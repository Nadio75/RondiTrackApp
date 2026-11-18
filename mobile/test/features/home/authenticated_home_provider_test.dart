import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ronditrack/core/network/dio_provider.dart';
import 'package:ronditrack/core/offline/app_database.dart';
import 'package:ronditrack/core/offline/home_cache_repository.dart';
import 'package:ronditrack/core/offline/offline_home_providers.dart';
import 'package:ronditrack/features/home/domain/offline_home_provider.dart';
import 'package:ronditrack/features/session/presentation/session_provider.dart';

class DelayedHomeAdapter implements HttpClientAdapter {
  final started = Completer<void>();
  final response = Completer<ResponseBody>();

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    if (!started.isCompleted) {
      started.complete();
    }

    return response.future;
  }

  void completeSuccess() {
    response.complete(
      ResponseBody.fromString(
        jsonEncode({
          'stokvels': [
            {
              'stokvelId': 'stale-stokvel',
              'name': 'Stale Club',
              'role': 'Member',
              'contributionAmount': '500.00',
              'currentCycle': null,
            },
          ],
        }),
        200,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      ),
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test(
    'old Home response cannot overwrite cache after same-account relogin',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final cache = HomeCacheRepository(database);
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:5056'));
      final adapter = DelayedHomeAdapter();

      dio.httpClientAdapter = adapter;

      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          dioProvider.overrideWithValue(dio),
        ],
      );

      addTearDown(() async {
        container.dispose();
        dio.close(force: true);
        await database.close();
      });

      final session = container.read(sessionProvider.notifier);

      expect(session.login('lerato@example.com', 'testpassword123'), isTrue);

      final accountId = container.read(sessionProvider)!.id;

      await cache.save(
        accountId: accountId,
        stokvels: [
          const CachedHomeStokvel(
            id: 'original-stokvel',
            name: 'Original Club',
            role: 'Member',
          ),
        ],
      );

      final subscription = container.listen(
        authenticatedHomeProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);

      final oldRequest = container.read(authenticatedHomeProvider.future);

      await adapter.started.future;

      session.logout();

      expect(session.login('lerato@example.com', 'testpassword123'), isTrue);

      expect(container.read(sessionProvider)!.id, accountId);

      adapter.completeSuccess();

      try {
        await oldRequest.timeout(const Duration(seconds: 5));
      } on StateError {
        // A rejected stale response is acceptable.
      } on TimeoutException {
        // Riverpod may discard the invalidated provider's future.
      }

      final cached = await cache.load(accountId);

      expect(cached, isNotNull);
      expect(cached!.stokvels.single.id, 'original-stokvel');
    },
  );
}
