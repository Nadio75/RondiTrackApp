import 'package:flutter/widgets.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../l10n/generated/app_localizations_en.dart';

extension RondiLocalizationContext on BuildContext {
  AppLocalizations get l10n {
    return Localizations.of<AppLocalizations>(this, AppLocalizations) ??
        AppLocalizationsEn();
  }
}
