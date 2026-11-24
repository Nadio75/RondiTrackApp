import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/core/network/generated/me/me_client.dart';
import 'package:ronditrack/core/offline/app_database.dart';
import 'package:ronditrack/core/offline/home_cache_repository.dart';
import 'package:ronditrack/core/offline/offline_home_service.dart';

class FakeHomeAdapter implements HttpClientAdapter {
  FakeHomeAdapter(this.statusCode, this.body);

  final int statusCode;
  final Object body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late AppDatabase database;
  late HomeCacheRepository cache;
  late Dio dio;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    cache = HomeCacheRepository(database);
    dio = Dio(BaseOptions(baseUrl: 'http://localhost:5056'));
  });

  tearDown(() async {
    dio.close(force: true);
    await database.close();
  });

  OfflineHomeService service() {
    return OfflineHomeService(client: MeClient(dio), cache: cache);
  }

  test('online refresh saves authenticated Home data', () async {
    dio.httpClientAdapter = FakeHomeAdapter(200, {
      'stokvels': [
        {
          'stokvelId': 'stokvel-1',
          'name': 'Savings Club',
          'role': 'Member',
          'contributionAmount': '500.00',
          'currentCycle': null,
        },
      ],
    });

    final snapshot = await service().refresh('user-1');

    expect(snapshot.stokvels, hasLength(1));
    expect(snapshot.stokvels.single.id, 'stokvel-1');
    expect(snapshot.stokvels.single.name, 'Savings Club');

    final persisted = await cache.load('user-1');
    expect(persisted!.stokvels.single.id, 'stokvel-1');
  });

  test('offline failure returns existing cached Home data', () async {
    await cache.save(
      accountId: 'user-1',
      stokvels: [
        const CachedHomeStokvel(
          id: 'cached-1',
          name: 'Offline Club',
          role: 'Member',
        ),
      ],
    );

    dio.httpClientAdapter = FakeHomeAdapter(503, {
      'message': 'Service unavailable',
    });

    final snapshot = await service().loadWithFallback('user-1');

    expect(snapshot, isNotNull);
    expect(snapshot!.stokvels.single.id, 'cached-1');
  });

  test('401 authentication failure never falls back to cache', () async {
    await cache.save(
      accountId: 'user-1',
      stokvels: [
        const CachedHomeStokvel(
          id: 'cached-1',
          name: 'Offline Club',
          role: 'Member',
        ),
      ],
    );

    dio.httpClientAdapter = FakeHomeAdapter(401, {'message': 'Unauthorized'});

    await expectLater(
      service().loadWithFallback('user-1'),
      throwsA(isA<DioException>()),
    );
  });

  test('stale successful response never overwrites cache', () async {
    await cache.save(
      accountId: 'user-1',
      stokvels: [
        const CachedHomeStokvel(
          id: 'original-1',
          name: 'Original Club',
          role: 'Member',
        ),
      ],
    );

    dio.httpClientAdapter = FakeHomeAdapter(200, {
      'stokvels': [
        {
          'stokvelId': 'new-1',
          'name': 'New Club',
          'role': 'Member',
          'contributionAmount': '500.00',
          'currentCycle': null,
        },
      ],
    });

    var sessionCurrent = true;

    final result = service().refresh(
      'user-1',
      isSessionCurrent: () => sessionCurrent,
    );

    sessionCurrent = false;

    await expectLater(result, throwsA(isA<StateError>()));

    final snapshot = await cache.load('user-1');

    expect(snapshot, isNotNull);
    expect(snapshot!.stokvels.single.id, 'original-1');
  });

  test('service guarded save rolls back after session invalidation', () async {
    await cache.save(
      accountId: 'user-1',
      stokvels: [
        const CachedHomeStokvel(
          id: 'original-1',
          name: 'Original Club',
          role: 'Member',
        ),
      ],
    );

    dio.httpClientAdapter = FakeHomeAdapter(200, {
      'stokvels': [
        {
          'stokvelId': 'new-1',
          'name': 'New Club',
          'role': 'Member',
          'contributionAmount': '500.00',
          'currentCycle': null,
        },
      ],
    });

    var checks = 0;

    bool isSessionCurrent() {
      checks++;
      return checks == 1;
    }

    await expectLater(
      service().refresh('user-1', isSessionCurrent: isSessionCurrent),
      throwsA(isA<StateError>()),
    );

    expect(checks, 2);

    final snapshot = await cache.load('user-1');

    expect(snapshot, isNotNull);
    expect(snapshot!.stokvels.single.id, 'original-1');
  });
  test('stale session cannot receive offline fallback', () async {
    await cache.save(
      accountId: 'user-1',
      stokvels: [
        const CachedHomeStokvel(
          id: 'cached-1',
          name: 'Offline Club',
          role: 'Member',
        ),
      ],
    );

    dio.httpClientAdapter = FakeHomeAdapter(503, {
      'message': 'Service unavailable',
    });

    var sessionCurrent = true;

    final result = service().loadWithFallback(
      'user-1',
      isSessionCurrent: () => sessionCurrent,
    );

    sessionCurrent = false;

    await expectLater(result, throwsA(isA<StateError>()));
  });

  test('offline fallback never reads another account cache', () async {
    await cache.save(
      accountId: 'user-2',
      stokvels: [
        const CachedHomeStokvel(
          id: 'private-2',
          name: 'Other Account',
          role: 'Treasurer',
        ),
      ],
    );

    dio.httpClientAdapter = FakeHomeAdapter(503, {
      'message': 'Service unavailable',
    });

    await expectLater(
      service().loadWithFallback('user-1'),
      throwsA(isA<DioException>()),
    );

    expect(await cache.load('user-1'), isNull);

    final otherAccount = await cache.load('user-2');

    expect(otherAccount, isNotNull);
    expect(otherAccount!.stokvels.single.id, 'private-2');
  });
}
