import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'app_database.dart';

class PaymentOutboxRepository {
  PaymentOutboxRepository(
    this._database, {
    DateTime Function()? clock,
    String Function()? generateId,
  }) : _clock = clock ?? DateTime.now,
       _generateId = generateId ?? (() => const Uuid().v4());

  final AppDatabase _database;
  final DateTime Function() _clock;
  final String Function() _generateId;

  Future<PendingPaymentIntent> enqueue({
    required String accountId,
    required String stokvelId,
    required String cycleId,
    required String memberId,
    required int amountInCents,
    required bool Function() isSessionCurrent,
  }) async {
    if (amountInCents <= 0) {
      throw ArgumentError('Contribution amount must be positive.');
    }

    if ([
      accountId,
      stokvelId,
      cycleId,
      memberId,
    ].any((value) => value.trim().isEmpty)) {
      throw ArgumentError('Required identifiers must not be empty.');
    }

    final intentId = _generateId();
    final idempotencyKey = _generateId();

    return _database.transaction(() async {
      if (!isSessionCurrent()) {
        throw StateError('Session changed before contribution was saved.');
      }

      await _database
          .into(_database.pendingPaymentIntents)
          .insert(
            PendingPaymentIntentsCompanion.insert(
              intentId: intentId,
              accountId: accountId,
              stokvelId: stokvelId,
              cycleId: cycleId,
              memberId: memberId,
              amountInCents: amountInCents,
              idempotencyKey: idempotencyKey,
              createdAtUtc: _clock().toUtc(),
            ),
          );

      final intent =
          await (_database.select(_database.pendingPaymentIntents)..where(
                (row) =>
                    row.accountId.equals(accountId) &
                    row.intentId.equals(intentId),
              ))
              .getSingle();

      if (!isSessionCurrent()) {
        throw StateError('Session changed during contribution save.');
      }

      return intent;
    });
  }

  Future<List<PendingPaymentIntent>> pendingForAccount(String accountId) {
    return (_database.select(_database.pendingPaymentIntents)
          ..where(
            (row) =>
                row.accountId.equals(accountId) & row.status.equals('pending'),
          )
          ..orderBy([
            (row) => OrderingTerm.asc(row.createdAtUtc),
            (row) => OrderingTerm.asc(row.intentId),
          ]))
        .get();
  }

  Future<List<PendingPaymentIntent>> readyForAccount(String accountId) async {
    final now = _clock().toUtc();
    final pending = await pendingForAccount(accountId);

    return pending
        .where((intent) {
          final nextAttempt = intent.nextAttemptAtUtc;

          return nextAttempt == null || !nextAttempt.toUtc().isAfter(now);
        })
        .toList(growable: false);
  }

  Future<void> defer({
    required String accountId,
    required String intentId,
    required DateTime nextAttemptAtUtc,
  }) async {
    await (_database.update(_database.pendingPaymentIntents)..where(
          (row) =>
              row.accountId.equals(accountId) & row.intentId.equals(intentId),
        ))
        .write(
          PendingPaymentIntentsCompanion(
            nextAttemptAtUtc: Value(nextAttemptAtUtc.toUtc()),
          ),
        );
  }

  Future<DateTime?> accountRetryAt(String accountId) async {
    final limit = await (_database.select(
      _database.paymentRetryLimits,
    )..where((row) => row.accountId.equals(accountId))).getSingleOrNull();

    return limit?.retryAtUtc.toUtc();
  }

  Future<void> deferAccount({
    required String accountId,
    required DateTime retryAtUtc,
    required bool Function() isSessionCurrent,
  }) async {
    await _database.transaction(() async {
      if (!isSessionCurrent()) {
        return;
      }

      final existing = await accountRetryAt(accountId);

      if (!isSessionCurrent()) {
        return;
      }

      if (existing != null && existing.isAfter(retryAtUtc)) {
        return;
      }

      await _database
          .into(_database.paymentRetryLimits)
          .insertOnConflictUpdate(
            PaymentRetryLimitsCompanion.insert(
              accountId: accountId,
              retryAtUtc: retryAtUtc.toUtc(),
            ),
          );

      if (!isSessionCurrent()) {
        throw StateError('Session changed during retry limit save.');
      }
    });
  }

  Future<void> remove({
    required String accountId,
    required String intentId,
  }) async {
    await (_database.delete(_database.pendingPaymentIntents)..where(
          (row) =>
              row.accountId.equals(accountId) & row.intentId.equals(intentId),
        ))
        .go();
  }
}
