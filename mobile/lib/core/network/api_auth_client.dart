import 'dart:async';

import 'package:dio/dio.dart';

/// Authentication responses are handled manually because the
/// current OpenAPI snapshot does not declare their response schemas.
class ApiAuthClient {
  ApiAuthClient(this._dio, {this._prepareNativeLogout});

  final Dio _dio;
  final Future<String?> Function()? _prepareNativeLogout;

  String? _accessToken;
  Future<void>? _refreshInFlight;
  int _sessionGeneration = 0;

  String? get accessToken => _accessToken;

  bool get isAuthenticated => _accessToken != null;

  /// Changes when login starts or logout occurs.
  int get sessionGeneration => _sessionGeneration;

  Future<void> login({required String email, required String password}) async {
    final generation = ++_sessionGeneration;
    _accessToken = null;

    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/auth/login',
      data: {'email': email, 'password': password},
    );

    if (generation != _sessionGeneration) return;

    _acceptToken(response.data);
  }

  Future<void> refresh() {
    final existing = _refreshInFlight;
    if (existing != null) return existing;

    final generation = _sessionGeneration;

    final future = _performRefresh(generation);
    _refreshInFlight = future;

    future.whenComplete(() {
      if (identical(_refreshInFlight, future)) {
        _refreshInFlight = null;
      }
    }).ignore();

    return future;
  }

  Future<void> _performRefresh(int generation) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/auth/refresh',
      );

      if (generation != _sessionGeneration) return;

      _acceptToken(response.data);
    } on DioException catch (error) {
      if (generation == _sessionGeneration &&
          error.response?.statusCode == 401) {
        _accessToken = null;
      }
      rethrow;
    }
  }

  /// Only invalidates credentials belonging to the expected session.
  ///
  /// Returns false when another authentication operation has started.
  Future<bool> logoutIfGenerationMatches(int expectedGeneration) async {
    if (expectedGeneration != _sessionGeneration) {
      return false;
    }

    await logout();
    return true;
  }

  Future<void> logout() async {
    ++_sessionGeneration;
    _accessToken = null;

    String? nativeRefreshToken;

    // Clear native credentials before attempting remote revocation.
    if (_prepareNativeLogout != null) {
      nativeRefreshToken = await _prepareNativeLogout();
    }

    try {
      await _dio
          .post<void>(
            '/api/v1/auth/logout',
            options: Options(
              extra: {'nativeLogoutToken': ?nativeRefreshToken},
              sendTimeout: const Duration(seconds: 3),
              receiveTimeout: const Duration(seconds: 3),
            ),
          )
          .timeout(const Duration(seconds: 3));
    } on DioException {
      // Local logout remains effective if remote revocation fails.
    } on TimeoutException {
      // Local logout remains effective if the server is unavailable.
    }
  }

  void _acceptToken(Map<String, dynamic>? body) {
    final token = body?['accessToken'];
    final tokenType = body?['tokenType'];
    final expiresIn = body?['expiresIn'];

    if (token is! String ||
        token.isEmpty ||
        tokenType != 'Bearer' ||
        expiresIn is! int ||
        expiresIn <= 0) {
      throw const FormatException('Invalid authentication response');
    }

    _accessToken = token;
  }
}
