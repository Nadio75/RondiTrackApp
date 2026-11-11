import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/app/router/auth_redirect.dart';

void main() {
  group('Protected destination restoration', () {
    test('signed-out stokvel URL is preserved', () {
      final redirect = authRedirect(
        signedIn: false,
        location: '/stokvels/bitcube-001',
      );

      expect(
        Uri.parse(redirect!).queryParameters['from'],
        '/stokvels/bitcube-001',
      );
    });

    test('login restores Bitcube details', () {
      final redirect = authRedirect(
        signedIn: true,
        location: '/sign-in?from=%2Fstokvels%2Fbitcube-001',
      );

      expect(redirect, '/stokvels/bitcube-001');
    });

    test('login restores Soweto Teachers details', () {
      final redirect = authRedirect(
        signedIn: true,
        location: '/sign-in?from=%2Fstokvels%2Fsoweto-teachers-001',
      );

      expect(redirect, '/stokvels/soweto-teachers-001');
    });

    test('login restores a cycle deep link', () {
      const destination = '/stokvels/bitcube-001/cycles/cycle-001';

      final signInRedirect = authRedirect(
        signedIn: false,
        location: destination,
      );

      expect(Uri.parse(signInRedirect!).queryParameters['from'], destination);

      final restored = authRedirect(signedIn: true, location: signInRedirect);

      expect(restored, destination);
    });

    test('invitation links still work', () {
      final signInRedirect = authRedirect(
        signedIn: false,
        location: '/join/ABC123',
      );

      final restored = authRedirect(signedIn: true, location: signInRedirect!);

      expect(restored, '/join/ABC123');
    });

    test('external destinations are rejected', () {
      final redirect = authRedirect(
        signedIn: true,
        location: '/sign-in?from=https%3A%2F%2Fevil.example',
      );

      expect(redirect, '/home');
    });

    test('protocol-relative destinations are rejected', () {
      final redirect = authRedirect(
        signedIn: true,
        location: '/sign-in?from=%2F%2Fevil.example',
      );

      expect(redirect, '/home');
    });
  });
}
