import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ronditrack/features/profile/presentation/profile_screen.dart';
import 'package:ronditrack/features/session/presentation/demo_persona_config.dart';

void main() {
  testWidgets('demo personas are hidden by default', (tester) async {
    final container = ProviderContainer(
      overrides: [demoPersonasEnabledProvider.overrideWithValue(false)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );

    expect(find.text('Development personas'), findsNothing);
    expect(find.text('Lerato - Treasurer'), findsNothing);
    expect(find.text('Thabo - Member'), findsNothing);
    expect(find.text('Naledi - Non-member'), findsNothing);
    expect(find.text('Sign out'), findsOneWidget);
  });
}
