import 'package:dio/dio.dart';

import '../../../core/network/api_auth_client.dart';
import '../data/demo_users.dart';

/// Authenticates against the backend and loads the real user profile.
class ApiSessionService {
  ApiSessionService({required this._auth, required this._dio});

  final ApiAuthClient _auth;
  final Dio _dio;

  Future<DemoUser> login({
    required String email,
    required String password,
  }) async {
    await _auth.login(email: email, password: password);
    final loginGeneration = _auth.sessionGeneration;

    try {
      final response = await _dio.get<Map<String, dynamic>>('/api/v1/me');
      final body = response.data;

      if (body == null ||
          body['id'] is! String ||
          body['name'] is! String ||
          body['email'] is! String) {
        throw const FormatException('Invalid profile response');
      }

      return DemoUser(
        id: body['id'] as String,
        name: body['name'] as String,
        email: body['email'] as String,
      );
    } catch (_) {
      // Do not retain a signed-in session when profile loading fails.
      try {
        await _auth.logoutIfGenerationMatches(loginGeneration);
      } catch (_) {
        // Local access-token invalidation occurs before the logout request.
      }
      rethrow;
    }
  }

  /// Restores an existing session using its refresh credential.
  ///
  /// Throws when the refresh credential is invalid or the network
  /// is unavailable. The caller decides whether to sign out or retry.
  Future<DemoUser> restore() async {
    await _auth.refresh();

    if (!_auth.isAuthenticated) {
      throw const FormatException('No active session to restore');
    }

    final response = await _dio.get<Map<String, dynamic>>('/api/v1/me');
    final body = response.data;

    if (body == null ||
        body['id'] is! String ||
        body['name'] is! String ||
        body['email'] is! String) {
      throw const FormatException('Invalid profile response');
    }

    return DemoUser(
      id: body['id'] as String,
      name: body['name'] as String,
      email: body['email'] as String,
    );
  }

  Future<void> logout() => _auth.logout();
}
