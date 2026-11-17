import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/core/network/browser_credentials_interceptor.dart';

void main() {
  const baseUrl = 'https://api.example.com:8443';

  late Dio dio;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: baseUrl));
    dio.interceptors.add(BrowserCredentialsInterceptor(baseUrl));

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(
            Response<Map<String, dynamic>>(
              requestOptions: options,
              data: {'withCredentials': options.extra['withCredentials']},
              statusCode: 200,
            ),
          );
        },
      ),
    );
  });

  tearDown(() => dio.close(force: true));

  Future<bool?> credentialsFor(
    String path, {
    Map<String, dynamic>? extra,
  }) async {
    final response = await dio.get<Map<String, dynamic>>(
      path,
      options: Options(extra: extra),
    );

    return response.data?['withCredentials'] as bool?;
  }

  test('trusted API requests enable credentials', () async {
    expect(await credentialsFor('/api/v1/auth/refresh'), isTrue);
  });

  test('external host cannot receive credentials', () async {
    expect(
      await credentialsFor('https://other.example.com:8443/data'),
      isFalse,
    );
  });

  test('different scheme cannot receive credentials', () async {
    expect(await credentialsFor('http://api.example.com:8443/data'), isFalse);
  });

  test('different port cannot receive credentials', () async {
    expect(await credentialsFor('https://api.example.com:9443/data'), isFalse);
  });

  test('caller cannot force credentials for external origin', () async {
    expect(
      await credentialsFor(
        'https://other.example.com:8443/data',
        extra: {'withCredentials': true},
      ),
      isFalse,
    );
  });

  test('caller cannot disable credentials for trusted origin', () async {
    expect(
      await credentialsFor(
        '/api/v1/auth/login',
        extra: {'withCredentials': false},
      ),
      isTrue,
    );
  });
}
