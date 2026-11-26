import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ronditrack/app/ronditrack_root.dart';
import 'package:ronditrack/core/localization/language_provider.dart';
import 'package:ronditrack/features/session/presentation/session_provider.dart';
import 'package:ronditrack/l10n/generated/app_localizations_nso.dart';

Future<ProviderContainer> startApp(
  WidgetTester tester, {
  required Size size,
  String language = 'nso',
  double textScale = 1,
}) async {
  SharedPreferences.setMockInitialValues({
    LanguageNotifier.preferenceKey: language,
  });

  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;

  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  final container = ProviderContainer();
  addTearDown(container.dispose);

  final signedIn = container
      .read(sessionProvider.notifier)
      .login('lerato@example.com', 'testpassword123');

  expect(signedIn, isTrue);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MediaQuery(
        data: MediaQueryData(
          size: size,
          textScaler: TextScaler.linear(textScale),
        ),
        child: const RondiTrackRoot(),
      ),
    ),
  );

  await tester.pump();
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle();

  return container;
}

List<String> bottomLabels(WidgetTester tester) {
  final navigation = tester.widget<NavigationBar>(find.byType(NavigationBar));

  return navigation.destinations
      .whereType<NavigationDestination>()
      .map((destination) => destination.label)
      .toList();
}

List<String?> railLabels(WidgetTester tester) {
  final navigation = tester.widget<NavigationRail>(find.byType(NavigationRail));

  return navigation.destinations
      .map((destination) => (destination.label as Text).data)
      .toList();
}

void main() {
  final nso = AppLocalizationsNso();

  final expectedLabels = [nso.home, nso.stokvels, nso.activity, nso.profile];

  testWidgets('Compact navigation uses Sepedi labels', (tester) async {
    await startApp(tester, size: const Size(390, 844));

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
    expect(bottomLabels(tester), expectedLabels);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Medium navigation uses Sepedi labels', (tester) async {
    await startApp(tester, size: const Size(720, 900));

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(railLabels(tester), expectedLabels);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Expanded navigation uses Sepedi labels', (tester) async {
    await startApp(tester, size: const Size(1280, 900));

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(railLabels(tester), expectedLabels);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Real app navigation updates when language changes', (
    tester,
  ) async {
    final container = await startApp(
      tester,
      size: const Size(390, 844),
      language: 'en',
    );

    expect(bottomLabels(tester), ['Home', 'Stokvels', 'Activity', 'Profile']);

    await container
        .read(languageProvider.notifier)
        .setLanguage(const Locale('nso'));

    await tester.pumpAndSettle();

    expect(bottomLabels(tester), expectedLabels);

    await container
        .read(languageProvider.notifier)
        .setLanguage(const Locale('en'));

    await tester.pumpAndSettle();

    expect(bottomLabels(tester), ['Home', 'Stokvels', 'Activity', 'Profile']);

    expect(tester.takeException(), isNull);
  });

  testWidgets('Real Home translates financial labels', (tester) async {
    await startApp(tester, size: const Size(390, 844));

    expect(find.text(nso.stokvelOverview), findsOneWidget);

    expect(find.textContaining('Moneelo wa kgwedi:'), findsWidgets);

    expect(find.textContaining('Maikarabelo:'), findsWidgets);

    expect(find.textContaining('Monthly contribution:'), findsNothing);

    expect(tester.takeException(), isNull);
  });

  testWidgets('Sepedi navigation renders at 360dp and 200% text', (
    tester,
  ) async {
    await startApp(tester, size: const Size(360, 800), textScale: 2);

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(bottomLabels(tester), expectedLabels);

    final context = tester.element(find.byType(NavigationBar));

    expect(MediaQuery.textScalerOf(context).scale(14), 28);

    expect(tester.takeException(), isNull);
  });
}
