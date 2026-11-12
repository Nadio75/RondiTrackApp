import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ronditrack/features/profile/presentation/profile_screen.dart';
import 'package:ronditrack/features/session/presentation/session_provider.dart';
import 'package:ronditrack/features/stokvel/presentation/stokvel_details_provider.dart';

void main() {
  testWidgets('debug persona switcher displays three accounts', (tester) async {
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
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );

    expect(find.text('Development personas'), findsOneWidget);
    expect(find.text('Lerato - Treasurer'), findsOneWidget);
    expect(find.text('Thabo - Member'), findsOneWidget);
    expect(find.text('Naledi - Non-member'), findsOneWidget);
  });

  testWidgets('persona buttons change the active session', (tester) async {
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
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );

    await tester.tap(find.text('Thabo - Member'));
    await tester.pump();

    expect(container.read(sessionProvider)?.email, 'thabo@example.com');

    await tester.tap(find.text('Naledi - Non-member'));
    await tester.pump();

    expect(container.read(sessionProvider)?.email, 'naledi@example.com');

    await tester.tap(find.text('Lerato - Treasurer'));
    await tester.pump();

    expect(container.read(sessionProvider)?.email, 'lerato@example.com');

    expect(tester.takeException(), isNull);
  });

  test('switching personas respects Bitcube membership', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final session = container.read(sessionProvider.notifier);

    expect(session.login('lerato@example.com', 'testpassword123'), isTrue);

    final treasurer = await container.read(
      stokvelDetailsProvider('bitcube-001').future,
    );

    expect(treasurer, isNotNull);
    expect(treasurer!.visibleContributions.length, 2);

    expect(session.login('thabo@example.com', 'testpassword123'), isTrue);

    final member = await container.read(
      stokvelDetailsProvider('bitcube-001').future,
    );

    expect(member, isNotNull);
    expect(member!.visibleContributions.length, 1);
    expect(member.visibleContributions.single.memberId, 'user-2');

    expect(session.login('naledi@example.com', 'testpassword123'), isTrue);

    final outsider = await container.read(
      stokvelDetailsProvider('bitcube-001').future,
    );

    expect(outsider, isNull);
  });
}
