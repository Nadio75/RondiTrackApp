import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/core/auth/refresh_cookie_parser.dart';

void main() {
  group('extractRefreshCookie', () {
    test('extracts the correct cookie', () {
      final token = extractRefreshCookie(
        setCookieHeaders: [
          'other=value; Path=/',
          'ronditrack_refresh=secret123; Path=/api/v1/auth; HttpOnly; Secure',
        ],
        cookieName: 'ronditrack_refresh',
      );

      expect(token, 'secret123');
    });

    test('ignores unrelated cookies', () {
      final token = extractRefreshCookie(
        setCookieHeaders: ['session=abc; Path=/'],
        cookieName: 'ronditrack_refresh',
      );

      expect(token, isNull);
    });

    test('returns null for an empty cookie', () {
      final token = extractRefreshCookie(
        setCookieHeaders: ['ronditrack_refresh=; Path=/api/v1/auth'],
        cookieName: 'ronditrack_refresh',
      );

      expect(token, isNull);
    });

    test('preserves equals signs inside a cookie value', () {
      final token = extractRefreshCookie(
        setCookieHeaders: ['ronditrack_refresh=abc==; HttpOnly'],
        cookieName: 'ronditrack_refresh',
      );

      expect(token, 'abc==');
    });

    test('rejects an empty cookie name', () {
      expect(
        () => extractRefreshCookie(setCookieHeaders: [], cookieName: ''),
        throwsArgumentError,
      );
    });
  });
}
