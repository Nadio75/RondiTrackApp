import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:ronditrack/app/ronditrack_root.dart';

import 'package:ronditrack/features/session/presentation/session_provider.dart';

void main() {
  testWidgets('Real app Home screen renders at 360dp with 200% text', (
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

    container
        .read(sessionProvider.notifier)
        .login('lerato@example.com', 'testpassword123');

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

    expect(find.byType(NavigationBar), findsOneWidget);

    final navigationContext = tester.element(find.byType(NavigationBar));

    final textScaler = MediaQuery.textScalerOf(navigationContext);

    expect(textScaler.scale(14), 28);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Bitcube details renders at 360dp with 200% text', (
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

    container
        .read(sessionProvider.notifier)
        .login('lerato@example.com', 'testpassword123');

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

    GoRouter.of(context).go('/stokvels/bitcube-001');

    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Bitcube'), findsWidgets);
    expect(find.byType(NavigationBar), findsOneWidget);

    final detailsContext = tester.element(find.byType(NavigationBar));

    expect(MediaQuery.textScalerOf(detailsContext).scale(14), 28);

    expect(tester.takeException(), isNull);
  });
  testWidgets('Current cycle renders at 360dp with 200% text', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(sessionProvider.notifier)
        .login('lerato@example.com', 'testpassword123');

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
    expect(find.text('Current cycle'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    final navigationContext = tester.element(find.byType(NavigationBar));

    expect(MediaQuery.textScalerOf(navigationContext).scale(14), 28);

    expect(tester.takeException(), isNull);
  });
}
