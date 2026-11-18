import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ronditrack/core/network/api_auth_client.dart';
import 'package:ronditrack/features/session/data/api_session_provider.dart';
import 'package:ronditrack/features/session/data/api_session_service.dart';
import 'package:ronditrack/features/session/data/demo_users.dart';
import 'package:ronditrack/features/session/presentation/session_lifecycle.dart';
import 'package:ronditrack/features/session/presentation/session_lifecycle_provider.dart';
import 'package:ronditrack/features/session/presentation/session_provider.dart';

class ControlledSessionService extends ApiSessionService {
  ControlledSessionService() : super(auth: ApiAuthClient(Dio()), dio: Dio());

  final pendingRestore = Completer<DemoUser>();

  @override
  Future<DemoUser> restore() => pendingRestore.future;
}

void main() {
  test('temporary restoration failure allows retry', () async {
    final service = ControlledSessionService();

    final container = ProviderContainer(
      overrides: [apiSessionServiceProvider.overrideWithValue(service)],
    );
    addTearDown(container.dispose);

    final notifier = container.read(sessionProvider.notifier);

    final restoring = notifier.restoreWithApi();

    service.pendingRestore.completeError(
      DioException(
        requestOptions: RequestOptions(path: '/api/v1/auth/refresh'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/auth/refresh'),
          statusCode: 500,
        ),
        type: DioExceptionType.badResponse,
      ),
    );

    await restoring;

    expect(container.read(sessionProvider), isNull);
    expect(
      container.read(sessionLifecycleProvider),
      SessionLifecycle.retryRequired,
    );
  });

  test('successful restoration signs in the backend user', () async {
    final service = ControlledSessionService();

    final container = ProviderContainer(
      overrides: [apiSessionServiceProvider.overrideWithValue(service)],
    );
    addTearDown(container.dispose);

    final notifier = container.read(sessionProvider.notifier);

    final restoring = notifier.restoreWithApi();

    expect(
      container.read(sessionLifecycleProvider),
      SessionLifecycle.restoring,
    );

    service.pendingRestore.complete(
      DemoUser(
        id: 'restored-user',
        name: 'Restored User',
        email: 'restored@example.com',
      ),
    );

    await restoring;

    expect(container.read(sessionProvider)?.id, 'restored-user');
    expect(container.read(sessionLifecycleProvider), SessionLifecycle.signedIn);
  });

  test('late restoration cannot sign in after logout', () async {
    final service = ControlledSessionService();

    final container = ProviderContainer(
      overrides: [apiSessionServiceProvider.overrideWithValue(service)],
    );
    addTearDown(container.dispose);

    final notifier = container.read(sessionProvider.notifier);

    final restoring = notifier.restoreWithApi();

    notifier.logout();

    service.pendingRestore.complete(
      DemoUser(
        id: 'stale-user',
        name: 'Stale User',
        email: 'stale@example.com',
      ),
    );

    await restoring;

    expect(container.read(sessionProvider), isNull);
    expect(
      container.read(sessionLifecycleProvider),
      SessionLifecycle.signedOut,
    );
  });
}
