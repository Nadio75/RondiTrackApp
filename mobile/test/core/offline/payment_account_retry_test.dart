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
      generateId: () => 'account-retry-${++sequence}',
    );

    service = PaymentOutboxService(
      repository: repository,
      api: api,
      clock: () => now,
    );
  }

  setUp(() async {
    directory = await Directory.systemTemp.createTemp(
      'ronditrack-account-retry-',
    );

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
      stokvelId: 'synthetic-stokvel',
      cycleId: 'synthetic-cycle',
      memberId: accountId,
      amountInCents: 125050,
      isSessionCurrent: () => true,
    );
  }

  Future<List<PaymentAttemptResult>> process({String accountId = 'account-1'}) {
    return service.process(accountId: accountId, isSessionCurrent: () => true);
  }

  test('429 persists an account-wide retry deadline', () async {
    await enqueue();

    api.nextStatus = 429;

    final results = await process();

    expect(results.single.outcome, PaymentOutcome.rateLimited);

    expect(
      await repository.accountRetryAt('account-1'),
      now.add(const Duration(seconds: 120)),
    );
  });

  test('new intent cannot bypass a previous account rate limit', () async {
    final original = await enqueue();

    api.nextStatus = 429;

    await process();

    await repository.remove(
      accountId: original.accountId,
      intentId: original.intentId,
    );

    final replacement = await enqueue();

    now = now.add(const Duration(seconds: 119));

    await process();

    expect(api.sentKeys, hasLength(1));

    now = now.add(const Duration(seconds: 1));

    await process();

    expect(api.sentKeys, [original.idempotencyKey, replacement.idempotencyKey]);
  });

  test('account retry deadline survives database restart', () async {
    final original = await enqueue();

    api.nextStatus = 429;

    await process();

    await database.close();

    openDatabase();

    expect(
      await repository.accountRetryAt('account-1'),
      now.add(const Duration(seconds: 120)),
    );

    now = now.add(const Duration(seconds: 119));

    await process();

    expect(api.sentKeys, hasLength(1));

    now = now.add(const Duration(seconds: 1));

    await process();

    expect(api.sentKeys, [original.idempotencyKey, original.idempotencyKey]);
  });

  test('rate limit does not block a different account', () async {
    await enqueue();

    final other = await enqueue(accountId: 'account-2');

    api.nextStatus = 429;

    await process();

    final results = await process(accountId: 'account-2');

    expect(results.single.outcome, PaymentOutcome.recorded);
    expect(api.sentKeys.last, other.idempotencyKey);
    expect(await repository.accountRetryAt('account-2'), isNull);
  });

  test('shorter retry deadline cannot replace longer deadline', () async {
    final longer = now.add(const Duration(minutes: 5));

    await repository.deferAccount(
      accountId: 'account-1',
      retryAtUtc: longer,
      isSessionCurrent: () => true,
    );

    await repository.deferAccount(
      accountId: 'account-1',
      retryAtUtc: now.add(const Duration(minutes: 1)),
      isSessionCurrent: () => true,
    );

    expect(await repository.accountRetryAt('account-1'), longer);
  });

  test('logout clears only its own account retry deadline', () async {
    final deadline = now.add(const Duration(minutes: 2));

    for (final accountId in ['account-1', 'account-2']) {
      await repository.deferAccount(
        accountId: accountId,
        retryAtUtc: deadline,
        isSessionCurrent: () => true,
      );
    }

    await database.clearAccountData('account-1');

    expect(await repository.accountRetryAt('account-1'), isNull);

    expect(await repository.accountRetryAt('account-2'), deadline);
  });
}
