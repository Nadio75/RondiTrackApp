import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ronditrack/core/offline/home_cache_repository.dart';
import 'package:ronditrack/features/home/domain/offline_home_provider.dart';
import 'package:ronditrack/features/home/presentation/api_home_view.dart';

void main() {
  Widget testApp(Future<CachedHomeSnapshot?> Function() load) {
    return ProviderScope(
      overrides: [authenticatedHomeProvider.overrideWith((ref) => load())],
      child: const MaterialApp(home: Scaffold(body: ApiHomeView())),
    );
  }

  testWidgets('displays backend stokvel names and roles', (tester) async {
    final snapshot = CachedHomeSnapshot(
      stokvels: const [
        CachedHomeStokvel(
          id: 'stokvel-1',
          name: 'Community Savings',
          role: 'ADMIN',
        ),
        CachedHomeStokvel(id: 'stokvel-2', name: 'Family Fund', role: 'MEMBER'),
      ],
      updatedAtUtc: DateTime.utc(2026, 11, 18, 12),
    );

    await tester.pumpWidget(testApp(() async => snapshot));
    await tester.pumpAndSettle();

    expect(find.text('Your stokvel overview'), findsOneWidget);
    expect(find.text('Community Savings'), findsOneWidget);
    expect(find.text('Family Fund'), findsOneWidget);
    expect(find.text('Role: ADMIN'), findsOneWidget);
    expect(find.text('Role: MEMBER'), findsOneWidget);
    expect(find.textContaining('Last updated:'), findsOneWidget);
  });

  testWidgets('displays an empty stokvel message', (tester) async {
    final snapshot = CachedHomeSnapshot(
      stokvels: const [],
      updatedAtUtc: DateTime.utc(2026, 11, 18),
    );

    await tester.pumpWidget(testApp(() async => snapshot));
    await tester.pumpAndSettle();

    expect(find.text('You have not joined any stokvels yet.'), findsOneWidget);
  });

  testWidgets('handles a missing Home snapshot', (tester) async {
    await tester.pumpWidget(testApp(() async => null));
    await tester.pumpAndSettle();

    expect(find.text('No Home data is available yet.'), findsOneWidget);
  });

  testWidgets('retries after an API Home error', (tester) async {
    var attempts = 0;

    final snapshot = CachedHomeSnapshot(
      stokvels: const [
        CachedHomeStokvel(
          id: 'retry-stokvel',
          name: 'Recovered Savings',
          role: 'MEMBER',
        ),
      ],
      updatedAtUtc: DateTime.utc(2026, 11, 18),
    );

    await tester.pumpWidget(
      testApp(() async {
        attempts++;

        if (attempts == 1) {
          throw StateError('Simulated network failure');
        }

        return snapshot;
      }),
    );

    await tester.pumpAndSettle();

    expect(find.text('Could not load your stokvels.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Recovered Savings'), findsOneWidget);
    expect(find.text('Role: MEMBER'), findsOneWidget);
    expect(attempts, 2);
  });
  testWidgets('shows loading while Home data is pending', (tester) async {
    final pending = Completer<CachedHomeSnapshot?>();

    await tester.pumpWidget(testApp(() => pending.future));

    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    pending.complete(null);

    await tester.pumpAndSettle();

    expect(find.text('No Home data is available yet.'), findsOneWidget);
  });
}
