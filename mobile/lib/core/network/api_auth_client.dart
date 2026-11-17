import 'package:dio/dio.dart';

/// Authentication responses are handled manually because the
/// current OpenAPI snapshot does not declare their response schemas.
class ApiAuthClient {
  ApiAuthClient(this._dio);

  final Dio _dio;

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
    } catch (_) {
      if (generation == _sessionGeneration) {
        _accessToken = null;
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    ++_sessionGeneration;
    _accessToken = null;

    await _dio.post<void>('/api/v1/auth/logout');
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
