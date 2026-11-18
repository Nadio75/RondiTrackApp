import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/core/offline/app_database.dart';
import 'package:drift/native.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('stores and retrieves cached API responses', () async {
    await database
        .into(database.cachedApiResponses)
        .insert(
          CachedApiResponsesCompanion.insert(
            cacheKey: 'home',
            accountId: 'user-1',
            responseJson: '{"stokvelCount":2}',
            updatedAtUtc: DateTime.utc(2026, 11, 18),
          ),
        );

    final rows = await database.select(database.cachedApiResponses).get();

    expect(rows.length, 1);
    expect(rows.single.cacheKey, 'home');
    expect(rows.single.accountId, 'user-1');
    expect(rows.single.responseJson, '{"stokvelCount":2}');
  });

  test('separates cached responses by account', () async {
    for (final accountId in ['user-1', 'user-2']) {
      await database
          .into(database.cachedApiResponses)
          .insert(
            CachedApiResponsesCompanion.insert(
              cacheKey: 'home',
              accountId: accountId,
              responseJson: '{"account":"$accountId"}',
              updatedAtUtc: DateTime.utc(2026, 11, 18),
            ),
          );
    }

    final rows = await database.select(database.cachedApiResponses).get();

    expect(rows.length, 2);
    expect(rows.map((row) => row.accountId).toSet(), {'user-1', 'user-2'});
  });

  test('cache-only cleanup preserves pending payment intents', () async {
    for (final accountId in ['user-1', 'user-2']) {
      await database
          .into(database.cachedApiResponses)
          .insert(
            CachedApiResponsesCompanion.insert(
              cacheKey: 'home',
              accountId: accountId,
              responseJson: '{}',
              updatedAtUtc: DateTime.utc(2026, 11, 18),
            ),
          );

      await database
          .into(database.pendingPaymentIntents)
          .insert(
            PendingPaymentIntentsCompanion.insert(
              intentId: 'intent-$accountId',
              accountId: accountId,
              stokvelId: 'stokvel-1',
              cycleId: 'cycle-1',
              memberId: accountId,
              amountInCents: 125050,
              idempotencyKey: 'key-$accountId',
              createdAtUtc: DateTime.utc(2026, 11, 18),
            ),
          );
    }

    await database.clearAccountCache('user-1');

    final cacheRows = await database.select(database.cachedApiResponses).get();

    final paymentRows = await database
        .select(database.pendingPaymentIntents)
        .get();

    expect(cacheRows, hasLength(1));
    expect(cacheRows.single.accountId, 'user-2');

    expect(paymentRows, hasLength(2));
    expect(paymentRows.map((row) => row.accountId).toSet(), {
      'user-1',
      'user-2',
    });
  });
  test('logout clears only the selected account data', () async {
    for (final accountId in ['user-1', 'user-2']) {
      await database
          .into(database.cachedApiResponses)
          .insert(
            CachedApiResponsesCompanion.insert(
              cacheKey: 'home',
              accountId: accountId,
              responseJson: '{}',
              updatedAtUtc: DateTime.utc(2026, 11, 18),
            ),
          );

      await database
          .into(database.pendingPaymentIntents)
          .insert(
            PendingPaymentIntentsCompanion.insert(
              intentId: 'intent-$accountId',
              accountId: accountId,
              stokvelId: 'stokvel-1',
              cycleId: 'cycle-1',
              memberId: accountId,
              amountInCents: 125050,
              idempotencyKey: 'key-$accountId',
              createdAtUtc: DateTime.utc(2026, 11, 18),
            ),
          );
    }

    await database.clearAccountData('user-1');

    final cache = await database.select(database.cachedApiResponses).get();

    final payments = await database
        .select(database.pendingPaymentIntents)
        .get();

    expect(cache.length, 1);
    expect(cache.single.accountId, 'user-2');

    expect(payments.length, 1);
    expect(payments.single.accountId, 'user-2');
  });
}
