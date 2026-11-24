import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ronditrack/core/network/api_auth_client.dart';
import 'package:ronditrack/core/network/auth_interceptor.dart';
import 'package:ronditrack/core/network/auth_recovery_interceptor.dart';

class MockApiAuthClient extends Mock implements ApiAuthClient {}

class ScriptedSessionAdapter implements HttpClientAdapter {
  ScriptedSessionAdapter({
    this.status = 401,
    this.noConnection = false,
    this.rejectNewToken = false,
  });

  final int status;
  final bool noConnection;
  final bool rejectNewToken;

  final List<String?> authorizations = [];

  int get requestCount => authorizations.length;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final authorization = options.headers['Authorization']?.toString();

    authorizations.add(authorization);

    if (noConnection) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
      );
    }

    final accepted = authorization == 'Bearer new-token' && !rejectNewToken;

    return ResponseBody.fromString(
      jsonEncode(
        accepted
            ? {'id': 'synthetic-member'}
            : {'title': 'Synthetic request refusal'},
      ),
      accepted ? 200 : status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late MockApiAuthClient auth;
  late Dio dio;
  late String? token;

  setUp(() {
    auth = MockApiAuthClient();
    token = 'old-token';

    when(() => auth.accessToken).thenAnswer((_) => token);

    when(() => auth.sessionGeneration).thenReturn(1);

    when(() => auth.isAuthenticated).thenAnswer((_) => token != null);

    dio = Dio(BaseOptions(baseUrl: 'http://localhost:5056'));

    dio.interceptors.add(AuthInterceptor(auth));

    dio.interceptors.add(AuthRecoveryInterceptor(dio, auth));
  });

  tearDown(() {
    dio.close(force: true);
  });

  test('401 refreshes mocked session and retries once', () async {
    final adapter = ScriptedSessionAdapter();

    dio.httpClientAdapter = adapter;

    when(() => auth.refresh()).thenAnswer((_) async {
      token = 'new-token';
    });

    final response = await dio.get<dynamic>('/api/v1/me');

    expect(response.statusCode, 200);
    expect(adapter.requestCount, 2);

    expect(adapter.authorizations, ['Bearer old-token', 'Bearer new-token']);

    verify(() => auth.refresh()).called(1);

    expect(auth.accessToken, 'new-token');
    expect(auth.isAuthenticated, isTrue);
  });

  test('refused refresh prevents request replay', () async {
    final adapter = ScriptedSessionAdapter();

    dio.httpClientAdapter = adapter;

    when(() => auth.refresh()).thenAnswer((_) async {
      token = null;

      final request = RequestOptions(path: '/api/v1/auth/refresh');

      throw DioException(
        requestOptions: request,
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(requestOptions: request, statusCode: 401),
      );
    });

    await expectLater(
      dio.get<dynamic>('/api/v1/me'),
      throwsA(
        isA<DioException>().having(
          (error) => error.response?.statusCode,
          'status',
          401,
        ),
      ),
    );

    verify(() => auth.refresh()).called(1);

    expect(adapter.requestCount, 1);
    expect(auth.accessToken, isNull);
    expect(auth.isAuthenticated, isFalse);
  });

  test('no connection preserves mocked session', () async {
    final adapter = ScriptedSessionAdapter(noConnection: true);

    dio.httpClientAdapter = adapter;

    await expectLater(
      dio.get<dynamic>('/api/v1/me'),
      throwsA(
        isA<DioException>().having(
          (error) => error.type,
          'type',
          DioExceptionType.connectionError,
        ),
      ),
    );

    verifyNever(() => auth.refresh());
    verifyNever(() => auth.logout());

    expect(adapter.requestCount, 1);
    expect(auth.accessToken, 'old-token');
    expect(auth.isAuthenticated, isTrue);
  });

  test('403 never refreshes the mocked session', () async {
    final adapter = ScriptedSessionAdapter(status: 403);

    dio.httpClientAdapter = adapter;

    await expectLater(
      dio.get<dynamic>('/api/v1/me'),
      throwsA(
        isA<DioException>().having(
          (error) => error.response?.statusCode,
          'status',
          403,
        ),
      ),
    );

    verifyNever(() => auth.refresh());
    verifyNever(() => auth.logout());

    expect(adapter.requestCount, 1);
    expect(auth.accessToken, 'old-token');
  });

  test('repeated 401 stops after one mocked refresh', () async {
    final adapter = ScriptedSessionAdapter(rejectNewToken: true);

    dio.httpClientAdapter = adapter;

    when(() => auth.refresh()).thenAnswer((_) async {
      token = 'new-token';
    });

    await expectLater(
      dio.get<dynamic>('/api/v1/me'),
      throwsA(
        isA<DioException>().having(
          (error) => error.response?.statusCode,
          'status',
          401,
        ),
      ),
    );

    verify(() => auth.refresh()).called(1);

    expect(adapter.requestCount, 2);

    expect(adapter.authorizations, ['Bearer old-token', 'Bearer new-token']);
  });
}
