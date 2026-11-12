import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ronditrack/features/profile/presentation/profile_screen.dart';
import 'package:ronditrack/features/session/presentation/session_provider.dart';

void main() {
  testWidgets('persona switcher works at 360dp and 200% text scaling', (
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
        child: const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: Size(360, 800),
              textScaler: TextScaler.linear(2),
            ),
            child: ProfileScreen(),
          ),
        ),
      ),
    );

    expect(find.text('Development personas'), findsOneWidget);

    final profileContext = tester.element(find.byType(ProfileScreen));

    expect(MediaQuery.textScalerOf(profileContext).scale(14), 28);

    final memberButton = find.text('Thabo - Member');

    await tester.scrollUntilVisible(
      memberButton,
      150,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(memberButton);
    await tester.pump();

    expect(container.read(sessionProvider)?.email, 'thabo@example.com');

    final outsiderButton = find.text('Naledi - Non-member');

    await tester.scrollUntilVisible(
      outsiderButton,
      150,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(outsiderButton);
    await tester.pump();

    expect(container.read(sessionProvider)?.email, 'naledi@example.com');

    expect(tester.takeException(), isNull);
  });
}
