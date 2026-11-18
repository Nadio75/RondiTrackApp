import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ronditrack/features/session/presentation/session_lifecycle.dart';
import 'package:ronditrack/features/session/presentation/session_lifecycle_provider.dart';
import 'package:ronditrack/features/session/presentation/session_provider.dart';

void main() {
  test('logout and login to the same account changes session generation', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(sessionProvider.notifier);

    expect(notifier.login('lerato@example.com', 'testpassword123'), isTrue);

    final firstAccountId = container.read(sessionProvider)!.id;
    final firstGeneration = notifier.sessionGeneration;

    expect(container.read(sessionLifecycleProvider), SessionLifecycle.signedIn);

    notifier.logout();

    expect(container.read(sessionProvider), isNull);
    expect(
      container.read(sessionLifecycleProvider),
      SessionLifecycle.signedOut,
    );

    final loggedOutGeneration = notifier.sessionGeneration;

    expect(loggedOutGeneration, greaterThan(firstGeneration));

    expect(notifier.login('lerato@example.com', 'testpassword123'), isTrue);

    final secondAccountId = container.read(sessionProvider)!.id;
    final secondGeneration = notifier.sessionGeneration;

    expect(secondAccountId, firstAccountId);
    expect(secondGeneration, greaterThan(loggedOutGeneration));
    expect(secondGeneration, isNot(firstGeneration));

    expect(container.read(sessionLifecycleProvider), SessionLifecycle.signedIn);
  });

  test('different account login also changes session generation', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(sessionProvider.notifier);

    expect(notifier.login('lerato@example.com', 'testpassword123'), isTrue);

    final firstAccountId = container.read(sessionProvider)!.id;
    final firstGeneration = notifier.sessionGeneration;

    notifier.logout();

    expect(notifier.login('thabo@example.com', 'testpassword123'), isTrue);

    final secondAccountId = container.read(sessionProvider)!.id;
    final secondGeneration = notifier.sessionGeneration;

    expect(secondAccountId, isNot(firstAccountId));
    expect(secondGeneration, greaterThan(firstGeneration));
  });
}
