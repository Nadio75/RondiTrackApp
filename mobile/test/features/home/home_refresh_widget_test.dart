import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/features/home/domain/home_summaries_provider.dart';
import 'package:ronditrack/features/home/presentation/home_screen.dart';
import 'package:ronditrack/features/session/presentation/session_provider.dart';

void main() {
  testWidgets('Dashboard keeps Bitcube visible during refresh', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(sessionProvider.notifier)
        .login('lerato@example.com', 'testpassword123');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('Bitcube'), findsOneWidget);

    // Trigger refresh while the widget is still mounted.
    container.invalidate(homeSummariesProvider('user-1'));

    await tester.pump();

    // The existing card should remain visible.
    expect(find.text('Bitcube'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('Bitcube'), findsOneWidget);
  });
}
