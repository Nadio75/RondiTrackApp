import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/core/network/api_auth_client.dart';
import 'package:ronditrack/features/session/data/api_session_service.dart';

class RecordingAdapter implements HttpClientAdapter {
  final requests = <String>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add('${options.method} ${options.path}');

    if (options.path == '/api/v1/auth/login') {
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
