import '../../l10n/generated/app_localizations.dart';

String localizedRole(AppLocalizations l10n, String role) {
  if (l10n.localeName.startsWith('en')) return role;

  return switch (role.trim().toLowerCase()) {
    'treasurer' => l10n.treasurer,
    'chairperson' => l10n.chairperson,
    'member' => l10n.member,
    _ => role,
  };
}

String localizedContributionStatus(AppLocalizations l10n, String status) {
  if (l10n.localeName.startsWith('en')) return status;

  final normalized = status.trim().toLowerCase().replaceAll(
    RegExp(r'[\s_-]'),
    '',
  );

  return switch (normalized) {
    'paid' => l10n.paid,
    'overdue' => l10n.overdue,
    'active' => l10n.active,
    'upcoming' => l10n.upcoming,
    'closed' => l10n.closed,
    'pending' => l10n.pending,
    'inarrears' || 'arrears' => l10n.inArrears,
    'uptodate' => l10n.upToDate,
    'unknown' || 'none' => l10n.unknown,
    _ => status,
  };
}
