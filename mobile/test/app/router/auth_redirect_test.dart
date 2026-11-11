import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/app/router/auth_redirect.dart';

void main() {
  group('Authentication redirects', () {
    test('Signed-out Home redirects to Sign In', () {
      expect(
        authRedirect(signedIn: false, location: '/home'),
        '/sign-in?from=%2Fhome',
      );
    });

    test('Signed-out stokvel redirects to Sign In', () {
      expect(
        authRedirect(signedIn: false, location: '/stokvels/bitcube-001'),
        '/sign-in?from=%2Fstokvels%2Fbitcube-001',
      );
    });

    test('Signed-out user remains on Sign In', () {
      expect(authRedirect(signedIn: false, location: '/sign-in'), isNull);
    });

    test('Signed-in user on Sign In redirects Home', () {
      expect(authRedirect(signedIn: true, location: '/sign-in'), '/home');
    });

    test('Signed-in user can visit Home', () {
      expect(authRedirect(signedIn: true, location: '/home'), isNull);
    });

    test('Signed-in user can visit a stokvel', () {
      expect(
        authRedirect(signedIn: true, location: '/stokvels/bitcube-001'),
        isNull,
      );
    });

    test('Signed-out invitation remembers destination', () {
      expect(
        authRedirect(signedIn: false, location: '/join/ABC123'),
        '/sign-in?from=%2Fjoin%2FABC123',
      );
    });

    test('Signed-in user returns to invitation after login', () {
      expect(
        authRedirect(
          signedIn: true,
          location: '/sign-in?from=%2Fjoin%2FABC123',
        ),
        '/join/ABC123',
      );
    });

    test('External return URL is rejected', () {
      expect(
        authRedirect(
          signedIn: true,
          location: '/sign-in?from=https%3A%2F%2Fevil.example',
        ),
        '/home',
      );
    });

    test('Protocol-relative return URL is rejected', () {
      expect(
        authRedirect(
          signedIn: true,
          location: '/sign-in?from=%2F%2Fevil.example',
        ),
        '/home',
      );
    });
  });
}
