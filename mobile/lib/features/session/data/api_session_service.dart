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
        await _auth.logout();
      } catch (_) {
        // Local access-token invalidation occurs before the logout request.
      }
      rethrow;
    }
  }

  Future<void> logout() => _auth.logout();
}
