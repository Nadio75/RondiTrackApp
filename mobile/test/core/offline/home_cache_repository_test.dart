import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/core/offline/app_database.dart';
import 'package:ronditrack/core/offline/home_cache_repository.dart';

void main() {
  late AppDatabase database;
  late HomeCacheRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = HomeCacheRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  const firstStokvel = CachedHomeStokvel(
    id: 'stokvel-1',
    name: 'Savings Club',
    role: 'Member',
  );

  const secondStokvel = CachedHomeStokvel(
    id: 'stokvel-2',
    name: 'Family Fund',
    role: 'Treasurer',
  );

  final firstRefresh = DateTime.utc(2026, 11, 18, 10);
  final secondRefresh = DateTime.utc(2026, 11, 18, 11);

  test('saves and loads a Home snapshot', () async {
    await repository.save(
      accountId: 'user-1',
      stokvels: [firstStokvel],
      updatedAtUtc: firstRefresh,
    );

    final snapshot = await repository.load('user-1');

    expect(snapshot, isNotNull);
    expect(snapshot!.stokvels, hasLength(1));
    expect(snapshot.stokvels.single.id, 'stokvel-1');
    expect(snapshot.stokvels.single.name, 'Savings Club');
    expect(snapshot.stokvels.single.role, 'Member');
    expect(snapshot.updatedAtUtc, firstRefresh);
  });

  test('replaces an existing Home snapshot', () async {
    await repository.save(
      accountId: 'user-1',
      stokvels: [firstStokvel],
      updatedAtUtc: firstRefresh,
    );

    await repository.save(
      accountId: 'user-1',
      stokvels: [secondStokvel],
      updatedAtUtc: secondRefresh,
    );

    final snapshot = await repository.load('user-1');
    final rows = await database.select(database.cachedApiResponses).get();

    expect(snapshot!.stokvels, hasLength(1));
    expect(snapshot.stokvels.single.id, 'stokvel-2');
    expect(snapshot.updatedAtUtc, secondRefresh);
    expect(rows, hasLength(1));
  });

  test('watch emits updated Home snapshots', () async {
    final iterator = StreamIterator(repository.watch('user-1'));

    try {
      expect(await iterator.moveNext(), isTrue);
      expect(iterator.current, isNull);

      await repository.save(
        accountId: 'user-1',
        stokvels: [firstStokvel],
        updatedAtUtc: firstRefresh,
      );

      expect(await iterator.moveNext(), isTrue);
      expect(iterator.current!.stokvels.single.id, 'stokvel-1');

      await repository.save(
        accountId: 'user-1',
        stokvels: [secondStokvel],
        updatedAtUtc: secondRefresh,
      );

      expect(await iterator.moveNext(), isTrue);
      expect(iterator.current!.stokvels.single.id, 'stokvel-2');
    } finally {
      await iterator.cancel();
    }
  });

  test('guarded save rejects an invalid session', () async {
    await repository.save(accountId: 'user-1', stokvels: [firstStokvel]);

    await expectLater(
      repository.saveIfSessionCurrent(
        accountId: 'user-1',
        stokvels: [secondStokvel],
        isSessionCurrent: () => false,
      ),
      throwsA(isA<StateError>()),
    );

    final snapshot = await repository.load('user-1');

    expect(snapshot, isNotNull);
    expect(snapshot!.stokvels.single.id, 'stokvel-1');
  });

  test('guarded save rolls back when session changes during save', () async {
    await repository.save(accountId: 'user-1', stokvels: [firstStokvel]);

    var checks = 0;

    bool isSessionCurrent() {
      checks++;
      return checks == 1;
    }

    await expectLater(
      repository.saveIfSessionCurrent(
        accountId: 'user-1',
        stokvels: [secondStokvel],
        isSessionCurrent: isSessionCurrent,
      ),
      throwsA(isA<StateError>()),
    );

    expect(checks, 2);

    final snapshot = await repository.load('user-1');

    expect(snapshot, isNotNull);
    expect(snapshot!.stokvels.single.id, 'stokvel-1');
  });
  test('repository cleanup preserves pending payment intents', () async {
    await repository.save(accountId: 'user-1', stokvels: [firstStokvel]);

    await database
        .into(database.pendingPaymentIntents)
        .insert(
          PendingPaymentIntentsCompanion.insert(
            intentId: 'intent-user-1',
            accountId: 'user-1',
            stokvelId: 'stokvel-1',
            cycleId: 'cycle-1',
            memberId: 'user-1',
            amountInCents: 125050,
            idempotencyKey: 'key-user-1',
            createdAtUtc: DateTime.utc(2026, 11, 18),
          ),
        );

    await repository.clearAccount('user-1');

    expect(await repository.load('user-1'), isNull);

    final paymentRows = await database
        .select(database.pendingPaymentIntents)
        .get();

    expect(paymentRows, hasLength(1));
    expect(paymentRows.single.intentId, 'intent-user-1');
    expect(paymentRows.single.accountId, 'user-1');
    expect(paymentRows.single.amountInCents, 125050);
  });
  test('isolates accounts and clears signed-out account data', () async {
    await repository.save(accountId: 'user-1', stokvels: [firstStokvel]);

    await repository.save(accountId: 'user-2', stokvels: [secondStokvel]);

    expect((await repository.load('user-1'))!.stokvels.single.id, 'stokvel-1');

    expect((await repository.load('user-2'))!.stokvels.single.id, 'stokvel-2');

    await repository.clearAccount('user-1');

    expect(await repository.load('user-1'), isNull);
    expect((await repository.load('user-2'))!.stokvels.single.id, 'stokvel-2');
  });
}
