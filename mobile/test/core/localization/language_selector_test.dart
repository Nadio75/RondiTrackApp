import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ronditrack/core/localization/language_provider.dart';
import 'package:ronditrack/core/localization/language_selector.dart';
import 'package:ronditrack/core/localization/localization_context.dart';
import 'package:ronditrack/core/localization/sepedi_localizations.dart';
import 'package:ronditrack/core/theme/rondi_theme.dart';
import 'package:ronditrack/l10n/generated/app_localizations.dart';

class _LocalizationTestApp extends ConsumerWidget {
  const _LocalizationTestApp({this.themeMode = ThemeMode.light});

  final ThemeMode themeMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale =
        ref.watch(languageProvider).asData?.value ?? const Locale('en');

    return MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        SepediMaterialLocalizationsDelegate(),
        SepediWidgetsLocalizationsDelegate(),
        SepediCupertinoLocalizationsDelegate(),
        ...AppLocalizations.localizationsDelegates,
      ],
      theme: RondiTheme.light,
      darkTheme: RondiTheme.dark,
      themeMode: themeMode,
      home: const _LocalizationTestScreen(),
    );
  }
}

class _LocalizationTestScreen extends StatelessWidget {
  const _LocalizationTestScreen();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profile)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.welcome('Lerato')),
          const LanguageSelector(),
          FilledButton(onPressed: () {}, child: Text(l10n.signOut)),
        ],
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('language selector displays English by default', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: _LocalizationTestApp()));
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Welcome, Lerato!'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Sepedi'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('selecting Sepedi translates visible labels', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: _LocalizationTestApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sepedi'));
    await tester.pumpAndSettle();

    expect(find.text('Profaele'), findsOneWidget);
    expect(find.text('O amogetšwe, Lerato!'), findsOneWidget);
    expect(find.text('Tšwa'), findsOneWidget);
    expect(find.text('Profile'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('switching back to English restores original labels', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      LanguageNotifier.preferenceKey: 'nso',
    });

    await tester.pumpWidget(const ProviderScope(child: _LocalizationTestApp()));
    await tester.pumpAndSettle();

    expect(find.text('Profaele'), findsOneWidget);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Sign out'), findsOneWidget);
    expect(find.text('Profaele'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Sepedi has all required framework localizations', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      LanguageNotifier.preferenceKey: 'nso',
    });

    await tester.pumpWidget(const ProviderScope(child: _LocalizationTestApp()));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(_LocalizationTestScreen));

    expect(Localizations.localeOf(context), const Locale('nso'));
    expect(MaterialLocalizations.of(context), isNotNull);
    expect(WidgetsLocalizations.of(context), isNotNull);
    expect(CupertinoLocalizations.of(context), isNotNull);
    expect(Directionality.of(context), TextDirection.ltr);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Sepedi language selector works in dark mode', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: _LocalizationTestApp(themeMode: ThemeMode.dark),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sepedi'));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(_LocalizationTestScreen));

    expect(Theme.of(context).brightness, Brightness.dark);
    expect(find.text('Profaele'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
