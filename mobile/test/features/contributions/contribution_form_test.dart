import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/features/contributions/presentation/contribution_form.dart';
import 'package:ronditrack/features/session/data/demo_users.dart';
import 'package:ronditrack/features/session/presentation/session_provider.dart';
import 'package:ronditrack/features/session/presentation/session_origin_provider.dart';
import 'package:ronditrack/l10n/generated/app_localizations.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  Future<void> renderForm(
    WidgetTester tester, {
    bool authenticated = true,
  }) async {
    if (authenticated) {
      final user = demoUsers.first;

      container.read(sessionProvider.notifier).login(user.email, demoPassword);

      container.read(sessionOriginProvider.notifier).markApi();
    }

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: ContributionForm(
                stokvelId: 'stokvel-1',
                cycleId: 'cycle-1',
                memberId: 'user-1',
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  testWidgets('authenticated user sees contribution form', (tester) async {
    await renderForm(tester);

    expect(find.byKey(const Key('contribution_amount')), findsOneWidget);

    expect(find.byKey(const Key('submit_contribution')), findsOneWidget);
  });

  testWidgets('unauthenticated user cannot access form', (tester) async {
    await renderForm(tester, authenticated: false);

    expect(find.text('Sign in again to continue'), findsOneWidget);

    expect(find.byKey(const Key('submit_contribution')), findsNothing);
  });

  for (final amount in ['', 'abc', '0', '-50', '10.999']) {
    testWidgets('form rejects invalid amount "$amount"', (tester) async {
      await renderForm(tester);

      await tester.enterText(
        find.byKey(const Key('contribution_amount')),
        amount,
      );

      await tester.tap(find.byKey(const Key('submit_contribution')));

      await tester.pumpAndSettle();

      expect(find.text('Enter a valid positive amount'), findsOneWidget);
    });
  }
}
