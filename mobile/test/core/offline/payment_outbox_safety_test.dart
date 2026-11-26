import 'dart:async';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/core/offline/app_database.dart';
import 'package:ronditrack/core/offline/payment_outbox_api.dart';
import 'package:ronditrack/core/offline/payment_outbox_repository.dart';
import 'package:ronditrack/core/offline/payment_outbox_service.dart';

import 'payment_outbox_service_test.dart' show ScriptedPaymentApi;

class BlockingPaymentApi implements PaymentOutboxApi {
  final started = Completer<void>();
  final release = Completer<void>();
  final sentKeys = <String>[];

  @override
  Future<void> send(
    PendingPaymentIntent intent, {
    required String idempotencyKey,
  }) async {
    sentKeys.add(idempotencyKey);

    if (!started.isCompleted) {
      started.complete();
    }

    await release.future;
  }
}

void main() {
  late AppDatabase database;
  late PaymentOutboxRepository repository;
  late DateTime now;
  late int sequence;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    now = DateTime.utc(2026, 11, 24, 10);
    sequence = 0;

    repository = PaymentOutboxRepository(
      database,
      clock: () => now,
      generateId: () => 'safety-${++sequence}',
    );
  });

  tearDown(() async {
    await database.close();
  });

  Future<PendingPaymentIntent> enqueue({String accountId = 'account-1'}) {
    return repository.enqueue(
      accountId: accountId,
      stokvelId: 'synthetic-stokvel',
      cycleId: 'synthetic-cycle',
      memberId: 'synthetic-member',
      amountInCents: 125050,
      isSessionCurrent: () => true,
    );
  }

  PaymentOutboxService createService(PaymentOutboxApi api) {
    return PaymentOutboxService(
      repository: repository,
      api: api,
      clock: () => now,
    );
  }

  test('Dio sender uses correct route header and integer cents', () async {
    final intent = await enqueue();
    final requests = <RequestOptions>[];

    final dio = Dio(BaseOptions(baseUrl: 'https://example.invalid'));

    addTearDown(() => dio.close(force: true));

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requests.add(options);

          handler.resolve(
            Response<dynamic>(requestOptions: options, statusCode: 201),
          );
        },
      ),
    );

    final api = DioPaymentOutboxApi(dio);

    await api.send(intent, idempotencyKey: intent.idempotencyKey);

    expect(requests, hasLength(1));

    final request = requests.single;

    expect(request.method, 'POST');

    expect(
      request.path,
      '/api/v1/stokvels/synthetic-stokvel/cycles/synthetic-cycle/contributions',
    );

    final key = request.headers.entries.singleWhere(
      (entry) => entry.key.toLowerCase() == 'idempotency-key',
    );

    expect(key.value, intent.idempotencyKey);

    expect(request.data, {
      'userId': 'synthetic-member',
      'amountInCents': 125050,
    });

    expect((request.data as Map)['amountInCents'], isA<int>());
  });

  test('later queued contributions cannot bypass Retry-After', () async {
    final api = ScriptedPaymentApi();
    final service = createService(api);

    final first = await enqueue();

    now = now.add(const Duration(seconds: 1));

    final second = await enqueue();

    api.nextStatus = 429;

    await service.process(accountId: 'account-1', isSessionCurrent: () => true);

    expect(api.sentKeys, [first.idempotencyKey]);

    now = now.add(const Duration(seconds: 119));

    await service.process(accountId: 'account-1', isSessionCurrent: () => true);

    expect(api.sentKeys, [first.idempotencyKey]);

    now = now.add(const Duration(seconds: 1));

    await service.process(accountId: 'account-1', isSessionCurrent: () => true);

    expect(api.sentKeys, [
      first.idempotencyKey,
      first.idempotencyKey,
      second.idempotencyKey,
    ]);

    expect(await repository.pendingForAccount('account-1'), isEmpty);
  });

  test('concurrent processing does not send an intent twice', () async {
    final api = BlockingPaymentApi();
    final service = createService(api);
    final intent = await enqueue();

    final first = service.process(
      accountId: 'account-1',
      isSessionCurrent: () => true,
    );

    try {
      await api.started.future.timeout(const Duration(seconds: 5));

      expect(service.isProcessing, isTrue);

      final second = await service.process(
        accountId: 'account-1',
        isSessionCurrent: () => true,
      );

      expect(second, isEmpty);
      expect(api.sentKeys, [intent.idempotencyKey]);
    } finally {
      api.release.complete();
      await first;
    }

    expect(service.isProcessing, isFalse);
    expect(api.sentKeys, hasLength(1));

    expect(await repository.pendingForAccount('account-1'), isEmpty);
  });

  test('late response after logout cannot process remaining intents', () async {
    final api = BlockingPaymentApi();
    final service = createService(api);

    final first = await enqueue();

    now = now.add(const Duration(seconds: 1));

    await enqueue();

    final other = await enqueue(accountId: 'account-2');

    var sessionCurrent = true;

    final processing = service.process(
      accountId: 'account-1',
      isSessionCurrent: () => sessionCurrent,
    );

    try {
      await api.started.future.timeout(const Duration(seconds: 5));

      sessionCurrent = false;

      await database.clearAccountData('account-1');
    } finally {
      api.release.complete();
      await processing;
    }

    expect(await processing, isEmpty);
    expect(api.sentKeys, [first.idempotencyKey]);

    expect(await repository.pendingForAccount('account-1'), isEmpty);

    final remaining = await repository.pendingForAccount('account-2');

    expect(remaining, hasLength(1));
    expect(remaining.single.intentId, other.intentId);
    expect(service.isProcessing, isFalse);
  });
}
