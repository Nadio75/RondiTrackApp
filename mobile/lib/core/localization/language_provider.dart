import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final languageProvider = AsyncNotifierProvider<LanguageNotifier, Locale>(
  LanguageNotifier.new,
);

class LanguageNotifier extends AsyncNotifier<Locale> {
  static const preferenceKey = 'ronditrack_language';

  static const supportedLocales = [Locale('en'), Locale('nso')];

  @override
  Future<Locale> build() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final savedLanguage = preferences.getString(preferenceKey);

      return savedLanguage == 'nso' ? const Locale('nso') : const Locale('en');
    } catch (_) {
      return const Locale('en');
    }
  }

  Future<void> setLanguage(Locale locale) async {
    if (!supportedLocales.contains(locale)) {
      throw ArgumentError.value(locale, 'locale', 'Unsupported language');
    }

    final preferences = await SharedPreferences.getInstance();

    final saved = await preferences.setString(
      preferenceKey,
      locale.languageCode,
    );

    if (!saved) {
      throw StateError('Could not save language preference');
    }

    state = AsyncData(locale);
  }
}
