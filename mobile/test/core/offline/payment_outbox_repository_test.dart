import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/core/offline/app_database.dart';
import 'package:ronditrack/core/offline/payment_outbox_repository.dart';

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
      generateId: () => 'synthetic-${++sequence}',
    );
  });

  tearDown(() async {
    await database.close();
  });

  Future<PendingPaymentIntent> enqueue({
    String accountId = 'account-1',
    int amount = 50000,
    bool Function()? session,
  }) {
    return repository.enqueue(
      accountId: accountId,
      stokvelId: 'synthetic-stokvel',
      cycleId: 'synthetic-cycle',
      memberId: 'synthetic-member',
      amountInCents: amount,
      isSessionCurrent: session ?? () => true,
    );
  }

  test('enqueue persists amount and original idempotency key', () async {
    final intent = await enqueue();
    final stored = await repository.pendingForAccount('account-1');

    expect(stored, hasLength(1));
    expect(stored.single.amountInCents, 50000);
    expect(stored.single.idempotencyKey, intent.idempotencyKey);
    expect(stored.single.createdAtUtc.toUtc(), now);
    expect(stored.single.status, 'pending');
  });

  test('separate contribution intents receive different keys', () async {
    final first = await enqueue();
    final second = await enqueue();

    expect(first.intentId, isNot(second.intentId));
    expect(first.idempotencyKey, isNot(second.idempotencyKey));
  });

  test('zero and negative amounts are rejected', () async {
    await expectLater(enqueue(amount: 0), throwsArgumentError);

    await expectLater(enqueue(amount: -100), throwsArgumentError);

    expect(await repository.pendingForAccount('account-1'), isEmpty);
  });

  test('pending intents are isolated by account', () async {
    final first = await enqueue();
    await enqueue(accountId: 'account-2');

    final stored = await repository.pendingForAccount('account-1');

    expect(stored, hasLength(1));
    expect(stored.single.intentId, first.intentId);
  });

  test('another account cannot remove a pending intent', () async {
    final intent = await enqueue();

    await repository.remove(accountId: 'account-2', intentId: intent.intentId);

    expect(await repository.pendingForAccount('account-1'), hasLength(1));
  });

  test('another account cannot defer a pending intent', () async {
    final intent = await enqueue();

    await repository.defer(
      accountId: 'account-2',
      intentId: intent.intentId,
      nextAttemptAtUtc: now.add(const Duration(hours: 1)),
    );

    final stored = await repository.pendingForAccount('account-1');

    expect(stored.single.nextAttemptAtUtc, isNull);
  });

  test('deferred intent is not ready before retry deadline', () async {
    final intent = await enqueue();

    await repository.defer(
      accountId: 'account-1',
      intentId: intent.intentId,
      nextAttemptAtUtc: now.add(const Duration(seconds: 120)),
    );

    now = now.add(const Duration(seconds: 119));

    expect(await repository.readyForAccount('account-1'), isEmpty);
  });

  test('retry deadline preserves the original idempotency key', () async {
    final intent = await enqueue();

    await repository.defer(
      accountId: 'account-1',
      intentId: intent.intentId,
      nextAttemptAtUtc: now.add(const Duration(seconds: 120)),
    );

    now = now.add(const Duration(seconds: 120));

    final ready = await repository.readyForAccount('account-1');

    expect(ready, hasLength(1));
    expect(ready.single.idempotencyKey, intent.idempotencyKey);
  });

  test('completed intent can be removed', () async {
    final intent = await enqueue();

    await repository.remove(accountId: 'account-1', intentId: intent.intentId);

    expect(await repository.pendingForAccount('account-1'), isEmpty);
  });

  test('invalid session cannot enqueue a contribution', () async {
    await expectLater(enqueue(session: () => false), throwsStateError);

    expect(await repository.pendingForAccount('account-1'), isEmpty);
  });

  test('session invalidation rolls back the queued intent', () async {
    var checks = 0;

    await expectLater(enqueue(session: () => ++checks == 1), throwsStateError);

    expect(await repository.pendingForAccount('account-1'), isEmpty);
  });

  test('account cleanup removes only its pending intents', () async {
    await enqueue();
    await enqueue(accountId: 'account-2');

    await database.clearAccountData('account-1');

    expect(await repository.pendingForAccount('account-1'), isEmpty);

    expect(await repository.pendingForAccount('account-2'), hasLength(1));
  });
}
