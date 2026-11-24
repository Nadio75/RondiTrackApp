import 'package:dio/dio.dart';

import 'api_auth_client.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._auth);

  final ApiAuthClient _auth;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final requiredGeneration = options.extra['requiredAuthSessionGeneration'];

    if (requiredGeneration != null &&
        (requiredGeneration != _auth.sessionGeneration ||
            !_auth.isAuthenticated)) {
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.cancel,
          message: 'Authentication session changed.',
        ),
      );
      return;
    }

    final requestUri = options.uri;
    final apiUri = Uri.parse(options.baseUrl);

    // Bearer credentials must never leave the configured API origin.
    final isTrustedOrigin =
        requestUri.scheme == apiUri.scheme &&
        requestUri.host == apiUri.host &&
        requestUri.port == apiUri.port;

    final path = requestUri.path;

    final isAuthEndpoint =
        path == '/api/v1/auth/login' ||
        path == '/api/v1/auth/refresh' ||
        path == '/api/v1/auth/logout';

    // Remove stale or caller-supplied Bearer credentials.
    options.headers.remove('Authorization');

    if (isTrustedOrigin && !isAuthEndpoint) {
      final token = _auth.accessToken;

      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
        options.extra['authSessionGeneration'] = _auth.sessionGeneration;
      }
    }

    handler.next(options);
  }
}
