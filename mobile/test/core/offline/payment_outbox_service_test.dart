import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/core/offline/app_database.dart';
import 'package:ronditrack/core/offline/payment_outbox_api.dart';
import 'package:ronditrack/core/offline/payment_outbox_repository.dart';
import 'package:ronditrack/core/offline/payment_outbox_service.dart';

class ScriptedPaymentApi implements PaymentOutboxApi {
  final sentKeys = <String>[];
  final recordedKeys = <String>{};

  int? nextStatus;
  String? nextDetail;
  bool loseNextResponse = false;

  @override
  Future<void> send(
    PendingPaymentIntent intent, {
    required String idempotencyKey,
  }) async {
    sentKeys.add(idempotencyKey);

    final request = RequestOptions(path: '/synthetic-payment');

    final status = nextStatus;
    nextStatus = null;

    if (status != null) {
      throw DioException.badResponse(
        statusCode: status,
        requestOptions: request,
        response: Response<dynamic>(
          requestOptions: request,
          statusCode: status,
          data: {'detail': nextDetail},
          headers: Headers.fromMap({
            if (status == 429) 'retry-after': ['120'],
          }),
        ),
      );
    }

    recordedKeys.add(idempotencyKey);

    if (loseNextResponse) {
      loseNextResponse = false;

      throw DioException(
        requestOptions: request,
        type: DioExceptionType.receiveTimeout,
      );
    }
  }
}

void main() {
  late AppDatabase database;
  late PaymentOutboxRepository repository;
  late PaymentOutboxService service;
  late ScriptedPaymentApi api;
  late DateTime now;
  late int sequence;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    now = DateTime.utc(2026, 11, 24, 10);
    sequence = 0;
    api = ScriptedPaymentApi();

    repository = PaymentOutboxRepository(
      database,
      clock: () => now,
      generateId: () => 'test-${++sequence}',
    );

    service = PaymentOutboxService(
      repository: repository,
      api: api,
      clock: () => now,
    );
  });

  tearDown(() async {
    await database.close();
  });

  Future<PendingPaymentIntent> enqueue({String accountId = 'account-1'}) {
    return repository.enqueue(
      accountId: accountId,
      stokvelId: 'test-stokvel',
      cycleId: 'test-cycle',
      memberId: 'test-member',
      amountInCents: 15050,
      isSessionCurrent: () => true,
    );
  }

  Future<List<PaymentAttemptResult>> process() {
    return service.process(
      accountId: 'account-1',
      isSessionCurrent: () => true,
    );
  }

  test('successful contribution removes the pending intent', () async {
    final intent = await enqueue();
    final results = await process();

    expect(results.single.outcome, PaymentOutcome.recorded);
    expect(api.sentKeys, [intent.idempotencyKey]);
    expect(await repository.pendingForAccount('account-1'), isEmpty);
  });

  test('lost response retries the same key and records only once', () async {
    final intent = await enqueue();
    api.loseNextResponse = true;

    final first = await process();

    expect(first.single.outcome, PaymentOutcome.pending);

    final pending = await repository.pendingForAccount('account-1');
    expect(pending.single.idempotencyKey, intent.idempotencyKey);

    now = now.add(PaymentOutboxService.temporaryRetryDelay);

    final second = await process();

    expect(second.single.outcome, PaymentOutcome.recorded);
    expect(api.sentKeys, [intent.idempotencyKey, intent.idempotencyKey]);
    expect(api.recordedKeys, {intent.idempotencyKey});
    expect(await repository.pendingForAccount('account-1'), isEmpty);
  });

  test('429 respects Retry-After and retries the same key', () async {
    final intent = await enqueue();
    api.nextStatus = 429;

    final first = await process();

    expect(first.single.outcome, PaymentOutcome.rateLimited);
    expect(first.single.retryAtUtc, now.add(const Duration(seconds: 120)));

    now = now.add(const Duration(seconds: 119));

    await process();

    expect(api.sentKeys, hasLength(1));

    now = now.add(const Duration(seconds: 1));

    final second = await process();

    expect(second.single.outcome, PaymentOutcome.recorded);
    expect(api.sentKeys, [intent.idempotencyKey, intent.idempotencyKey]);
    expect(await repository.pendingForAccount('account-1'), isEmpty);
  });

  test('already paid conflict removes intent without retry', () async {
    await enqueue();
    api.nextStatus = 409;
    api.nextDetail = 'This member has already paid for this cycle.';

    final results = await process();

    expect(results.single.outcome, PaymentOutcome.alreadyPaid);
    expect(await repository.pendingForAccount('account-1'), isEmpty);

    await process();

    expect(api.sentKeys, hasLength(1));
  });

  test('closed cycle removes intent without retry', () async {
    await enqueue();
    api.nextStatus = 409;
    api.nextDetail = 'This contribution cycle is closed.';

    final results = await process();

    expect(results.single.outcome, PaymentOutcome.cycleClosed);
    expect(await repository.pendingForAccount('account-1'), isEmpty);

    await process();

    expect(api.sentKeys, hasLength(1));
  });

  test('expired intent is removed without sending', () async {
    await enqueue();

    now = now.add(PaymentOutboxService.maximumAge);

    final results = await process();

    expect(results.single.outcome, PaymentOutcome.expired);
    expect(api.sentKeys, isEmpty);
    expect(await repository.pendingForAccount('account-1'), isEmpty);
  });

  test('another account intent is never sent', () async {
    await enqueue(accountId: 'account-2');

    final results = await process();

    expect(results, isEmpty);
    expect(api.sentKeys, isEmpty);
    expect(await repository.pendingForAccount('account-2'), hasLength(1));
  });

  test('401 pauses processing and preserves the original key', () async {
    final intent = await enqueue();
    api.nextStatus = 401;

    final results = await process();

    expect(results.single.outcome, PaymentOutcome.authenticationRequired);

    final pending = await repository.pendingForAccount('account-1');

    expect(pending.single.idempotencyKey, intent.idempotencyKey);
  });

  test('503 preserves pending contribution and key', () async {
    final intent = await enqueue();
    api.nextStatus = 503;

    final results = await process();

    expect(results.single.outcome, PaymentOutcome.pending);

    final pending = await repository.pendingForAccount('account-1');

    expect(pending.single.idempotencyKey, intent.idempotencyKey);
    expect(pending.single.nextAttemptAtUtc, isNotNull);
  });

  for (final status in [400, 403, 404, 422]) {
    test('$status removes rejected intent', () async {
      await enqueue();
      api.nextStatus = status;

      final results = await process();

      expect(results.single.outcome, PaymentOutcome.rejected);
      expect(await repository.pendingForAccount('account-1'), isEmpty);

      await process();

      expect(api.sentKeys, hasLength(1));
    });
  }

  test('invalid session prevents any outgoing payment request', () async {
    await enqueue();

    final results = await service.process(
      accountId: 'account-1',
      isSessionCurrent: () => false,
    );

    expect(results, isEmpty);
    expect(api.sentKeys, isEmpty);
    expect(await repository.pendingForAccount('account-1'), hasLength(1));
  });
}
