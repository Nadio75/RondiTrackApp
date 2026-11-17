import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/core/network/api_auth_client.dart';

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

void main() {
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
