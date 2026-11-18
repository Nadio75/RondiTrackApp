import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../auth/refresh_token_store.dart';
import 'native_refresh_cookie_interceptor.dart';

Future<String?> Function()? configureHttpAdapter(Dio dio) {
  const storage = FlutterSecureStorage();

  final interceptor = NativeRefreshCookieInterceptor(
    store: SecureRefreshTokenStore(storage),
    apiBaseUrl: dio.options.baseUrl,
  );

  dio.interceptors.add(interceptor);

  return interceptor.prepareLogout;
}
