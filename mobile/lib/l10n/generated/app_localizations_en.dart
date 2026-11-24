// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'RondiTrack';

  @override
  String get home => 'Home';

  @override
  String get stokvels => 'Stokvels';

  @override
  String get activity => 'Activity';

  @override
  String get profile => 'Profile';

  @override
  String get language => 'Language';

  @override
  String get appLanguage => 'App language';

  @override
  String get chooseLanguage => 'Choose your preferred language';

  @override
  String get english => 'English';

  @override
  String get sepedi => 'Sepedi';

  @override
  String get saveLanguage => 'Save language';

  @override
  String get languageChanged => 'Language changed successfully';

  @override
  String get guest => 'Guest';

  @override
  String get signOut => 'Sign out';

  @override
  String get logout => 'Logout';

  @override
  String get login => 'Login';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get signInSubtitle => 'Sign in to manage your stokvel';

  @override
  String get pleaseSignIn => 'Please sign in';

  @override
  String get invalidCredentials => 'Invalid email or password';

  @override
  String get tooManyAttempts => 'Too many attempts. Please try again later.';

  @override
  String get signInConnectionError =>
      'Unable to sign in. Check your connection and retry.';

  @override
  String get signInError => 'Unable to sign in. Please try again.';

  @override
  String get stokvelOverview => 'Your stokvel overview';

  @override
  String get noStokvels => 'You have not joined any stokvels yet.';

  @override
  String get noHomeData => 'No Home data is available yet.';

  @override
  String get loadStokvelsError => 'Could not load your stokvels.';

  @override
  String get retry => 'Retry';

  @override
  String get tryAgain => 'Try again';

  @override
  String get loading => 'Loading...';

  @override
  String get offline => 'Offline';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get close => 'Close';

  @override
  String get treasurer => 'Treasurer';

  @override
  String get chairperson => 'Chairperson';

  @override
  String get member => 'Member';

  @override
  String get paid => 'Paid';

  @override
  String get pending => 'Pending';

  @override
  String get inArrears => 'In arrears';

  @override
  String get upToDate => 'Up to date';

  @override
  String get unknown => 'Unknown';

  @override
  String welcome(String name) {
    return 'Welcome, $name!';
  }

  @override
  String monthlyContribution(String amount) {
    return 'Monthly contribution: $amount';
  }

  @override
  String roleLabel(String role) {
    return 'Role: $role';
  }

  @override
  String contributionStatus(String status) {
    return 'Contribution status: $status';
  }

  @override
  String lastUpdated(String date) {
    return 'Last updated: $date';
  }

  @override
  String contributionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contributions',
      one: '1 contribution',
      zero: 'No contributions',
    );
    return '$_temp0';
  }

  @override
  String get activityEmpty => 'Your stokvel activity will appear here.';

  @override
  String get myStokvels => 'My Stokvels';

  @override
  String get loadStokvelsListError => 'Could not load stokvels.';

  @override
  String get stokvel => 'Stokvel';

  @override
  String get loadStokvelDetailsError => 'Could not load stokvel details.';

  @override
  String get stokvelNotFound => 'Stokvel not found';

  @override
  String get switchStokvel => 'Switch stokvel';

  @override
  String get monthlyContributionTitle => 'Monthly contribution';

  @override
  String yourRole(String value) {
    return 'Your role: $value';
  }

  @override
  String get currentCycle => 'Current cycle';

  @override
  String statusLabel(String value) {
    return 'Status: $value';
  }

  @override
  String get viewCurrentCycle => 'View Current Cycle';

  @override
  String get totalPaidContributions => 'Total paid contributions';

  @override
  String get yourPaidContributions => 'Your paid contributions';

  @override
  String get memberContributions => 'Member contributions';

  @override
  String get yourContributions => 'Your contributions';

  @override
  String get noContributionsFound => 'No contributions found.';

  @override
  String get unknownMember => 'Unknown member';

  @override
  String get selectStokvel => 'Select a stokvel to view its details.';

  @override
  String get payoutRotation => 'Payout rotation';

  @override
  String get payoutEmpty => 'No payout rotation is available for this cycle.';

  @override
  String get payoutLoadError => 'Could not load the payout rotation.';

  @override
  String get payoutSchedule => 'Payout schedule';

  @override
  String get recipientOrderDescription =>
      'Recipients are shown in their assigned payout order.';

  @override
  String get nextRecipient => 'Next recipient';

  @override
  String get rotationOrder => 'Rotation order';

  @override
  String get next => 'Next';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get active => 'Active';

  @override
  String get closed => 'Closed';

  @override
  String get overdue => 'Overdue';

  @override
  String get nextPayoutRecipient => 'Next payout recipient';

  @override
  String scheduled(String value) {
    return 'Scheduled: $value';
  }

  @override
  String get cycle => 'Cycle';

  @override
  String get cycleNotFound => 'Cycle not found';

  @override
  String get cycleDashboard => 'Cycle dashboard';

  @override
  String cycleIdentifier(String value) {
    return 'Cycle $value';
  }

  @override
  String get cycleOverview => 'Cycle overview';

  @override
  String startDate(String value) {
    return 'Start date: $value';
  }

  @override
  String endDate(String value) {
    return 'End date: $value';
  }

  @override
  String get contributionSummary => 'Contribution summary';

  @override
  String get demoContributionCounts =>
      'Paid and unpaid member counts are not available for this cycle in the current demo data.';

  @override
  String get payoutInformation => 'Payout information';

  @override
  String get payoutDescription =>
      'View the assigned recipient order and the next payout for this cycle.';

  @override
  String get viewPayoutRotation => 'View payout rotation';

  @override
  String get stokvelInvitation => 'Stokvel invitation';

  @override
  String get youAreInvited => 'You have been invited!';

  @override
  String get invitationCode => 'Your invitation code is:';

  @override
  String get invitationUnavailable =>
      'Invitation acceptance will be available when the invitation service is connected.';

  @override
  String get restoringSession => 'Restoring your session...';

  @override
  String get restoreSessionError => 'Unable to restore your session.';

  @override
  String get languageSaveError => 'Could not save language. Try again.';

  @override
  String get viewStokvels => 'View stokvels';

  @override
  String get offlineSavedData => 'Offline - showing saved data';

  @override
  String get cachedSavedData => 'Unable to refresh - showing saved data';

  @override
  String get updatedJustNow => 'Updated just now';

  @override
  String updatedMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Updated $count minutes ago',
      one: 'Updated 1 minute ago',
    );
    return '$_temp0';
  }

  @override
  String updatedHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Updated $count hours ago',
      one: 'Updated 1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String updatedDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Updated $count days ago',
      one: 'Updated 1 day ago',
    );
    return '$_temp0';
  }

  @override
  String errorReference(String reference) {
    return 'Reference: $reference';
  }
}
