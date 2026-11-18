import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ronditrack/features/session/presentation/session_lifecycle.dart';
import 'package:ronditrack/features/session/presentation/session_lifecycle_provider.dart';

void main() {
  test('lifecycle starts in restoring state', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      container.read(sessionLifecycleProvider),
      SessionLifecycle.restoring,
    );
  });

  test('lifecycle supports sign-in, sign-out and retry', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(sessionLifecycleProvider.notifier);

    notifier.markSignedIn();
    expect(container.read(sessionLifecycleProvider), SessionLifecycle.signedIn);

    notifier.markSignedOut();
    expect(
      container.read(sessionLifecycleProvider),
      SessionLifecycle.signedOut,
    );

    notifier.markRetryRequired();
    expect(
      container.read(sessionLifecycleProvider),
      SessionLifecycle.retryRequired,
    );

    notifier.markRestoring();
    expect(
      container.read(sessionLifecycleProvider),
      SessionLifecycle.restoring,
    );
  });
}
