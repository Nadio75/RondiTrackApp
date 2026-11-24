import '../../../l10n/generated/app_localizations.dart';

String formatHomeAge(
  AppLocalizations l10n,
  DateTime updatedAtUtc, {
  DateTime? now,
}) {
  final age = (now ?? DateTime.now()).toUtc().difference(updatedAtUtc.toUtc());

  if (age.inMinutes < 1) {
    return l10n.updatedJustNow;
  }

  if (age.inHours < 1) {
    return l10n.updatedMinutesAgo(age.inMinutes);
  }

  if (age.inDays < 1) {
    return l10n.updatedHoursAgo(age.inHours);
  }

  return l10n.updatedDaysAgo(age.inDays);
}
