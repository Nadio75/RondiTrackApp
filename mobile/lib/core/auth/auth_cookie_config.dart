/// Authentication settings matching the RondiTrack API contract.
class AuthCookieConfig {
  const AuthCookieConfig._();

  static const String refreshCookieName = String.fromEnvironment(
    'REFRESH_COOKIE_NAME',
    defaultValue: 'ronditrack_refresh',
  );

  static const String refreshPath = '/api/v1/auth/refresh';
  static const String logoutPath = '/api/v1/auth/logout';

  static void validate() {
    if (refreshCookieName.trim().isEmpty) {
      throw StateError('Missing refresh cookie configuration');
    }
  }
}
