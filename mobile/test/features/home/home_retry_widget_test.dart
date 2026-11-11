import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/features/home/presentation/home_screen.dart';
import 'package:ronditrack/features/session/presentation/session_provider.dart';
import 'package:ronditrack/features/stokvel/data/fake_stokvel_repository.dart';
import 'package:ronditrack/features/stokvel/domain/stokvel_models.dart';
import 'package:ronditrack/features/stokvel/domain/stokvel_repository.dart';

class RetryRepository implements StokvelRepository {
  @override
  Cycle? getActiveCycle({required String userId, required String stokvelId}) {
    return null;
  }

  @override
  Cycle? getCycle({
    required String userId,
    required String stokvelId,
    required String cycleId,
  }) {
    return null;
  }

  bool shouldFail = true;

  final StokvelRepository delegate = FakeStokvelRepository();

  @override
  List<Stokvel> getStokvelsForUser(String userId) {
    if (shouldFail) {
      throw Exception('Temporary repository failure');
    }

    return delegate.getStokvelsForUser(userId);
  }

  @override
  StokvelDetails? getDetails({
    required String userId,
    required String stokvelId,
  }) {
    return delegate.getDetails(userId: userId, stokvelId: stokvelId);
  }
}

void main() {
  testWidgets('Dashboard Retry button recovers after failure', (tester) async {
    final repository = RetryRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [stokvelRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, child) {
              final user = ref.watch(sessionProvider);

              if (user == null) {
                return Scaffold(
                  body: Center(
                    child: FilledButton(
                      onPressed: () {
                        ref
                            .read(sessionProvider.notifier)
                            .login('lerato@example.com', 'testpassword123');
                      },
                      child: const Text('Sign in'),
                    ),
                  ),
                );
              }

              return const HomeScreen();
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Sign in'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('Could not load your stokvels.'), findsOneWidget);

    repository.shouldFail = false;

    await tester.tap(find.text('Retry'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('Bitcube'), findsOneWidget);
    expect(find.text('Role: treasurer'), findsOneWidget);
  });
}
