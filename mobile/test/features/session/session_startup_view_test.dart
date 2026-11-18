import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ronditrack/features/session/presentation/session_startup_view.dart';
import 'package:ronditrack/features/session/presentation/session_lifecycle.dart';
import 'package:ronditrack/features/session/presentation/session_lifecycle_provider.dart';

void main() {
  testWidgets('shows retry when restoration fails', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(sessionLifecycleProvider.notifier).markRetryRequired();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: SessionStartupView(child: Text('Protected content')),
        ),
      ),
    );

    expect(
      container.read(sessionLifecycleProvider),
      SessionLifecycle.retryRequired,
    );
    expect(find.text('Unable to restore your session.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('Protected content'), findsNothing);
  });

  testWidgets('shows loading while restoring', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SessionStartupView(child: Text('Protected content')),
        ),
      ),
    );

    expect(find.text('Restoring your session...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Protected content'), findsNothing);
  });
}
