import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ronditrack/core/network/api_auth_client.dart';
import 'package:ronditrack/core/network/auth_interceptor.dart';

class MockPaymentAuthClient extends Mock implements ApiAuthClient {}

void main() {
  late Dio dio;
  late MockPaymentAuthClient auth;
  late int forwarded;

  setUp(() {
    auth = MockPaymentAuthClient();
    forwarded = 0;

    when(() => auth.sessionGeneration).thenReturn(5);
    when(() => auth.isAuthenticated).thenReturn(true);
    when(() => auth.accessToken).thenReturn('synthetic-token');

    dio = Dio(BaseOptions(baseUrl: 'https://example.invalid'));

    dio.interceptors.add(AuthInterceptor(auth));

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          forwarded++;

          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: 201,
              data: const {'accepted': true},
            ),
          );
        },
      ),
    );
  });

  tearDown(() {
    dio.close(force: true);
  });

  Future<Response<dynamic>> send(int generation) {
    return dio.post<dynamic>(
      '/api/v1/synthetic-contribution',
      options: Options(extra: {'requiredAuthSessionGeneration': generation}),
    );
  }

  test('matching authentication generation permits request', () async {
    final response = await send(5);

    expect(response.statusCode, 201);
    expect(forwarded, 1);
    expect(
      response.requestOptions.headers['Authorization'],
      'Bearer synthetic-token',
    );
  });

  test('stale authentication generation blocks request', () async {
    await expectLater(
      send(4),
      throwsA(
        isA<DioException>().having(
          (error) => error.type,
          'type',
          DioExceptionType.cancel,
        ),
      ),
    );

    expect(forwarded, 0);
  });

  test('signed out session blocks protected request', () async {
    when(() => auth.isAuthenticated).thenReturn(false);
    when(() => auth.accessToken).thenReturn(null);

    await expectLater(send(5), throwsA(isA<DioException>()));

    expect(forwarded, 0);
  });

  test('ordinary requests remain compatible', () async {
    final response = await dio.get<dynamic>('/api/v1/me/home');

    expect(response.statusCode, 201);
    expect(forwarded, 1);
  });

  test('account switch prevents old request from being forwarded', () async {
    const capturedGeneration = 5;

    when(() => auth.sessionGeneration).thenReturn(6);
    when(() => auth.accessToken).thenReturn('other-synthetic-token');

    await expectLater(send(capturedGeneration), throwsA(isA<DioException>()));

    expect(forwarded, 0);
  });
}
