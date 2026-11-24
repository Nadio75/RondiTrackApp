import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class SepediMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const SepediMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'nso';

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    return GlobalMaterialLocalizations.delegate.load(const Locale('en', 'ZA'));
  }

  @override
  bool shouldReload(SepediMaterialLocalizationsDelegate old) => false;
}

class SepediWidgetsLocalizationsDelegate
    extends LocalizationsDelegate<WidgetsLocalizations> {
  const SepediWidgetsLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'nso';

  @override
  Future<WidgetsLocalizations> load(Locale locale) {
    return SynchronousFuture<WidgetsLocalizations>(
      const DefaultWidgetsLocalizations(),
    );
  }

  @override
  bool shouldReload(SepediWidgetsLocalizationsDelegate old) => false;
}

class SepediCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const SepediCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'nso';

  @override
  Future<CupertinoLocalizations> load(Locale locale) {
    return GlobalCupertinoLocalizations.delegate.load(const Locale('en', 'ZA'));
  }

  @override
  bool shouldReload(SepediCupertinoLocalizationsDelegate old) => false;
}
