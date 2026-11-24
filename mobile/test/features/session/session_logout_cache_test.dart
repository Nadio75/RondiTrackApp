import 'dart:async';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ronditrack/core/network/api_auth_client.dart';
import 'package:ronditrack/core/offline/app_database.dart';
import 'package:ronditrack/core/offline/home_cache_repository.dart';
import 'package:ronditrack/core/offline/offline_home_providers.dart';
import 'package:ronditrack/features/session/data/api_session_provider.dart';
import 'package:ronditrack/features/session/data/api_session_service.dart';
import 'package:ronditrack/features/session/presentation/session_lifecycle.dart';
import 'package:ronditrack/features/session/presentation/session_lifecycle_provider.dart';
import 'package:ronditrack/features/session/presentation/session_provider.dart';

class FakeLogoutService extends ApiSessionService {
  FakeLogoutService() : super(auth: ApiAuthClient(Dio()), dio: Dio());

  int logoutCalls = 0;
  bool failLogout = false;
  Completer<void>? pendingLogout;

  @override
  Future<void> logout() async {
    logoutCalls++;

    if (pendingLogout != null) {
      await pendingLogout!.future;
    }

    if (failLogout) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/auth/logout'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/auth/logout'),
          statusCode: 503,
        ),
        type: DioExceptionType.badResponse,
      );
    }
  }
}

void main() {
  test('API logout clears only the signed-out account Home cache', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final cache = HomeCacheRepository(database);
    final service = FakeLogoutService();

    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        apiSessionServiceProvider.overrideWithValue(service),
      ],
    );

    addTearDown(() async {
      container.dispose();
      await database.close();
    });

    final session = container.read(sessionProvider.notifier);

    expect(session.login('lerato@example.com', 'testpassword123'), isTrue);

    final accountId = container.read(sessionProvider)!.id;
    const otherAccountId = 'other-account';

    await cache.save(
      accountId: accountId,
      stokvels: [
        const CachedHomeStokvel(
          id: 'my-stokvel',
          name: 'My Club',
          role: 'Member',
        ),
      ],
    );

    await cache.save(
      accountId: otherAccountId,
      stokvels: [
        const CachedHomeStokvel(
          id: 'other-stokvel',
          name: 'Other Club',
          role: 'Member',
        ),
      ],
    );

    expect(await cache.load(accountId), isNotNull);
    expect(await cache.load(otherAccountId), isNotNull);

    await session.logoutWithApi();

    expect(container.read(sessionProvider), isNull);
    expect(
      container.read(sessionLifecycleProvider),
      SessionLifecycle.signedOut,
    );

    expect(service.logoutCalls, 1);
    expect(await cache.load(accountId), isNull);

    final otherCache = await cache.load(otherAccountId);
    expect(otherCache, isNotNull);
    expect(otherCache!.stokvels.single.id, 'other-stokvel');
  });
  test('API logout clears only its own pending payment intents', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final cache = HomeCacheRepository(database);
    final service = FakeLogoutService();

    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        apiSessionServiceProvider.overrideWithValue(service),
      ],
    );

    addTearDown(() async {
      container.dispose();
      await database.close();
    });

    final session = container.read(sessionProvider.notifier);

    expect(session.login('lerato@example.com', 'testpassword123'), isTrue);

    final accountId = container.read(sessionProvider)!.id;

    await cache.save(
      accountId: accountId,
      stokvels: [
        const CachedHomeStokvel(
          id: 'stokvel-1',
          name: 'Savings Club',
          role: 'Member',
        ),
      ],
    );

    await database
        .into(database.pendingPaymentIntents)
        .insert(
          PendingPaymentIntentsCompanion.insert(
            intentId: 'intent-logout-1',
            accountId: accountId,
            stokvelId: 'stokvel-1',
            cycleId: 'cycle-1',
            memberId: accountId,
            amountInCents: 125050,
            idempotencyKey: 'logout-preserved-key-1',
            createdAtUtc: DateTime.utc(2026, 11, 18),
          ),
        );

    await database
        .into(database.pendingPaymentIntents)
        .insert(
          PendingPaymentIntentsCompanion.insert(
            intentId: 'other-payment-intent',
            accountId: 'other-payment-account',
            stokvelId: 'other-stokvel',
            cycleId: 'other-cycle',
            memberId: 'other-payment-account',
            amountInCents: 75000,
            idempotencyKey: 'other-payment-key',
            createdAtUtc: DateTime.utc(2026, 11, 18),
          ),
        );

    await session.logoutWithApi();

    expect(container.read(sessionProvider), isNull);
    expect(await cache.load(accountId), isNull);
    expect(service.logoutCalls, 1);

    final payments = await database
        .select(database.pendingPaymentIntents)
        .get();

    expect(payments, hasLength(1));
    expect(payments.single.accountId, 'other-payment-account');
    expect(payments.single.intentId, 'other-payment-intent');
    expect(payments.single.amountInCents, 75000);
    expect(payments.single.idempotencyKey, 'other-payment-key');
    expect(payments.single.status, 'pending');
  });
  test('backend logout failure leaves local session signed out', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final cache = HomeCacheRepository(database);
    final service = FakeLogoutService()..failLogout = true;

    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        apiSessionServiceProvider.overrideWithValue(service),
      ],
    );

    addTearDown(() async {
      container.dispose();
      await database.close();
    });

    final session = container.read(sessionProvider.notifier);

    expect(session.login('lerato@example.com', 'testpassword123'), isTrue);

    final accountId = container.read(sessionProvider)!.id;

    await cache.save(
      accountId: accountId,
      stokvels: [
        const CachedHomeStokvel(
          id: 'private-stokvel',
          name: 'Private Club',
          role: 'Member',
        ),
      ],
    );

    await expectLater(session.logoutWithApi(), throwsA(isA<DioException>()));

    expect(container.read(sessionProvider), isNull);
    expect(
      container.read(sessionLifecycleProvider),
      SessionLifecycle.signedOut,
    );
    expect(service.logoutCalls, 1);
    expect(await cache.load(accountId), isNull);
  });
  test('late logout completion does not sign out a newer session', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final cache = HomeCacheRepository(database);
    final service = FakeLogoutService()..pendingLogout = Completer<void>();

    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        apiSessionServiceProvider.overrideWithValue(service),
      ],
    );

    addTearDown(() async {
      container.dispose();
      await database.close();
    });

    final session = container.read(sessionProvider.notifier);

    expect(session.login('lerato@example.com', 'testpassword123'), isTrue);

    final firstAccountId = container.read(sessionProvider)!.id;

    await cache.save(
      accountId: firstAccountId,
      stokvels: [
        const CachedHomeStokvel(
          id: 'first-stokvel',
          name: 'First Club',
          role: 'Member',
        ),
      ],
    );

    final logoutFuture = session.logoutWithApi();

    // The old session must be invalidated immediately.
    expect(container.read(sessionProvider), isNull);

    // Allow the old logout to reach the delayed backend operation.
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(service.logoutCalls, 1);

    expect(session.login('thabo@example.com', 'testpassword123'), isTrue);

    final secondAccountId = container.read(sessionProvider)!.id;

    expect(secondAccountId, isNot(firstAccountId));

    await cache.save(
      accountId: secondAccountId,
      stokvels: [
        const CachedHomeStokvel(
          id: 'second-stokvel',
          name: 'Second Club',
          role: 'Member',
        ),
      ],
    );

    service.pendingLogout!.complete();

    await logoutFuture;

    expect(container.read(sessionProvider)?.id, secondAccountId);
    expect(container.read(sessionLifecycleProvider), SessionLifecycle.signedIn);

    expect(await cache.load(firstAccountId), isNull);

    final secondCache = await cache.load(secondAccountId);

    expect(secondCache, isNotNull);
    expect(secondCache!.stokvels.single.id, 'second-stokvel');
  });
}
