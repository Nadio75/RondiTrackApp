import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ronditrack/features/cycles/presentation/cycle_details_screen.dart';

void main() {
  testWidgets('Non-member sees Cycle not found', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: const CycleDetailsScreen(
            stokvelId: 'bitcube-001',
            cycleId: 'cycle-001',
          ),
        ),
      ),
    );

    expect(find.text('Cycle not found'), findsOneWidget);
    expect(find.text('Cycle cycle-001'), findsNothing);
  });

  testWidgets('Unknown cycle shows Cycle not found', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: const CycleDetailsScreen(
            stokvelId: 'bitcube-001',
            cycleId: 'does-not-exist',
          ),
        ),
      ),
    );

    expect(find.text('Cycle not found'), findsOneWidget);
  });
}
