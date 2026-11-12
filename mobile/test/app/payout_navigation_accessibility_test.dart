import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:ronditrack/app/router/app_routes.dart';
import 'package:ronditrack/app/router/auth_redirect.dart';
import 'package:ronditrack/app/ronditrack_root.dart';
import 'package:ronditrack/features/session/presentation/session_provider.dart';
import 'package:ronditrack/features/stokvel/presentation/payout_rotation_screen.dart';

void main() {
  const payoutPath = '/stokvels/bitcube-001/cycles/cycle-001/payout-rotation';

  test('typed payout route generates correct URL', () {
    const route = PayoutRotationRoute(id: 'bitcube-001', cycleId: 'cycle-001');

    expect(route.location, payoutPath);
  });

  test('signed-out payout deep link redirects to sign-in', () {
    expect(
      authRedirect(signedIn: false, location: payoutPath),
      Uri(path: '/sign-in', queryParameters: {'from': payoutPath}).toString(),
    );
  });

  test('signed-in user returns to payout after login', () {
    final signIn = Uri(
      path: '/sign-in',
      queryParameters: {'from': payoutPath},
    ).toString();

    expect(authRedirect(signedIn: true, location: signIn), payoutPath);
  });

  test('unsafe external redirect is rejected', () {
    expect(
      authRedirect(
        signedIn: true,
        location: '/sign-in?from=https%3A%2F%2Fevil.example',
      ),
      '/home',
    );
  });

  testWidgets('cycle opens payout screen at 360dp and 200% text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      container
          .read(sessionProvider.notifier)
          .login('lerato@example.com', 'testpassword123'),
      isTrue,
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MediaQuery(
          data: MediaQueryData(
            size: Size(360, 800),
            textScaler: TextScaler.linear(2),
          ),
          child: RondiTrackRoot(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    final context = tester.element(find.byType(NavigationBar));

    GoRouter.of(context).go('/stokvels/bitcube-001/cycles/cycle-001');

    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Cycle dashboard'), findsOneWidget);

    final button = find.text('View payout rotation');

    await tester.ensureVisible(button);
    await tester.pumpAndSettle();

    await tester.tap(button);
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    expect(find.byType(PayoutRotationScreen), findsOneWidget);
    expect(find.text('Payout rotation'), findsOneWidget);
    expect(find.text('Next recipient'), findsOneWidget);
    expect(find.text('1. Lerato'), findsOneWidget);
    expect(find.text('2. Thabo'), findsOneWidget);

    final payoutContext = tester.element(find.byType(PayoutRotationScreen));

    expect(MediaQuery.textScalerOf(payoutContext).scale(14), 28);

    expect(tester.takeException(), isNull);
  });
}
