import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ronditrack/core/localization/language_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Language preference provider', () {
    test('defaults to English on first launch', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final locale = await container.read(languageProvider.future);

      expect(locale, const Locale('en'));
    });

    test('restores previously saved Sepedi preference', () async {
      SharedPreferences.setMockInitialValues({
        LanguageNotifier.preferenceKey: 'nso',
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final locale = await container.read(languageProvider.future);

      expect(locale, const Locale('nso'));
    });

    test('switches from English to Sepedi', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(languageProvider.future);

      await container
          .read(languageProvider.notifier)
          .setLanguage(const Locale('nso'));

      expect(
        container.read(languageProvider).asData?.value,
        const Locale('nso'),
      );

      final preferences = await SharedPreferences.getInstance();

      expect(preferences.getString(LanguageNotifier.preferenceKey), 'nso');
    });

    test('switches back from Sepedi to English', () async {
      SharedPreferences.setMockInitialValues({
        LanguageNotifier.preferenceKey: 'nso',
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(languageProvider.future);

      await container
          .read(languageProvider.notifier)
          .setLanguage(const Locale('en'));

      expect(
        container.read(languageProvider).asData?.value,
        const Locale('en'),
      );

      final preferences = await SharedPreferences.getInstance();

      expect(preferences.getString(LanguageNotifier.preferenceKey), 'en');
    });

    test('language survives provider container recreation', () async {
      final first = ProviderContainer();

      try {
        await first.read(languageProvider.future);

        await first
            .read(languageProvider.notifier)
            .setLanguage(const Locale('nso'));
      } finally {
        first.dispose();
      }

      final second = ProviderContainer();
      addTearDown(second.dispose);

      expect(await second.read(languageProvider.future), const Locale('nso'));
    });

    test('invalid saved language falls back to English', () async {
      SharedPreferences.setMockInitialValues({
        LanguageNotifier.preferenceKey: 'invalid',
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(await container.read(languageProvider.future), const Locale('en'));
    });

    test('unsupported language is rejected', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(languageProvider.future);

      await expectLater(
        container
            .read(languageProvider.notifier)
            .setLanguage(const Locale('fr')),
        throwsArgumentError,
      );

      expect(
        container.read(languageProvider).asData?.value,
        const Locale('en'),
      );
    });
  });
}
