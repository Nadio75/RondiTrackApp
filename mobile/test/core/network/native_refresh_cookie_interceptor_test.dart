import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/core/auth/refresh_token_store.dart';
import 'package:ronditrack/core/network/native_refresh_cookie_interceptor.dart';

class RecordingHttpAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];

  Completer<void>? refreshGate;
  Completer<void>? refreshStarted;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);

    final path = options.uri.path;

    if (path == '/api/v1/auth/refresh' && refreshGate != null) {
      refreshStarted?.complete();
      await refreshGate!.future;
    }

    if (path == '/api/v1/auth/login' || path == '/api/v1/auth/refresh') {
      final token = path.endsWith('/login') ? 'first-token' : 'rotated-token';

      return ResponseBody.fromString(
        jsonEncode({'ok': true}),
        200,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
          'set-cookie': [
            'ronditrack_refresh=$token; Path=/api/v1/auth; HttpOnly; Secure',
          ],
        },
      );
    }

    return ResponseBody.fromString(
      jsonEncode({'ok': true}),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class DelayedWriteRefreshTokenStore implements RefreshTokenStore {
  String? _token;
  final Completer<void> writeStarted = Completer<void>();
  final Completer<void> allowWrite = Completer<void>();

  @override
  Future<String?> read() async => _token;

  @override
  Future<void> write(String token) async {
    if (!writeStarted.isCompleted) {
      writeStarted.complete();
    }
    await allowWrite.future;
    _token = token;
  }

  @override
  Future<void> clear() async {
    _token = null;
  }
}

class DelayedReadRefreshTokenStore implements RefreshTokenStore {
  String? _token = 'old-refresh-token';

  final Completer<void> readStarted = Completer<void>();
  final Completer<void> allowRead = Completer<void>();

  @override
  Future<String?> read() async {
    final captured = _token;

    if (!readStarted.isCompleted) {
      readStarted.complete();
    }

    await allowRead.future;
    return captured;
  }

  @override
  Future<void> write(String token) async {
    _token = token;
  }

  @override
  Future<void> clear() async {
    _token = null;
  }

  String? get currentToken => _token;
}

void main() {
  test('pending refresh read cannot attach a cookie after logout', () async {
    final store = DelayedReadRefreshTokenStore();
    final adapter = RecordingHttpAdapter();

    final dio = Dio(BaseOptions(baseUrl: 'https://localhost:7051'))
      ..httpClientAdapter = adapter;

    final interceptor = NativeRefreshCookieInterceptor(
      store: store,
      apiBaseUrl: 'https://localhost:7051',
    );

    dio.interceptors.add(interceptor);

    try {
      final pendingRefresh = dio.post('/api/v1/auth/refresh');

      await store.readStarted.future.timeout(const Duration(seconds: 5));

      // Logout invalidates the session while the read is paused.
      final pendingLogout = interceptor.prepareLogout();

      // Release the old read after logout has started.
      store.allowRead.complete();

      await pendingRefresh.timeout(const Duration(seconds: 5));

      final refreshRequest = adapter.requests.single;

      expect(
        refreshRequest.headers.keys.any((key) => key.toLowerCase() == 'cookie'),
        isFalse,
      );

      await pendingLogout.timeout(const Duration(seconds: 5));

      expect(store.currentToken, isNull);
    } finally {
      if (!store.allowRead.isCompleted) {
        store.allowRead.complete();
      }
      dio.close(force: true);
    }
  });

  test('logout clears a delayed Dio refresh-token write', () async {
    final store = DelayedWriteRefreshTokenStore();
    final adapter = RecordingHttpAdapter();

    final dio = Dio(BaseOptions(baseUrl: 'https://localhost:7051'))
      ..httpClientAdapter = adapter;

    final interceptor = NativeRefreshCookieInterceptor(
      store: store,
      apiBaseUrl: 'https://localhost:7051',
    );

    dio.interceptors.add(interceptor);

    try {
      final pendingRefresh = dio.post('/api/v1/auth/refresh');

      await store.writeStarted.future.timeout(const Duration(seconds: 5));

      final logoutFuture = interceptor.prepareLogout();

      // Allow the refresh response's storage write to finish.
      store.allowWrite.complete();

      await pendingRefresh.timeout(const Duration(seconds: 5));
      await logoutFuture.timeout(const Duration(seconds: 5));

      expect(await store.read(), isNull);
    } finally {
      dio.close(force: true);
    }
  });
  test(
    'logout revocation uses a captured credential after local clearing',
    () async {
      final store = MemoryRefreshTokenStore();
      await store.write('token-to-revoke');

      final adapter = RecordingHttpAdapter();

      final dio = Dio(BaseOptions(baseUrl: 'https://localhost:7051'))
        ..httpClientAdapter = adapter;

      final interceptor = NativeRefreshCookieInterceptor(
        store: store,
        apiBaseUrl: 'https://localhost:7051',
      );

      dio.interceptors.add(interceptor);

      try {
        final captured = await interceptor.prepareLogout();

        expect(captured, 'token-to-revoke');
        expect(await store.read(), isNull);

        await dio.post(
          '/api/v1/auth/logout',
          options: Options(extra: {'nativeLogoutToken': captured}),
        );

        expect(await store.read(), isNull);
        expect(
          adapter.requests.single.headers['Cookie'],
          'ronditrack_refresh=token-to-revoke',
        );
      } finally {
        dio.close(force: true);
      }
    },
  );
  test('captured logout token never reaches an untrusted origin', () async {
    final store = MemoryRefreshTokenStore();
    final adapter = RecordingHttpAdapter();

    final dio = Dio(BaseOptions(baseUrl: 'https://localhost:7051'))
      ..httpClientAdapter = adapter;

    dio.interceptors.add(
      NativeRefreshCookieInterceptor(
        store: store,
        apiBaseUrl: 'https://localhost:7051',
      ),
    );

    try {
      await dio.post(
        'https://untrusted.example/api/v1/auth/logout',
        options: Options(
          extra: {'nativeLogoutToken': 'secret-logout-token'},
          headers: {'Cookie': 'injected-cookie'},
        ),
      );

      final headers = adapter.requests.single.headers;

      expect(headers.keys.any((key) => key.toLowerCase() == 'cookie'), isFalse);
    } finally {
      dio.close(force: true);
    }
  });
  test('prepareLogout captures and clears the stored credential', () async {
    final store = MemoryRefreshTokenStore();
    await store.write('refresh-before-logout');

    final interceptor = NativeRefreshCookieInterceptor(
      store: store,
      apiBaseUrl: 'http://localhost:5056',
    );

    final captured = await interceptor.prepareLogout();

    expect(captured, 'refresh-before-logout');
    expect(await store.read(), isNull);
  });

  const baseUrl = 'https://localhost:7051';

  late Dio dio;
  late MemoryRefreshTokenStore store;
  late RecordingHttpAdapter adapter;

  setUp(() {
    store = MemoryRefreshTokenStore();
    adapter = RecordingHttpAdapter();

    dio = Dio(BaseOptions(baseUrl: baseUrl));
    dio.httpClientAdapter = adapter;

    dio.interceptors.add(
      NativeRefreshCookieInterceptor(store: store, apiBaseUrl: baseUrl),
    );
  });

  tearDown(() {
    dio.close(force: true);
  });

  test('login response stores the refresh cookie', () async {
    await dio.post('/api/v1/auth/login');

    expect(await store.read(), 'first-token');
  });

  test('refresh sends the stored cookie', () async {
    await store.write('existing-token');

    await dio.post('/api/v1/auth/refresh');

    expect(
      adapter.requests.single.headers['Cookie'],
      'ronditrack_refresh=existing-token',
    );
  });

  test('refresh response rotates the stored token', () async {
    await store.write('old-token');

    await dio.post('/api/v1/auth/refresh');

    expect(await store.read(), 'rotated-token');
  });

  test('ordinary API requests never receive the refresh cookie', () async {
    await store.write('private-token');

    await dio.get(
      '/api/v1/me',
      options: Options(headers: {'Cookie': 'injected-cookie'}),
    );

    final headers = adapter.requests.single.headers;

    expect(headers.keys.any((key) => key.toLowerCase() == 'cookie'), isFalse);
  });

  test('logout receives the stored refresh cookie', () async {
    await store.write('logout-token');

    await dio.post('/api/v1/auth/logout');

    expect(
      adapter.requests.single.headers['Cookie'],
      'ronditrack_refresh=logout-token',
    );
  });

  test('late refresh response cannot restore an invalidated session', () async {
    await store.write('old-refresh-token');

    adapter.refreshGate = Completer<void>();
    adapter.refreshStarted = Completer<void>();

    final pendingRefresh = dio.post('/api/v1/auth/refresh');

    await adapter.refreshStarted!.future.timeout(const Duration(seconds: 5));

    final cookieInterceptor = dio.interceptors
        .whereType<NativeRefreshCookieInterceptor>()
        .single;

    cookieInterceptor.invalidateSession();

    await store.clear();

    adapter.refreshGate!.complete();

    await pendingRefresh.timeout(const Duration(seconds: 5));

    expect(await store.read(), isNull);
  });
  test('cookies never leave the trusted API origin', () async {
    await store.write('secret-token');

    await dio.post('https://untrusted.example/api/v1/auth/refresh');

    final headers = adapter.requests.single.headers;

    expect(headers.keys.any((key) => key.toLowerCase() == 'cookie'), isFalse);
  });
}
