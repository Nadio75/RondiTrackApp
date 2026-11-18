import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/core/network/api_auth_client.dart';
import 'package:ronditrack/features/session/data/api_session_service.dart';

class RecordingAdapter implements HttpClientAdapter {
  RecordingAdapter({this.refreshStatus = 200});

  final int refreshStatus;
  final requests = <String>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add('${options.method} ${options.path}');

    if (options.path == '/api/v1/auth/refresh' && refreshStatus != 200) {
      return ResponseBody.fromString(
        '{"error":"Refresh rejected"}',
        refreshStatus,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      );
    }
    if (options.path == '/api/v1/auth/login' ||
        options.path == '/api/v1/auth/refresh') {
      return ResponseBody.fromString(
        jsonEncode({
          'accessToken': 'test-access-token',
          'tokenType': 'Bearer',
          'expiresIn': 900,
        }),
        200,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      );
    }

    if (options.path == '/api/v1/me') {
      return ResponseBody.fromString(
        jsonEncode({
          'id': 'backend-user-123',
          'name': 'Backend User',
          'email': 'backend@example.com',
        }),
        200,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      );
    }

    return ResponseBody.fromString('', 404);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('HTTP 401 prevents session restoration', () async {
    final adapter = RecordingAdapter(refreshStatus: 401);

    final dio = Dio(BaseOptions(baseUrl: 'https://localhost:7051'))
      ..httpClientAdapter = adapter;

    final auth = ApiAuthClient(dio);
    final service = ApiSessionService(auth: auth, dio: dio);

    try {
      await expectLater(
        service.restore(),
        throwsA(
          isA<DioException>().having(
            (error) => error.response?.statusCode,
            'status code',
            401,
          ),
        ),
      );

      expect(auth.isAuthenticated, isFalse);
      expect(adapter.requests, ['POST /api/v1/auth/refresh']);
    } finally {
      dio.close(force: true);
    }
  });

  test('HTTP 500 allows restoration retry', () async {
    final adapter = RecordingAdapter(refreshStatus: 500);

    final dio = Dio(BaseOptions(baseUrl: 'https://localhost:7051'))
      ..httpClientAdapter = adapter;

    final auth = ApiAuthClient(dio);
    final service = ApiSessionService(auth: auth, dio: dio);

    try {
      await expectLater(
        service.restore(),
        throwsA(
          isA<DioException>().having(
            (error) => error.response?.statusCode,
            'status code',
            500,
          ),
        ),
      );

      expect(auth.isAuthenticated, isFalse);
      expect(adapter.requests, ['POST /api/v1/auth/refresh']);
    } finally {
      dio.close(force: true);
    }
  });

  test('restore returns the backend profile', () async {
    final adapter = RecordingAdapter();

    final dio = Dio(BaseOptions(baseUrl: 'https://localhost:7051'))
      ..httpClientAdapter = adapter;

    final auth = ApiAuthClient(dio);
    final service = ApiSessionService(auth: auth, dio: dio);

    try {
      final user = await service.restore();

      expect(user.id, 'backend-user-123');
      expect(user.name, 'Backend User');
      expect(user.email, 'backend@example.com');
      expect(auth.isAuthenticated, isTrue);

      expect(adapter.requests, ['POST /api/v1/auth/refresh', 'GET /api/v1/me']);
    } finally {
      dio.close(force: true);
    }
  });

  test('login returns the real backend profile', () async {
    final adapter = RecordingAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://localhost:7051'));
    dio.httpClientAdapter = adapter;

    final auth = ApiAuthClient(dio);
    final service = ApiSessionService(auth: auth, dio: dio);

    final user = await service.login(
      email: 'backend@example.com',
      password: 'test-password',
    );

    expect(user.id, 'backend-user-123');
    expect(user.name, 'Backend User');
    expect(user.email, 'backend@example.com');
    expect(auth.isAuthenticated, isTrue);

    expect(adapter.requests, ['POST /api/v1/auth/login', 'GET /api/v1/me']);

    dio.close(force: true);
  });
}
