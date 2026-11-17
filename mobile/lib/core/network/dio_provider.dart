import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_auth_client.dart';
import 'configure_http_adapter_native.dart'
    if (dart.library.js_interop) 'configure_http_adapter_web.dart'
    as platform_adapter;
import 'auth_interceptor.dart';
import 'auth_recovery_interceptor.dart';
import 'safe_logging_interceptor.dart';

const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:5056',
);

class ApiNetworkSession {
  ApiNetworkSession({required this.dio, required this.auth});

  final Dio dio;
  final ApiAuthClient auth;
}

final apiNetworkSessionProvider = Provider<ApiNetworkSession>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      persistentConnection: true,
      followRedirects: false,
      headers: {'Accept': 'application/json'},
    ),
  );

  platform_adapter.configureHttpAdapter(dio);

  final auth = ApiAuthClient(dio);

  dio.interceptors.add(AuthInterceptor(auth));
  dio.interceptors.add(AuthRecoveryInterceptor(dio, auth));
  dio.interceptors.add(SafeLoggingInterceptor());

  ref.onDispose(() => dio.close(force: true));

  return ApiNetworkSession(dio: dio, auth: auth);
});

final dioProvider = Provider<Dio>((ref) {
  return ref.watch(apiNetworkSessionProvider).dio;
});

final apiAuthClientProvider = Provider<ApiAuthClient>((ref) {
  return ref.watch(apiNetworkSessionProvider).auth;
});
