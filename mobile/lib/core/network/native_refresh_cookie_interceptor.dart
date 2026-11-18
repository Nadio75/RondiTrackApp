import 'package:dio/dio.dart';

import '../auth/auth_cookie_config.dart';
import '../auth/refresh_cookie_parser.dart';
import '../auth/refresh_token_store.dart';
import '../auth/serialized_refresh_token_store.dart';

/// Native-only refresh-cookie handling.
///
/// The browser uses its own HttpOnly cookie jar instead.
class NativeRefreshCookieInterceptor extends QueuedInterceptor {
  NativeRefreshCookieInterceptor({
    required RefreshTokenStore store,
    required String apiBaseUrl,
  }) : _store = SerializedRefreshTokenStore(store),
       _apiOrigin = Uri.parse(apiBaseUrl);

  final RefreshTokenStore _store;
  final Uri _apiOrigin;

  int _generation = 0;

  /// Invalidate pending authentication responses after sign-out.
  void invalidateSession() {
    _generation++;
  }

  /// Capture the old refresh credential and clear native storage.
  ///
  /// The caller must not use this token for any endpoint other than
  /// the trusted logout endpoint.
  Future<String?> prepareLogout() async {
    invalidateSession();

    String? token;

    try {
      token = await _store.read();
    } finally {
      await _store.clear();
    }

    return token;
  }

  bool _trusted(RequestOptions options) {
    final uri = options.uri;
    return uri.scheme == _apiOrigin.scheme &&
        uri.host == _apiOrigin.host &&
        uri.port == _apiOrigin.port;
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Capture the session generation before dispatching the request.
    options.extra['nativeCookieGeneration'] = _generation;

    // Do not allow callers to inject cookies.
    options.headers.remove('Cookie');
    options.headers.remove('cookie');

    final path = options.uri.path;
    final allowed =
        path == AuthCookieConfig.refreshPath ||
        path == AuthCookieConfig.logoutPath;

    if (_trusted(options) && allowed) {
      try {
        final logoutToken = path == AuthCookieConfig.logoutPath
            ? options.extra['nativeLogoutToken']
            : null;

        final token = logoutToken is String ? logoutToken : await _store.read();

        // A storage read may finish after logout invalidates the session.
        // Only the captured credential for a trusted logout request
        // may be sent after that invalidation.
        final generationStillValid =
            options.extra['nativeCookieGeneration'] == _generation;

        if (token != null &&
            token.isNotEmpty &&
            (generationStillValid ||
                (path == AuthCookieConfig.logoutPath &&
                    logoutToken is String))) {
          options.headers['Cookie'] =
              '${AuthCookieConfig.refreshCookieName}=$token';
        }
      } catch (error) {
        handler.reject(
          DioException(
            requestOptions: options,
            error: error,
            type: DioExceptionType.unknown,
          ),
        );
        return;
      }
    }

    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async {
    final path = response.requestOptions.uri.path;

    final requestGeneration =
        response.requestOptions.extra['nativeCookieGeneration'];

    // Never persist credentials from an invalidated session.
    if (requestGeneration != _generation) {
      handler.next(response);
      return;
    }

    final authResponse =
        path == '/api/v1/auth/login' || path == AuthCookieConfig.refreshPath;

    if (_trusted(response.requestOptions) && authResponse) {
      final headers = response.headers.map['set-cookie'] ?? [];

      final token = extractRefreshCookie(
        setCookieHeaders: headers,
        cookieName: AuthCookieConfig.refreshCookieName,
      );

      if (token != null) {
        try {
          await _store.write(token);
        } catch (error) {
          handler.reject(
            DioException(
              requestOptions: response.requestOptions,
              response: response,
              error: error,
              type: DioExceptionType.unknown,
            ),
          );
          return;
        }
      }
    }

    handler.next(response);
  }
}
