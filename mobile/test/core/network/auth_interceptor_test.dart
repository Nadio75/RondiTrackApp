import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/core/network/api_auth_client.dart';
import 'package:ronditrack/core/network/auth_interceptor.dart';

class RecordingAdapter implements HttpClientAdapter {
  String? lastAuthorization;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastAuthorization = options.headers['Authorization']?.toString();

    if (options.path.endsWith('/login') || options.path.endsWith('/refresh')) {
      return ResponseBody.fromString(
        jsonEncode({
          'accessToken': 'test-token',
          'tokenType': 'Bearer',
          'expiresIn': 900,
        }),
        200,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      );
    }

    return ResponseBody.fromString(
      '{}',
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }
}

void main() {
  test('attaches token to authenticated API requests', () async {
    final adapter = RecordingAdapter();

    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:5056'))
      ..httpClientAdapter = adapter;

    final auth = ApiAuthClient(dio);

    dio.interceptors.add(AuthInterceptor(auth));

    await auth.login(email: 'test@example.com', password: 'example-password');

    expect(adapter.lastAuthorization, isNull);

    await dio.get<dynamic>('/api/v1/me');

    expect(adapter.lastAuthorization, 'Bearer test-token');
  });

  test('does not attach token before login', () async {
    final adapter = RecordingAdapter();

    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:5056'))
      ..httpClientAdapter = adapter;

    final auth = ApiAuthClient(dio);

    dio.interceptors.add(AuthInterceptor(auth));

    await dio.get<dynamic>('/api/v1/me');

    expect(adapter.lastAuthorization, isNull);
  });

  test('does not attach token to refresh', () async {
    final adapter = RecordingAdapter();

    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:5056'))
      ..httpClientAdapter = adapter;

    final auth = ApiAuthClient(dio);

    dio.interceptors.add(AuthInterceptor(auth));

    await auth.login(email: 'test@example.com', password: 'example-password');

    await auth.refresh();

    expect(adapter.lastAuthorization, isNull);
  });
  test('logout clears authorization on subsequent requests', () async {
    final adapter = RecordingAdapter();

    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:5056'))
      ..httpClientAdapter = adapter;

    final auth = ApiAuthClient(dio);

    dio.interceptors.add(AuthInterceptor(auth));

    await auth.login(email: 'test@example.com', password: 'example-password');

    await dio.get<dynamic>('/api/v1/me');
    expect(adapter.lastAuthorization, 'Bearer test-token');

    await auth.logout();
    expect(auth.accessToken, isNull);
    expect(adapter.lastAuthorization, isNull);

    await dio.get<dynamic>('/api/v1/me');
    expect(adapter.lastAuthorization, isNull);
  });

  test('does not send Bearer token to external origin', () async {
    final adapter = RecordingAdapter();

    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:5056'))
      ..httpClientAdapter = adapter;

    final auth = ApiAuthClient(dio);
    dio.interceptors.add(AuthInterceptor(auth));

    await auth.login(email: 'test@example.com', password: 'example-password');

    await dio.get<dynamic>('https://example.com/api/v1/me');

    expect(adapter.lastAuthorization, isNull);
  });

  test('sends Bearer token to configured API origin', () async {
    final adapter = RecordingAdapter();

    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:5056'))
      ..httpClientAdapter = adapter;

    final auth = ApiAuthClient(dio);
    dio.interceptors.add(AuthInterceptor(auth));

    await auth.login(email: 'test@example.com', password: 'example-password');

    await dio.get<dynamic>('http://localhost:5056/api/v1/me');

    expect(adapter.lastAuthorization, 'Bearer test-token');
  });
}
