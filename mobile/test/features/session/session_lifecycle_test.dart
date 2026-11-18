import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/features/session/presentation/session_lifecycle.dart';

void main() {
  test('session lifecycle defines all restoration states', () {
    expect(SessionLifecycle.values, [
      SessionLifecycle.restoring,
      SessionLifecycle.signedIn,
      SessionLifecycle.signedOut,
      SessionLifecycle.retryRequired,
    ]);
  });

  test('temporary failure is distinct from signed out', () {
    expect(SessionLifecycle.retryRequired, isNot(SessionLifecycle.signedOut));
  });
}
