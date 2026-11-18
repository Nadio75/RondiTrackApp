import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/core/auth/refresh_token_store.dart';
import 'package:ronditrack/core/network/native_refresh_cookie_interceptor.dart';

class DelayedLogoutReadStore implements RefreshTokenStore {
  String? token = 'old-refresh-token';

  final readStarted = Completer<void>();
  final releaseRead = Completer<void>();

  bool delayNextRead = true;

  @override
  Future<String?> read() async {
    final captured = token;

    if (delayNextRead) {
      delayNextRead = false;
      readStarted.complete();
      await releaseRead.future;
    }

    return captured;
  }

  @override
  Future<void> write(String value) async {
    token = value;
  }

  @override
  Future<void> clear() async {
    token = null;
  }
}

class NewLoginAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.uri.path == '/api/v1/auth/login') {
      return ResponseBody.fromString(
        jsonEncode({
          'accessToken': 'new-access-token',
          'tokenType': 'Bearer',
          'expiresIn': 900,
        }),
        200,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
          'set-cookie': [
            'ronditrack_refresh=new-refresh-token; Path=/api/v1/auth; HttpOnly',
          ],
        },
      );
    }

    return ResponseBody.fromString('', 204);
  }
}

void main() {
  test('old native logout cannot clear newer login refresh token', () async {
    final store = DelayedLogoutReadStore();
    final adapter = NewLoginAdapter();

    final dio = Dio(BaseOptions(baseUrl: 'https://localhost:7051'))
      ..httpClientAdapter = adapter;

    addTearDown(() => dio.close(force: true));

    final interceptor = NativeRefreshCookieInterceptor(
      store: store,
      apiBaseUrl: 'https://localhost:7051',
    );

    dio.interceptors.add(interceptor);

    final oldLogout = interceptor.prepareLogout();

    await store.readStarted.future.timeout(const Duration(seconds: 5));

    // A newer login completes while the old logout read is delayed.
    final newLogin = dio.post('/api/v1/auth/login');

    // Release the old logout operation.
    store.releaseRead.complete();

    await oldLogout.timeout(const Duration(seconds: 5));
    await newLogin.timeout(const Duration(seconds: 5));

    expect(store.token, 'new-refresh-token');
  });
}
