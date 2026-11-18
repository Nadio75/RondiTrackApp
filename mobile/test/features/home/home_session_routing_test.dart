import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ronditrack/core/offline/home_cache_repository.dart';
import 'package:ronditrack/features/home/domain/offline_home_provider.dart';
import 'package:ronditrack/features/home/presentation/home_screen.dart';
import 'package:ronditrack/features/session/presentation/session_origin_provider.dart';
import 'package:ronditrack/features/session/presentation/session_provider.dart';

void main() {
  testWidgets('demo session retains the Bitcube dashboard', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final signedIn = container
        .read(sessionProvider.notifier)
        .login('lerato@example.com', 'testpassword123');

    expect(signedIn, isTrue);
    expect(container.read(sessionOriginProvider), SessionOrigin.demo);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Bitcube'), findsOneWidget);
    expect(find.text('Welcome, Lerato!'), findsOneWidget);
  });

  testWidgets('API session displays the authenticated Home view', (
    tester,
  ) async {
    final snapshot = CachedHomeSnapshot(
      stokvels: const [
        CachedHomeStokvel(
          id: 'api-stokvel',
          name: 'Backend Savings',
          role: 'ADMIN',
        ),
      ],
      updatedAtUtc: DateTime.utc(2026, 11, 18),
    );

    final container = ProviderContainer(
      overrides: [
        authenticatedHomeProvider.overrideWith((ref) async => snapshot),
      ],
    );
    addTearDown(container.dispose);

    container
        .read(sessionProvider.notifier)
        .login('lerato@example.com', 'testpassword123');

    container.read(sessionOriginProvider.notifier).markApi();

    expect(container.read(sessionOriginProvider), SessionOrigin.api);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Backend Savings'), findsOneWidget);
    expect(find.text('Role: ADMIN'), findsOneWidget);
    expect(find.text('Bitcube'), findsNothing);
  });

  testWidgets('signed-out session does not display a dashboard', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Please sign in'), findsOneWidget);
    expect(find.text('Bitcube'), findsNothing);
    expect(find.text('Your stokvel overview'), findsNothing);
  });
}
