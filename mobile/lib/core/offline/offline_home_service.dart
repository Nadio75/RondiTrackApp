import 'package:dio/dio.dart';

import '../network/generated/me/me_client.dart';
import 'home_cache_repository.dart';

class OfflineHomeService {
  const OfflineHomeService({required this.client, required this.cache});

  final MeClient client;
  final HomeCacheRepository cache;

  Future<CachedHomeSnapshot> refresh(
    String accountId, {
    bool Function()? isSessionCurrent,
  }) async {
    final response = await client.getApiV1MeHome();

    final stokvels = response.stokvels
        .map(
          (item) => CachedHomeStokvel(
            id: item.stokvelId,
            name: item.name,
            role: item.role,
          ),
        )
        .toList(growable: false);

    if (isSessionCurrent != null && !isSessionCurrent()) {
      throw StateError('Session changed during Home refresh.');
    }

    final updatedAtUtc = DateTime.now().toUtc();

    if (isSessionCurrent != null) {
      await cache.saveIfSessionCurrent(
        accountId: accountId,
        stokvels: stokvels,
        updatedAtUtc: updatedAtUtc,
        isSessionCurrent: isSessionCurrent,
      );
    } else {
      await cache.save(
        accountId: accountId,
        stokvels: stokvels,
        updatedAtUtc: updatedAtUtc,
      );
    }

    final snapshot = await cache.load(accountId);

    if (snapshot == null) {
      throw StateError('Home cache was not saved.');
    }

    return snapshot;
  }

  Future<CachedHomeSnapshot?> loadOffline(String accountId) async {
    final snapshot = await cache.load(accountId);

    return snapshot?.withSource(HomeDataSource.offlineCache);
  }

  Future<CachedHomeSnapshot?> loadWithFallback(
    String accountId, {
    bool Function()? isSessionCurrent,
  }) async {
    try {
      return await refresh(accountId, isSessionCurrent: isSessionCurrent);
    } on DioException catch (error) {
      final status = error.response?.statusCode;

      if (status == 401 || status == 403) {
        rethrow;
      }

      final networkUnavailable =
          status == null &&
          const {
            DioExceptionType.connectionError,
            DioExceptionType.connectionTimeout,
            DioExceptionType.sendTimeout,
            DioExceptionType.receiveTimeout,
          }.contains(error.type);

      final serverUnavailable =
          status != null && (status >= 500 || status == 429);

      if (!networkUnavailable && !serverUnavailable) {
        rethrow;
      }

      if (isSessionCurrent != null && !isSessionCurrent()) {
        throw StateError('Session changed during Home refresh.');
      }

      final snapshot = await cache.load(accountId);

      if (isSessionCurrent != null && !isSessionCurrent()) {
        throw StateError('Session changed during Home refresh.');
      }

      if (snapshot == null) {
        rethrow;
      }

      return snapshot.withSource(
        networkUnavailable
            ? HomeDataSource.offlineCache
            : HomeDataSource.unavailableCache,
      );
    }
  }
}
