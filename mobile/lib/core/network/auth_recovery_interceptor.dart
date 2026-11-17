import 'package:dio/dio.dart';

import 'api_auth_client.dart';

/// Recovers authenticated GET requests from one HTTP 401 response.
///
/// Mutating requests are deliberately excluded from automatic replay.
class AuthRecoveryInterceptor extends Interceptor {
  AuthRecoveryInterceptor(this._dio, this._auth);

  final Dio _dio;
  final ApiAuthClient _auth;

  static const _retryKey = 'authRecoveryRetried';

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final request = err.requestOptions;
    final uri = request.uri;
    final apiUri = Uri.parse(request.baseUrl);

    final trusted =
        uri.scheme == apiUri.scheme &&
        uri.host == apiUri.host &&
        uri.port == apiUri.port;

    final authEndpoint =
        uri.path == '/api/v1/auth/login' ||
        uri.path == '/api/v1/auth/refresh' ||
        uri.path == '/api/v1/auth/logout';

    final sentAuthorization = request.headers['Authorization']?.toString();

    if (err.response?.statusCode != 401 ||
        request.method.toUpperCase() != 'GET' ||
        !trusted ||
        authEndpoint ||
        request.extra[_retryKey] == true ||
        sentAuthorization == null ||
        !sentAuthorization.startsWith('Bearer ')) {
      handler.next(err);
      return;
    }

    final previousToken = sentAuthorization.substring('Bearer '.length);

    final requestGeneration = request.extra['authSessionGeneration'];

    if (requestGeneration is! int ||
        requestGeneration != _auth.sessionGeneration) {
      handler.next(err);
      return;
    }

    try {
      final currentToken = _auth.accessToken;

      if (currentToken == null) {
        handler.next(err);
        return;
      }

      // A different request may have already refreshed this token.
      if (currentToken == previousToken) {
        await _auth.refresh();
      }

      if (requestGeneration != _auth.sessionGeneration) {
        handler.next(err);
        return;
      }

      final refreshedToken = _auth.accessToken;

      if (refreshedToken == null || refreshedToken == previousToken) {
        handler.next(err);
        return;
      }

      final retryOptions = request.copyWith(
        extra: {...request.extra, _retryKey: true},
      );

      // AuthInterceptor attaches the current token again.
      final response = await _dio.fetch<dynamic>(retryOptions);

      handler.resolve(response);
    } catch (_) {
      // Preserve the original 401. Never start another retry loop.
      handler.next(err);
    }
  }
}
