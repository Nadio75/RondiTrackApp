import 'package:dio/dio.dart';
import 'package:dio/browser.dart';

import 'browser_credentials_interceptor.dart';
import 'trusted_origin_http_adapter.dart';

Future<String?> Function()? configureHttpAdapter(Dio dio) {
  dio.httpClientAdapter = TrustedOriginHttpAdapter(
    inner: BrowserHttpClientAdapter(withCredentials: false),
    apiBaseUrl: dio.options.baseUrl,
  );

  // Early credential decision for request inspection.
  // The HTTP adapter independently enforces the final decision.
  dio.interceptors.add(BrowserCredentialsInterceptor(dio.options.baseUrl));

  return null;
}
