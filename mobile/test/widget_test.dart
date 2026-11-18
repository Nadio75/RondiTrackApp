import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/main.dart';
import 'package:ronditrack/features/session/presentation/session_lifecycle.dart';
import 'package:ronditrack/features/session/presentation/session_lifecycle_provider.dart';
import 'package:ronditrack/features/session/presentation/session_provider.dart';

void main() {
  testWidgets('RondiTrack application starts successfully', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final signedIn = container
        .read(sessionProvider.notifier)
        .login('lerato@example.com', 'testpassword123');

    expect(signedIn, isTrue);
    expect(container.read(sessionLifecycleProvider), SessionLifecycle.signedIn);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const RondiTrackApp(),
      ),
    );

    // Allow the Home screen's 400ms loading timer to finish.
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Restoring your session...'), findsNothing);

    // Support compact and wide navigation layouts.
    final navigationCount =
        find.byType(NavigationBar).evaluate().length +
        find.byType(NavigationRail).evaluate().length;

    expect(navigationCount, greaterThan(0));
    expect(tester.takeException(), isNull);
  });
}
