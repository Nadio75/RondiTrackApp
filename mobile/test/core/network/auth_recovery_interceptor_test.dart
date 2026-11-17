import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/core/network/api_auth_client.dart';
import 'package:ronditrack/core/network/auth_interceptor.dart';
import 'package:ronditrack/core/network/auth_recovery_interceptor.dart';

class RecoveryAdapter implements HttpClientAdapter {
  RecoveryAdapter({this.refreshFails = false, this.alwaysUnauthorized = false});

  final bool refreshFails;
  final bool alwaysUnauthorized;

  int refreshCalls = 0;
  int getCalls = 0;
  int postCalls = 0;
  final List<String?> getAuthorizations = [];

  @override
  void close({bool force = false}) {}

  ResponseBody jsonResponse(Object body, int status) {
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final path = options.uri.path;

    if (path == '/api/v1/auth/login') {
      return jsonResponse({
        'accessToken': 'old-token',
        'tokenType': 'Bearer',
        'expiresIn': 900,
      }, 200);
    }

    if (path == '/api/v1/auth/refresh') {
      refreshCalls++;

      if (refreshFails) {
        return jsonResponse({'title': 'Unauthorized'}, 401);
      }

      return jsonResponse({
        'accessToken': 'new-token',
        'tokenType': 'Bearer',
        'expiresIn': 900,
      }, 200);
    }

    if (path == '/api/v1/me' && options.method == 'GET') {
      getCalls++;
      final authorization = options.headers['Authorization']?.toString();
      getAuthorizations.add(authorization);

      if (!alwaysUnauthorized && authorization == 'Bearer new-token') {
        return jsonResponse({'id': 'user-1'}, 200);
      }

      return jsonResponse({'title': 'Unauthorized'}, 401);
    }

    if (path == '/api/v1/contributions' && options.method == 'POST') {
      postCalls++;
      return jsonResponse({'title': 'Unauthorized'}, 401);
    }

    return jsonResponse({'title': 'Not Found'}, 404);
  }
}

({Dio dio, ApiAuthClient auth}) createSession(RecoveryAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost:5056'))
    ..httpClientAdapter = adapter;

  final auth = ApiAuthClient(dio);

  dio.interceptors.add(AuthInterceptor(auth));
  dio.interceptors.add(AuthRecoveryInterceptor(dio, auth));

  return (dio: dio, auth: auth);
}

class ConcurrentRecoveryAdapter extends RecoveryAdapter {
  final Completer<void> refreshStarted = Completer<void>();
  final Completer<void> releaseRefresh = Completer<void>();
  final Completer<void> allInitialGets = Completer<void>();

  int initialGets = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.uri.path == '/api/v1/auth/refresh') {
      refreshCalls++;

      if (!refreshStarted.isCompleted) {
        refreshStarted.complete();
      }

      await releaseRefresh.future;

      return jsonResponse({
        'accessToken': 'new-token',
        'tokenType': 'Bearer',
        'expiresIn': 900,
      }, 200);
    }

    if (options.uri.path == '/api/v1/me' && options.method == 'GET') {
      getCalls++;

      final authorization = options.headers['Authorization']?.toString();

      getAuthorizations.add(authorization);

      if (authorization == 'Bearer old-token') {
        initialGets++;

        if (initialGets == 3) {
          allInitialGets.complete();
        }

        await allInitialGets.future;

        return jsonResponse({'title': 'Unauthorized'}, 401);
      }

      if (authorization == 'Bearer new-token') {
        return jsonResponse({'id': 'user-1'}, 200);
      }

      return jsonResponse({'title': 'Unauthorized'}, 401);
    }

    return super.fetch(options, requestStream, cancelFuture);
  }
}

class AccountSwitchAdapter extends RecoveryAdapter {
  final Completer<void> oldRequestStarted = Completer<void>();
  final Completer<void> releaseOldRequest = Completer<void>();

  int protectedGetCalls = 0;
  int loginCalls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.uri.path == '/api/v1/auth/login') {
      loginCalls++;

      return jsonResponse({
        'accessToken': loginCalls == 1 ? 'account-a' : 'account-b',
        'tokenType': 'Bearer',
        'expiresIn': 900,
      }, 200);
    }

    if (options.uri.path == '/api/v1/me' && options.method == 'GET') {
      protectedGetCalls++;

      if (protectedGetCalls == 1) {
        oldRequestStarted.complete();
        await releaseOldRequest.future;
      }

      return jsonResponse({'title': 'Unauthorized'}, 401);
    }

    return super.fetch(options, requestStream, cancelFuture);
  }
}

class LogoutDuringRecoveryAdapter extends RecoveryAdapter {
  final Completer<void> refreshStarted = Completer<void>();
  final Completer<void> releaseRefresh = Completer<void>();

  int logoutCalls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.uri.path == '/api/v1/auth/refresh') {
      refreshCalls++;

      if (!refreshStarted.isCompleted) {
        refreshStarted.complete();
      }

      await releaseRefresh.future;

      return jsonResponse({
        'accessToken': 'new-token',
        'tokenType': 'Bearer',
        'expiresIn': 900,
      }, 200);
    }

    if (options.uri.path == '/api/v1/auth/logout') {
      logoutCalls++;
      return ResponseBody.fromString('', 204);
    }

    return super.fetch(options, requestStream, cancelFuture);
  }
}

void main() {
  test('logout during recovery prevents GET replay', () async {
    final adapter = LogoutDuringRecoveryAdapter();
    final session = createSession(adapter);

    await session.auth.login(
      email: 'account-a@example.com',
      password: 'example-password',
    );

    final oldRequest = session.dio.get<dynamic>('/api/v1/me');

    final oldRequestResult = expectLater(
      oldRequest,
      throwsA(
        isA<DioException>().having(
          (error) => error.response?.statusCode,
          'status code',
          401,
        ),
      ),
    );

    await adapter.refreshStarted.future;

    await session.auth.logout();

    expect(session.auth.accessToken, isNull);
    expect(session.auth.isAuthenticated, isFalse);

    adapter.releaseRefresh.complete();

    await oldRequestResult;

    expect(adapter.refreshCalls, 1);
    expect(adapter.logoutCalls, 1);
    expect(adapter.getCalls, 1);
    expect(session.auth.accessToken, isNull);
    expect(session.auth.isAuthenticated, isFalse);
  });
  test('old account GET is not retried after new login', () async {
    final adapter = AccountSwitchAdapter();
    final session = createSession(adapter);

    await session.auth.login(
      email: 'account-a@example.com',
      password: 'example-password',
    );

    final oldRequest = session.dio.get<dynamic>('/api/v1/me');

    // Attach the error expectation immediately.
    final oldRequestResult = expectLater(
      oldRequest,
      throwsA(
        isA<DioException>().having(
          (error) => error.response?.statusCode,
          'status code',
          401,
        ),
      ),
    );

    await adapter.oldRequestStarted.future;

    await session.auth.login(
      email: 'account-b@example.com',
      password: 'example-password',
    );

    adapter.releaseOldRequest.complete();

    await oldRequestResult;

    expect(adapter.protectedGetCalls, 1);
    expect(adapter.refreshCalls, 0);
    expect(session.auth.accessToken, 'account-b');
  });
  test('concurrent GET 401 responses share one refresh', () async {
    final adapter = ConcurrentRecoveryAdapter();
    final session = createSession(adapter);

    await session.auth.login(
      email: 'test@example.com',
      password: 'example-password',
    );

    final requests = [
      session.dio.get<dynamic>('/api/v1/me'),
      session.dio.get<dynamic>('/api/v1/me'),
      session.dio.get<dynamic>('/api/v1/me'),
    ];

    await adapter.allInitialGets.future;
    await adapter.refreshStarted.future;

    adapter.releaseRefresh.complete();

    final responses = await Future.wait(requests);

    expect(responses.map((response) => response.statusCode), everyElement(200));

    expect(adapter.refreshCalls, 1);
    expect(adapter.getCalls, 6);
    expect(
      adapter.getAuthorizations
          .where((value) => value == 'Bearer old-token')
          .length,
      3,
    );
    expect(
      adapter.getAuthorizations
          .where((value) => value == 'Bearer new-token')
          .length,
      3,
    );
  });
  test('GET 401 refreshes token and retries once', () async {
    final adapter = RecoveryAdapter();
    final session = createSession(adapter);

    await session.auth.login(
      email: 'test@example.com',
      password: 'example-password',
    );

    final response = await session.dio.get<dynamic>('/api/v1/me');

    expect(response.statusCode, 200);
    expect(adapter.refreshCalls, 1);
    expect(adapter.getCalls, 2);
    expect(adapter.getAuthorizations, ['Bearer old-token', 'Bearer new-token']);
    expect(session.auth.accessToken, 'new-token');
  });

  test('failed refresh preserves original GET 401', () async {
    final adapter = RecoveryAdapter(refreshFails: true);
    final session = createSession(adapter);

    await session.auth.login(
      email: 'test@example.com',
      password: 'example-password',
    );

    await expectLater(
      session.dio.get<dynamic>('/api/v1/me'),
      throwsA(
        isA<DioException>().having(
          (error) => error.response?.statusCode,
          'status code',
          401,
        ),
      ),
    );

    expect(adapter.refreshCalls, 1);
    expect(adapter.getCalls, 1);
    expect(session.auth.accessToken, isNull);
  });

  test('POST 401 never triggers automatic replay', () async {
    final adapter = RecoveryAdapter();
    final session = createSession(adapter);

    await session.auth.login(
      email: 'test@example.com',
      password: 'example-password',
    );

    await expectLater(
      session.dio.post<dynamic>(
        '/api/v1/contributions',
        data: {'amountCents': 10000},
      ),
      throwsA(isA<DioException>()),
    );

    expect(adapter.postCalls, 1);
    expect(adapter.refreshCalls, 0);
  });

  test('repeated GET 401 stops after one retry', () async {
    final adapter = RecoveryAdapter(alwaysUnauthorized: true);
    final session = createSession(adapter);

    await session.auth.login(
      email: 'test@example.com',
      password: 'example-password',
    );

    await expectLater(
      session.dio.get<dynamic>('/api/v1/me'),
      throwsA(
        isA<DioException>().having(
          (error) => error.response?.statusCode,
          'status code',
          401,
        ),
      ),
    );

    expect(adapter.refreshCalls, 1);
    expect(adapter.getCalls, 2);
  });
}
