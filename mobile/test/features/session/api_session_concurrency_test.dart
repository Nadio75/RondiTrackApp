import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/core/network/api_auth_client.dart';
import 'package:ronditrack/features/session/data/api_session_service.dart';

class ControlledProfileAdapter implements HttpClientAdapter {
  final firstProfile = Completer<ResponseBody>();
  int profileCalls = 0;
  int logoutCalls = 0;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    if (options.path == '/api/v1/auth/login') {
      final email = (options.data as Map)['email'];

      return Future.value(
        ResponseBody.fromString(
          jsonEncode({
            'accessToken': 'token-$email',
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

    if (options.path == '/api/v1/me') {
      profileCalls++;

      if (profileCalls == 1) {
        return firstProfile.future;
      }

      return Future.value(
        ResponseBody.fromString(
          jsonEncode({
            'id': 'new-user',
            'name': 'New User',
            'email': 'new@example.com',
          }),
          200,
          headers: {
            Headers.contentTypeHeader: ['application/json'],
          },
        ),
      );
    }

    if (options.path == '/api/v1/auth/logout') {
      logoutCalls++;
      return Future.value(ResponseBody.fromString('', 204));
    }

    return Future.value(ResponseBody.fromString('', 404));
  }
}

void main() {
  test('old profile failure cannot clear newer login credentials', () async {
    final adapter = ControlledProfileAdapter();

    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:5056'))
      ..httpClientAdapter = adapter;

    addTearDown(() => dio.close(force: true));

    final auth = ApiAuthClient(dio);
    final service = ApiSessionService(auth: auth, dio: dio);

    final oldLogin = service.login(
      email: 'old@example.com',
      password: 'test-password',
    );

    // Wait until the first profile request is pending.
    while (adapter.profileCalls == 0) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }

    final newUser = await service.login(
      email: 'new@example.com',
      password: 'test-password',
    );

    expect(newUser.id, 'new-user');
    expect(auth.accessToken, 'token-new@example.com');

    // Complete the old profile request with a server error.
    adapter.firstProfile.complete(
      ResponseBody.fromString(
        '{"error":"Temporary failure"}',
        500,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      ),
    );

    await expectLater(oldLogin, throwsA(isA<DioException>()));

    // The old request must not destroy the new session.
    expect(auth.accessToken, 'token-new@example.com');
    expect(auth.isAuthenticated, isTrue);
    expect(adapter.logoutCalls, 0);
  });
  test('current profile failure clears its own credentials', () async {
    final adapter = ControlledProfileAdapter();

    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:5056'))
      ..httpClientAdapter = adapter;

    addTearDown(() => dio.close(force: true));

    final auth = ApiAuthClient(dio);
    final service = ApiSessionService(auth: auth, dio: dio);

    final loginFuture = service.login(
      email: 'failed@example.com',
      password: 'test-password',
    );

    // Wait for the current login's profile request.
    while (adapter.profileCalls == 0) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }

    expect(auth.accessToken, 'token-failed@example.com');

    adapter.firstProfile.complete(
      ResponseBody.fromString(
        '{"error":"Profile unavailable"}',
        500,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      ),
    );

    await expectLater(loginFuture, throwsA(isA<DioException>()));

    expect(auth.accessToken, isNull);
    expect(auth.isAuthenticated, isFalse);
    expect(adapter.logoutCalls, 1);
  });
}
