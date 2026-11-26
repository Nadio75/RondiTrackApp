import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/core/offline/app_database.dart';
import 'package:ronditrack/core/offline/payment_outbox_repository.dart';
import 'package:ronditrack/core/offline/payment_outbox_service.dart';

import 'payment_outbox_service_test.dart' show ScriptedPaymentApi;

void main() {
  late Directory directory;
  late File databaseFile;
  late AppDatabase database;
  late PaymentOutboxRepository repository;
  late PaymentOutboxService service;
  late ScriptedPaymentApi api;
  late DateTime now;
  late int sequence;

  void openDatabase() {
    database = AppDatabase.forTesting(NativeDatabase(databaseFile));

    repository = PaymentOutboxRepository(
      database,
      clock: () => now,
      generateId: () => 'restart-${++sequence}',
    );

    service = PaymentOutboxService(
      repository: repository,
      api: api,
      clock: () => now,
    );
  }

  Future<void> restartApplication() async {
    await database.close();
    openDatabase();
  }

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('ronditrack-outbox-');

    databaseFile = File(
      '${directory.path}${Platform.pathSeparator}outbox.sqlite',
    );

    now = DateTime.utc(2026, 11, 24, 10);
    sequence = 0;
    api = ScriptedPaymentApi();

    openDatabase();
  });

  tearDown(() async {
    await database.close();
    await directory.delete(recursive: true);
  });

  Future<PendingPaymentIntent> enqueue({String accountId = 'account-1'}) {
    return repository.enqueue(
      accountId: accountId,
      stokvelId: 'restart-stokvel',
      cycleId: 'restart-cycle',
      memberId: 'restart-member',
      amountInCents: 125050,
      isSessionCurrent: () => true,
    );
  }

  Future<List<PaymentAttemptResult>> process() {
    return service.process(
      accountId: 'account-1',
      isSessionCurrent: () => true,
    );
  }

  test('pending contribution survives database restart', () async {
    final original = await enqueue();

    expect(await databaseFile.exists(), isTrue);

    await restartApplication();

    final stored = await repository.pendingForAccount('account-1');

    expect(stored, hasLength(1));
    expect(stored.single.intentId, original.intentId);
    expect(stored.single.idempotencyKey, original.idempotencyKey);
    expect(stored.single.amountInCents, 125050);
    expect(stored.single.createdAtUtc.toUtc(), now);
    expect(stored.single.status, 'pending');
  });

  test('lost response survives restart and records only once', () async {
    final original = await enqueue();

    api.loseNextResponse = true;

    final first = await process();

    expect(first.single.outcome, PaymentOutcome.pending);
    expect(api.recordedKeys, hasLength(1));

    await restartApplication();

    final stored = await repository.pendingForAccount('account-1');

    expect(stored.single.idempotencyKey, original.idempotencyKey);

    now = now.add(PaymentOutboxService.temporaryRetryDelay);

    final second = await process();

    expect(second.single.outcome, PaymentOutcome.recorded);

    expect(api.sentKeys, [original.idempotencyKey, original.idempotencyKey]);

    expect(api.recordedKeys, {original.idempotencyKey});
    expect(await repository.pendingForAccount('account-1'), isEmpty);
  });

  test(
    'restart after server commit but before local acknowledgement',
    () async {
      final original = await enqueue();

      // Simulate the server accepting the request before the
      // application can remove its locally persisted intent.
      await api.send(original, idempotencyKey: original.idempotencyKey);

      expect(api.recordedKeys, hasLength(1));
      expect(await repository.pendingForAccount('account-1'), hasLength(1));

      await restartApplication();

      final results = await process();

      expect(results.single.outcome, PaymentOutcome.recorded);

      expect(api.sentKeys, [original.idempotencyKey, original.idempotencyKey]);

      expect(api.recordedKeys, {original.idempotencyKey});
      expect(await repository.pendingForAccount('account-1'), isEmpty);
    },
  );

  test('Retry-After deadline and key survive restart', () async {
    final original = await enqueue();

    api.nextStatus = 429;

    final first = await process();

    expect(first.single.outcome, PaymentOutcome.rateLimited);

    final deadline = now.add(const Duration(seconds: 120));

    await restartApplication();

    final stored = await repository.pendingForAccount('account-1');

    expect(stored.single.nextAttemptAtUtc?.toUtc(), deadline);
    expect(stored.single.idempotencyKey, original.idempotencyKey);

    now = now.add(const Duration(seconds: 119));

    await process();

    expect(api.sentKeys, hasLength(1));

    now = now.add(const Duration(seconds: 1));

    final second = await process();

    expect(second.single.outcome, PaymentOutcome.recorded);

    expect(api.sentKeys, [original.idempotencyKey, original.idempotencyKey]);

    expect(api.recordedKeys, {original.idempotencyKey});
    expect(await repository.pendingForAccount('account-1'), isEmpty);
  });

  test('signed-out account data stays deleted after restart', () async {
    await enqueue();

    final other = await enqueue(accountId: 'account-2');

    await database.clearAccountData('account-1');

    await restartApplication();

    expect(await repository.pendingForAccount('account-1'), isEmpty);

    final remaining = await repository.pendingForAccount('account-2');

    expect(remaining, hasLength(1));
    expect(remaining.single.idempotencyKey, other.idempotencyKey);

    await process();

    expect(api.sentKeys, isEmpty);
  });

  test('expired contribution is never resent after restart', () async {
    await enqueue();

    await restartApplication();

    now = now.add(PaymentOutboxService.maximumAge);

    final results = await process();

    expect(results.single.outcome, PaymentOutcome.expired);
    expect(api.sentKeys, isEmpty);
    expect(await repository.pendingForAccount('account-1'), isEmpty);
  });
}
