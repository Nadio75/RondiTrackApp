import 'package:flutter_test/flutter_test.dart';

import 'package:ronditrack/features/home/presentation/home_age_formatter.dart';
import 'package:ronditrack/l10n/generated/app_localizations_en.dart';
import 'package:ronditrack/l10n/generated/app_localizations_nso.dart';

void main() {
  final en = AppLocalizationsEn();
  final nso = AppLocalizationsNso();

  final now = DateTime.utc(2026, 11, 24, 10);

  String english(Duration age) {
    return formatHomeAge(en, now.subtract(age), now: now);
  }

  test('recent data displays just now', () {
    expect(english(const Duration(seconds: 30)), 'Updated just now');
  });

  test('one minute uses singular wording', () {
    expect(english(const Duration(minutes: 1)), 'Updated 1 minute ago');
  });

  test('multiple minutes use plural wording', () {
    expect(english(const Duration(minutes: 15)), 'Updated 15 minutes ago');
  });

  test('one hour uses singular wording', () {
    expect(english(const Duration(hours: 1)), 'Updated 1 hour ago');
  });

  test('multiple hours use plural wording', () {
    expect(english(const Duration(hours: 5)), 'Updated 5 hours ago');
  });

  test('one day uses singular wording', () {
    expect(english(const Duration(days: 1)), 'Updated 1 day ago');
  });

  test('multiple days use plural wording', () {
    expect(english(const Duration(days: 3)), 'Updated 3 days ago');
  });

  test('future timestamps never display negative ages', () {
    expect(
      formatHomeAge(en, now.add(const Duration(minutes: 5)), now: now),
      'Updated just now',
    );
  });

  test('Sepedi cache age uses localized resources', () {
    expect(
      formatHomeAge(nso, now.subtract(const Duration(minutes: 15)), now: now),
      nso.updatedMinutesAgo(15),
    );

    expect(nso.updatedMinutesAgo(15), isNot(en.updatedMinutesAgo(15)));
  });

  test('timezone conversion preserves the actual age', () {
    final timestamp = DateTime.parse('2026-11-24T11:45:00+02:00');

    expect(formatHomeAge(en, timestamp, now: now), 'Updated 15 minutes ago');
  });
}
