import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/features/session/data/demo_users.dart';
import 'package:ronditrack/features/session/presentation/session_provider.dart';
import 'package:ronditrack/features/stokvel/presentation/payout_rotation_screen.dart';

void main() {
  Widget app() => const ProviderScope(
    child: MaterialApp(
      home: PayoutRotationScreen(
        stokvelId: 'bitcube-001',
        cycleId: 'cycle-001',
      ),
    ),
  );

  testWidgets('shows empty state when logged out', (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(
      find.text('No payout rotation is available for this cycle.'),
      findsOneWidget,
    );
  });

  testWidgets('shows payout order and next recipient', (tester) async {
    final container = ProviderContainer.test();
    addTearDown(container.dispose);

    expect(
      container
          .read(sessionProvider.notifier)
          .login('lerato@example.com', demoPassword),
      isTrue,
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: PayoutRotationScreen(
            stokvelId: 'bitcube-001',
            cycleId: 'cycle-001',
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('Next recipient'), findsOneWidget);
    expect(find.text('1. Lerato'), findsOneWidget);
    expect(find.text('2. Thabo'), findsOneWidget);
    expect(find.text('Status: Paid'), findsOneWidget);
    expect(find.text('Status: Next'), findsOneWidget);
    expect(find.text('Next payout recipient'), findsOneWidget);
  });

  testWidgets('nonmember cannot see payout recipients', (tester) async {
    final container = ProviderContainer.test();
    addTearDown(container.dispose);

    expect(
      container
          .read(sessionProvider.notifier)
          .login('naledi@example.com', demoPassword),
      isTrue,
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: PayoutRotationScreen(
            stokvelId: 'bitcube-001',
            cycleId: 'cycle-001',
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('1. Lerato'), findsNothing);
    expect(find.text('2. Thabo'), findsNothing);
    expect(
      find.text('No payout rotation is available for this cycle.'),
      findsOneWidget,
    );
  });
}
