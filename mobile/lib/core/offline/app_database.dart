import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class CachedApiResponses extends Table {
  TextColumn get cacheKey => text()();
  TextColumn get accountId => text()();
  TextColumn get responseJson => text()();
  DateTimeColumn get updatedAtUtc => dateTime()();

  @override
  Set<Column> get primaryKey => {cacheKey, accountId};
}

class PendingPaymentIntents extends Table {
  TextColumn get intentId => text()();
  TextColumn get accountId => text()();
  TextColumn get stokvelId => text()();
  TextColumn get cycleId => text()();
  TextColumn get memberId => text()();
  IntColumn get amountInCents => integer()();
  TextColumn get idempotencyKey => text().unique()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  DateTimeColumn get createdAtUtc => dateTime()();

  @override
  Set<Column> get primaryKey => {intentId};
}

@DriftDatabase(tables: [CachedApiResponses, PendingPaymentIntents])
class AppDatabase extends _$AppDatabase {
  AppDatabase()
    : super(
        driftDatabase(
          name: 'ronditrack_offline',
          web: DriftWebOptions(
            sqlite3Wasm: Uri.parse('sqlite3.wasm'),
            driftWorker: Uri.parse('drift_worker.js'),
          ),
        ),
      );

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  /// Clears cached API responses for one account.
  ///
  /// Pending payment intents are deliberately preserved.
  Future<void> clearAccountCache(String accountId) async {
    await (delete(
      cachedApiResponses,
    )..where((row) => row.accountId.equals(accountId))).go();
  }

  Future<void> clearAccountData(String accountId) async {
    await transaction(() async {
      await (delete(
        cachedApiResponses,
      )..where((row) => row.accountId.equals(accountId))).go();

      await (delete(
        pendingPaymentIntents,
      )..where((row) => row.accountId.equals(accountId))).go();
    });
  }
}
