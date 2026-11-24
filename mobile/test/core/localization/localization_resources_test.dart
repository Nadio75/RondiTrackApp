import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/l10n/generated/app_localizations.dart';
import 'package:ronditrack/l10n/generated/app_localizations_en.dart';
import 'package:ronditrack/l10n/generated/app_localizations_nso.dart';
import 'package:ronditrack/core/localization/localized_values.dart';

void main() {
  final en = AppLocalizationsEn();
  final nso = AppLocalizationsNso();

  group('Localization resources', () {
    test('English and Sepedi are supported', () {
      expect(
        AppLocalizations.supportedLocales,
        containsAll([const Locale('en'), const Locale('nso')]),
      );
    });

    test('English navigation labels are correct', () {
      expect(en.home, 'Home');
      expect(en.stokvels, 'Stokvels');
      expect(en.activity, 'Activity');
      expect(en.profile, 'Profile');
    });

    test('Sepedi navigation labels are correct', () {
      expect(nso.home, 'Gae');
      expect(nso.stokvels, 'Mekgatlo ya poloko');
      expect(nso.activity, 'Ditiro');
      expect(nso.profile, 'Profaele');
    });

    test('welcome message preserves member name', () {
      expect(en.welcome('Lerato'), 'Welcome, Lerato!');
      expect(nso.welcome('Lerato'), 'O amogetšwe, Lerato!');
    });

    test('monthly contribution preserves formatted amount', () {
      const amount = 'R 1 250,50';

      expect(en.monthlyContribution(amount), 'Monthly contribution: $amount');

      expect(nso.monthlyContribution(amount), 'Moneelo wa kgwedi: $amount');
    });

    test('English contribution plurals are correct', () {
      expect(en.contributionCount(0), 'No contributions');
      expect(en.contributionCount(1), '1 contribution');
      expect(en.contributionCount(5), '5 contributions');
    });

    test('Sepedi contribution plurals are correct', () {
      expect(nso.contributionCount(0), 'Ga go na meneelo');
      expect(nso.contributionCount(1), 'Moneelo o tee');
      expect(nso.contributionCount(5), 'Meneelo ye 5');
    });

    test('known membership roles translate correctly', () {
      expect(localizedRole(en, 'treasurer'), 'treasurer');
      expect(localizedRole(nso, 'treasurer'), nso.treasurer);
      expect(localizedRole(nso, 'Chairperson'), nso.chairperson);
      expect(localizedRole(nso, 'member'), nso.member);
    });

    test('unrecognized roles preserve the original value', () {
      expect(localizedRole(nso, 'customRole'), 'customRole');
    });

    test('contribution statuses translate correctly', () {
      expect(localizedContributionStatus(nso, 'paid'), nso.paid);
      expect(localizedContributionStatus(nso, 'pending'), nso.pending);
      expect(localizedContributionStatus(nso, 'overdue'), nso.overdue);
      expect(localizedContributionStatus(nso, 'in_arrears'), nso.inArrears);
    });

    test('unknown contribution status is handled safely', () {
      expect(localizedContributionStatus(nso, 'unknown'), nso.unknown);
    });

    test('authentication errors are translated', () {
      expect(nso.invalidCredentials, isNot(en.invalidCredentials));
      expect(nso.tooManyAttempts, isNot(en.tooManyAttempts));
      expect(nso.signInError, isNot(en.signInError));
      expect(nso.signInConnectionError, isNot(en.signInConnectionError));
    });
  });
}
