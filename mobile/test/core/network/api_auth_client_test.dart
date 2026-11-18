import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/core/network/api_auth_client.dart';
import 'package:ronditrack/core/auth/refresh_token_store.dart';
import 'package:ronditrack/core/network/native_refresh_cookie_interceptor.dart';

class FakeAuthAdapter implements HttpClientAdapter {
  FakeAuthAdapter({this.validResponse = true});

  final bool validResponse;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final path = options.path;

    if (path.endsWith('/logout')) {
      return ResponseBody.fromString('', 204);
    }

    final body = validResponse
        ? {'accessToken': 'test-token', 'tokenType': 'Bearer', 'expiresIn': 900}
        : {'accessToken': '', 'tokenType': 'Bearer', 'expiresIn': 0};

    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }
}

class CountingRefreshAdapter implements HttpClientAdapter {
  int refreshCalls = 0;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    refreshCalls++;

    await Future<void>.delayed(const Duration(milliseconds: 30));

    return ResponseBody.fromString(
      jsonEncode({
        'accessToken': 'refreshed-token',
        'tokenType': 'Bearer',
        'expiresIn': 900,
      }),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }
}

class ControlledRefreshAdapter implements HttpClientAdapter {
  final Completer<ResponseBody> refreshResponse = Completer<ResponseBody>();

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    if (options.path.endsWith('/refresh')) {
      return refreshResponse.future;
    }

    if (options.path.endsWith('/logout')) {
      return Future.value(ResponseBody.fromString('', 204));
    }

    return Future.value(
      ResponseBody.fromString(
        jsonEncode({
          'accessToken': 'initial-token',
          'tokenType': 'Bearer',
          'expiresIn': 900,
        }),
        200,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      ),
    );
  }
}

class OfflineLogoutAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path.endsWith('/logout')) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
        error: 'Simulated offline connection',
      );
    }

    return ResponseBody.fromString(
      jsonEncode({
        'accessToken': 'active-token',
        'tokenType': 'Bearer',
        'expiresIn': 900,
      }),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }
}

class LogoutVerificationAdapter implements HttpClientAdapter {
  LogoutVerificationAdapter(this.store);

  final RefreshTokenStore store;

  bool storageWasEmptyAtLogout = false;
  String? receivedCookie;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.uri.path == '/api/v1/auth/logout') {
      storageWasEmptyAtLogout = await store.read() == null;
      receivedCookie = options.headers['Cookie']?.toString();

      return ResponseBody.fromString('', 204);
    }

    return ResponseBody.fromString(
      jsonEncode({
        'accessToken': 'initial-token',
        'tokenType': 'Bearer',
        'expiresIn': 900,
      }),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }
}

class ServerErrorRefreshAdapter implements HttpClientAdapter {
  ServerErrorRefreshAdapter({this.refreshStatus = 500});

  final int? refreshStatus;
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.uri.path == '/api/v1/auth/refresh') {
      if (refreshStatus == null) {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: 'Simulated offline connection',
        );
      }

      return ResponseBody.fromString(
        '{"error":"Temporary server failure"}',
        refreshStatus!,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      );
    }

    return ResponseBody.fromString(
      jsonEncode({
        'accessToken': 'existing-access-token',
        'tokenType': 'Bearer',
        'expiresIn': 900,
      }),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }
}

void main() {
  for (final status in <int?>[403, 429, null]) {
    test('refresh failure $status preserves existing access token', () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://localhost:7051'))
        ..httpClientAdapter = ServerErrorRefreshAdapter(refreshStatus: status);

      final auth = ApiAuthClient(dio);

      try {
        await auth.login(
          email: 'test@example.com',
          password: 'example-password',
        );

        expect(auth.accessToken, 'existing-access-token');

        await expectLater(
          auth.refresh(),
          throwsA(
            isA<DioException>().having(
              (error) => error.response?.statusCode,
              'status code',
              status,
            ),
          ),
        );

        expect(auth.accessToken, 'existing-access-token');
        expect(auth.isAuthenticated, isTrue);
      } finally {
        dio.close(force: true);
      }
    });
  }

  test('HTTP 500 refresh failure preserves existing access token', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://localhost:7051'))
      ..httpClientAdapter = ServerErrorRefreshAdapter();

    final auth = ApiAuthClient(dio);

    try {
      await auth.login(email: 'test@example.com', password: 'example-password');

      expect(auth.accessToken, 'existing-access-token');

      await expectLater(
        auth.refresh(),
        throwsA(
          isA<DioException>().having(
            (error) => error.response?.statusCode,
            'status code',
            500,
          ),
        ),
      );

      expect(auth.accessToken, 'existing-access-token');
      expect(auth.isAuthenticated, isTrue);
    } finally {
      dio.close(force: true);
    }
  });

  test('ApiAuthClient clears native storage before backend logout', () async {
    final store = MemoryRefreshTokenStore();
    await store.write('credential-to-revoke');

    final adapter = LogoutVerificationAdapter(store);

    final dio = Dio(BaseOptions(baseUrl: 'https://localhost:7051'))
      ..httpClientAdapter = adapter;

    final interceptor = NativeRefreshCookieInterceptor(
      store: store,
      apiBaseUrl: 'https://localhost:7051',
    );

    dio.interceptors.add(interceptor);

    final auth = ApiAuthClient(
      dio,
      prepareNativeLogout: interceptor.prepareLogout,
    );

    try {
      await auth.login(email: 'test@example.com', password: 'example-password');

      expect(auth.isAuthenticated, isTrue);

      await auth.logout();

      expect(adapter.storageWasEmptyAtLogout, isTrue);
      expect(adapter.receivedCookie, 'ronditrack_refresh=credential-to-revoke');
      expect(await store.read(), isNull);
      expect(auth.accessToken, isNull);
      expect(auth.isAuthenticated, isFalse);
    } finally {
      dio.close(force: true);
    }
  });

  test('offline logout still clears the local access token', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:5056'))
      ..httpClientAdapter = OfflineLogoutAdapter();

    final auth = ApiAuthClient(dio);

    await auth.login(email: 'test@example.com', password: 'example-password');

    expect(auth.isAuthenticated, isTrue);

    await auth.logout();

    expect(auth.accessToken, isNull);
    expect(auth.isAuthenticated, isFalse);

    dio.close(force: true);
  });

  test('late refresh cannot restore logged-out session', () async {
    final adapter = ControlledRefreshAdapter();

    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:5056'))
      ..httpClientAdapter = adapter;

    final auth = ApiAuthClient(dio);

    await auth.login(email: 'test@example.com', password: 'example-password');

    final refreshFuture = auth.refresh();

    await auth.logout();

    adapter.refreshResponse.complete(
      ResponseBody.fromString(
        jsonEncode({
          'accessToken': 'late-token',
          'tokenType': 'Bearer',
          'expiresIn': 900,
        }),
        200,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      ),
    );

    await refreshFuture;

    expect(auth.accessToken, isNull);
    expect(auth.isAuthenticated, isFalse);
  });

  test('failed refresh clears existing access token', () async {
    final adapter = ControlledRefreshAdapter();

    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:5056'))
      ..httpClientAdapter = adapter;

    final auth = ApiAuthClient(dio);

    await auth.login(email: 'test@example.com', password: 'example-password');

    expect(auth.accessToken, 'initial-token');

    final refreshFuture = auth.refresh();

    adapter.refreshResponse.complete(
      ResponseBody.fromString(
        '{"title":"Unauthorized"}',
        401,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      ),
    );

    await expectLater(refreshFuture, throwsA(isA<DioException>()));

    expect(auth.accessToken, isNull);
    expect(auth.isAuthenticated, isFalse);
  });
  test('concurrent refresh calls share one request', () async {
    final adapter = CountingRefreshAdapter();

    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:5056'))
      ..httpClientAdapter = adapter;

    final auth = ApiAuthClient(dio);

    await Future.wait([auth.refresh(), auth.refresh()]);

    expect(adapter.refreshCalls, 1);
    expect(auth.accessToken, 'refreshed-token');
  });
  test('login stores access token in memory', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:5056'))
      ..httpClientAdapter = FakeAuthAdapter();

    final auth = ApiAuthClient(dio);

    await auth.login(email: 'test@example.com', password: 'example-password');

    expect(auth.accessToken, 'test-token');
    expect(auth.isAuthenticated, isTrue);
  });

  test('refresh updates access token', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:5056'))
      ..httpClientAdapter = FakeAuthAdapter();

    final auth = ApiAuthClient(dio);

    await auth.refresh();

    expect(auth.accessToken, 'test-token');
  });

  test('invalid response is rejected', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:5056'))
      ..httpClientAdapter = FakeAuthAdapter(validResponse: false);

    final auth = ApiAuthClient(dio);

    await expectLater(auth.refresh(), throwsFormatException);

    expect(auth.isAuthenticated, isFalse);
  });

  test('logout clears access token', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:5056'))
      ..httpClientAdapter = FakeAuthAdapter();

    final auth = ApiAuthClient(dio);

    await auth.login(email: 'test@example.com', password: 'example-password');

    await auth.logout();

    expect(auth.accessToken, isNull);
    expect(auth.isAuthenticated, isFalse);
  });
}
