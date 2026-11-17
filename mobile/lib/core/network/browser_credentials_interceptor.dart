import 'package:dio/dio.dart';

class BrowserCredentialsInterceptor extends Interceptor {
  BrowserCredentialsInterceptor(this.apiBaseUrl);

  final String apiBaseUrl;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final requestUri = options.uri;
    final apiUri = Uri.parse(apiBaseUrl);

    final trusted =
        requestUri.scheme == apiUri.scheme &&
        requestUri.host == apiUri.host &&
        requestUri.port == apiUri.port;

    // Ignore caller-supplied credential settings.
    options.extra['withCredentials'] = trusted;

    handler.next(options);
  }
}
