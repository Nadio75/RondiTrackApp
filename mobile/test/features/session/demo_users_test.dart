import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/features/session/data/demo_users.dart';

void main() {
  test('Lerato can log in with demo credentials', () {
    final user = authenticateDemoUser('lerato@example.com', 'testpassword123');

    expect(user?.name, 'Lerato');
  });

  test('Incorrect password is rejected', () {
    final user = authenticateDemoUser('thabo@example.com', 'wrongpassword');

    expect(user, isNull);
  });

  test('Unknown email is rejected', () {
    final user = authenticateDemoUser('unknown@example.com', 'testpassword123');

    expect(user, isNull);
  });
}
