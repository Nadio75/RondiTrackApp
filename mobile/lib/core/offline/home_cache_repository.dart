import 'dart:convert';

import 'package:drift/drift.dart';

import 'app_database.dart';

class CachedHomeStokvel {
  const CachedHomeStokvel({
    required this.id,
    required this.name,
    required this.role,
  });

  final String id;
  final String name;
  final String role;

  Map<String, String> toJson() => {'id': id, 'name': name, 'role': role};

  factory CachedHomeStokvel.fromJson(Map<String, dynamic> json) {
    return CachedHomeStokvel(
      id: json['id'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
    );
  }
}

enum HomeDataSource { live, offlineCache, unavailableCache }

class CachedHomeSnapshot {
  const CachedHomeSnapshot({
    required this.stokvels,
    required this.updatedAtUtc,
    this.source = HomeDataSource.live,
  });

  final List<CachedHomeStokvel> stokvels;
  final DateTime updatedAtUtc;
  final HomeDataSource source;

  bool get isCached => source != HomeDataSource.live;

  CachedHomeSnapshot withSource(HomeDataSource source) {
    return CachedHomeSnapshot(
      stokvels: stokvels,
      updatedAtUtc: updatedAtUtc,
      source: source,
    );
  }
}

class HomeCacheRepository {
  const HomeCacheRepository(this._database);

  final AppDatabase _database;

  static const _cacheKey = 'home:v1';

  Future<void> save({
    required String accountId,
    required List<CachedHomeStokvel> stokvels,
    DateTime? updatedAtUtc,
  }) async {
    final json = jsonEncode(
      stokvels.map((stokvel) => stokvel.toJson()).toList(),
    );

    await _database
        .into(_database.cachedApiResponses)
        .insertOnConflictUpdate(
          CachedApiResponsesCompanion.insert(
            cacheKey: _cacheKey,
            accountId: accountId,
            responseJson: json,
            updatedAtUtc: updatedAtUtc ?? DateTime.now().toUtc(),
          ),
        );
  }

  /// Saves Home data only while the originating session is current.
  ///
  /// The session check and database write run in one transaction.
  Future<void> saveIfSessionCurrent({
    required String accountId,
    required List<CachedHomeStokvel> stokvels,
    required bool Function() isSessionCurrent,
    DateTime? updatedAtUtc,
  }) async {
    final json = jsonEncode(
      stokvels.map((stokvel) => stokvel.toJson()).toList(),
    );

    await _database.transaction(() async {
      if (!isSessionCurrent()) {
        throw StateError('Session changed during Home cache save.');
      }

      await _database
          .into(_database.cachedApiResponses)
          .insertOnConflictUpdate(
            CachedApiResponsesCompanion.insert(
              cacheKey: _cacheKey,
              accountId: accountId,
              responseJson: json,
              updatedAtUtc: updatedAtUtc ?? DateTime.now().toUtc(),
            ),
          );

      if (!isSessionCurrent()) {
        throw StateError('Session changed during Home cache save.');
      }
    });
  }

  Future<CachedHomeSnapshot?> load(String accountId) async {
    final query = _database.select(_database.cachedApiResponses)
      ..where(
        (row) =>
            row.accountId.equals(accountId) & row.cacheKey.equals(_cacheKey),
      );

    final row = await query.getSingleOrNull();

    if (row == null) return null;

    return _decode(row.responseJson, row.updatedAtUtc);
  }

  Stream<CachedHomeSnapshot?> watch(String accountId) {
    final query = _database.select(_database.cachedApiResponses)
      ..where(
        (row) =>
            row.accountId.equals(accountId) & row.cacheKey.equals(_cacheKey),
      );

    return query.watchSingleOrNull().map((row) {
      if (row == null) return null;
      return _decode(row.responseJson, row.updatedAtUtc);
    });
  }

  CachedHomeSnapshot _decode(String json, DateTime updatedAtUtc) {
    final items = jsonDecode(json) as List<dynamic>;

    return CachedHomeSnapshot(
      stokvels: List.unmodifiable(
        items.map(
          (item) => CachedHomeStokvel.fromJson(item as Map<String, dynamic>),
        ),
      ),
      updatedAtUtc: updatedAtUtc.toUtc(),
    );
  }

  Future<void> clearAccount(String accountId) {
    return _database.clearAccountCache(accountId);
  }
}
