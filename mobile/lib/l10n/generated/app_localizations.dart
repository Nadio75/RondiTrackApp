import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_nso.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('nso'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'RondiTrack'**
  String get appName;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @stokvels.
  ///
  /// In en, this message translates to:
  /// **'Stokvels'**
  String get stokvels;

  /// No description provided for @activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get appLanguage;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get chooseLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @sepedi.
  ///
  /// In en, this message translates to:
  /// **'Sepedi'**
  String get sepedi;

  /// No description provided for @saveLanguage.
  ///
  /// In en, this message translates to:
  /// **'Save language'**
  String get saveLanguage;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed successfully'**
  String get languageChanged;

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to manage your stokvel'**
  String get signInSubtitle;

  /// No description provided for @pleaseSignIn.
  ///
  /// In en, this message translates to:
  /// **'Please sign in'**
  String get pleaseSignIn;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password'**
  String get invalidCredentials;

  /// No description provided for @tooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please try again later.'**
  String get tooManyAttempts;

  /// No description provided for @signInConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Unable to sign in. Check your connection and retry.'**
  String get signInConnectionError;

  /// No description provided for @signInError.
  ///
  /// In en, this message translates to:
  /// **'Unable to sign in. Please try again.'**
  String get signInError;

  /// No description provided for @stokvelOverview.
  ///
  /// In en, this message translates to:
  /// **'Your stokvel overview'**
  String get stokvelOverview;

  /// No description provided for @noStokvels.
  ///
  /// In en, this message translates to:
  /// **'You have not joined any stokvels yet.'**
  String get noStokvels;

  /// No description provided for @noHomeData.
  ///
  /// In en, this message translates to:
  /// **'No Home data is available yet.'**
  String get noHomeData;

  /// No description provided for @loadStokvelsError.
  ///
  /// In en, this message translates to:
  /// **'Could not load your stokvels.'**
  String get loadStokvelsError;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @treasurer.
  ///
  /// In en, this message translates to:
  /// **'Treasurer'**
  String get treasurer;

  /// No description provided for @chairperson.
  ///
  /// In en, this message translates to:
  /// **'Chairperson'**
  String get chairperson;

  /// No description provided for @member.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get member;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @inArrears.
  ///
  /// In en, this message translates to:
  /// **'In arrears'**
  String get inArrears;

  /// No description provided for @upToDate.
  ///
  /// In en, this message translates to:
  /// **'Up to date'**
  String get upToDate;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}!'**
  String welcome(String name);

  /// No description provided for @monthlyContribution.
  ///
  /// In en, this message translates to:
  /// **'Monthly contribution: {amount}'**
  String monthlyContribution(String amount);

  /// No description provided for @roleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role: {role}'**
  String roleLabel(String role);

  /// No description provided for @contributionStatus.
  ///
  /// In en, this message translates to:
  /// **'Contribution status: {status}'**
  String contributionStatus(String status);

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: {date}'**
  String lastUpdated(String date);

  /// No description provided for @contributionCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No contributions} =1{1 contribution} other{{count} contributions}}'**
  String contributionCount(int count);

  /// No description provided for @activityEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your stokvel activity will appear here.'**
  String get activityEmpty;

  /// No description provided for @myStokvels.
  ///
  /// In en, this message translates to:
  /// **'My Stokvels'**
  String get myStokvels;

  /// No description provided for @loadStokvelsListError.
  ///
  /// In en, this message translates to:
  /// **'Could not load stokvels.'**
  String get loadStokvelsListError;

  /// No description provided for @stokvel.
  ///
  /// In en, this message translates to:
  /// **'Stokvel'**
  String get stokvel;

  /// No description provided for @loadStokvelDetailsError.
  ///
  /// In en, this message translates to:
  /// **'Could not load stokvel details.'**
  String get loadStokvelDetailsError;

  /// No description provided for @stokvelNotFound.
  ///
  /// In en, this message translates to:
  /// **'Stokvel not found'**
  String get stokvelNotFound;

  /// No description provided for @switchStokvel.
  ///
  /// In en, this message translates to:
  /// **'Switch stokvel'**
  String get switchStokvel;

  /// No description provided for @monthlyContributionTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly contribution'**
  String get monthlyContributionTitle;

  /// No description provided for @yourRole.
  ///
  /// In en, this message translates to:
  /// **'Your role: {value}'**
  String yourRole(String value);

  /// No description provided for @currentCycle.
  ///
  /// In en, this message translates to:
  /// **'Current cycle'**
  String get currentCycle;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status: {value}'**
  String statusLabel(String value);

  /// No description provided for @viewCurrentCycle.
  ///
  /// In en, this message translates to:
  /// **'View Current Cycle'**
  String get viewCurrentCycle;

  /// No description provided for @totalPaidContributions.
  ///
  /// In en, this message translates to:
  /// **'Total paid contributions'**
  String get totalPaidContributions;

  /// No description provided for @yourPaidContributions.
  ///
  /// In en, this message translates to:
  /// **'Your paid contributions'**
  String get yourPaidContributions;

  /// No description provided for @memberContributions.
  ///
  /// In en, this message translates to:
  /// **'Member contributions'**
  String get memberContributions;

  /// No description provided for @yourContributions.
  ///
  /// In en, this message translates to:
  /// **'Your contributions'**
  String get yourContributions;

  /// No description provided for @noContributionsFound.
  ///
  /// In en, this message translates to:
  /// **'No contributions found.'**
  String get noContributionsFound;

  /// No description provided for @unknownMember.
  ///
  /// In en, this message translates to:
  /// **'Unknown member'**
  String get unknownMember;

  /// No description provided for @selectStokvel.
  ///
  /// In en, this message translates to:
  /// **'Select a stokvel to view its details.'**
  String get selectStokvel;

  /// No description provided for @payoutRotation.
  ///
  /// In en, this message translates to:
  /// **'Payout rotation'**
  String get payoutRotation;

  /// No description provided for @payoutEmpty.
  ///
  /// In en, this message translates to:
  /// **'No payout rotation is available for this cycle.'**
  String get payoutEmpty;

  /// No description provided for @payoutLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load the payout rotation.'**
  String get payoutLoadError;

  /// No description provided for @payoutSchedule.
  ///
  /// In en, this message translates to:
  /// **'Payout schedule'**
  String get payoutSchedule;

  /// No description provided for @recipientOrderDescription.
  ///
  /// In en, this message translates to:
  /// **'Recipients are shown in their assigned payout order.'**
  String get recipientOrderDescription;

  /// No description provided for @nextRecipient.
  ///
  /// In en, this message translates to:
  /// **'Next recipient'**
  String get nextRecipient;

  /// No description provided for @rotationOrder.
  ///
  /// In en, this message translates to:
  /// **'Rotation order'**
  String get rotationOrder;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @nextPayoutRecipient.
  ///
  /// In en, this message translates to:
  /// **'Next payout recipient'**
  String get nextPayoutRecipient;

  /// No description provided for @scheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled: {value}'**
  String scheduled(String value);

  /// No description provided for @cycle.
  ///
  /// In en, this message translates to:
  /// **'Cycle'**
  String get cycle;

  /// No description provided for @cycleNotFound.
  ///
  /// In en, this message translates to:
  /// **'Cycle not found'**
  String get cycleNotFound;

  /// No description provided for @cycleDashboard.
  ///
  /// In en, this message translates to:
  /// **'Cycle dashboard'**
  String get cycleDashboard;

  /// No description provided for @cycleIdentifier.
  ///
  /// In en, this message translates to:
  /// **'Cycle {value}'**
  String cycleIdentifier(String value);

  /// No description provided for @cycleOverview.
  ///
  /// In en, this message translates to:
  /// **'Cycle overview'**
  String get cycleOverview;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start date: {value}'**
  String startDate(String value);

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End date: {value}'**
  String endDate(String value);

  /// No description provided for @contributionSummary.
  ///
  /// In en, this message translates to:
  /// **'Contribution summary'**
  String get contributionSummary;

  /// No description provided for @demoContributionCounts.
  ///
  /// In en, this message translates to:
  /// **'Paid and unpaid member counts are not available for this cycle in the current demo data.'**
  String get demoContributionCounts;

  /// No description provided for @payoutInformation.
  ///
  /// In en, this message translates to:
  /// **'Payout information'**
  String get payoutInformation;

  /// No description provided for @payoutDescription.
  ///
  /// In en, this message translates to:
  /// **'View the assigned recipient order and the next payout for this cycle.'**
  String get payoutDescription;

  /// No description provided for @viewPayoutRotation.
  ///
  /// In en, this message translates to:
  /// **'View payout rotation'**
  String get viewPayoutRotation;

  /// No description provided for @stokvelInvitation.
  ///
  /// In en, this message translates to:
  /// **'Stokvel invitation'**
  String get stokvelInvitation;

  /// No description provided for @youAreInvited.
  ///
  /// In en, this message translates to:
  /// **'You have been invited!'**
  String get youAreInvited;

  /// No description provided for @invitationCode.
  ///
  /// In en, this message translates to:
  /// **'Your invitation code is:'**
  String get invitationCode;

  /// No description provided for @invitationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Invitation acceptance will be available when the invitation service is connected.'**
  String get invitationUnavailable;

  /// No description provided for @restoringSession.
  ///
  /// In en, this message translates to:
  /// **'Restoring your session...'**
  String get restoringSession;

  /// No description provided for @restoreSessionError.
  ///
  /// In en, this message translates to:
  /// **'Unable to restore your session.'**
  String get restoreSessionError;

  /// No description provided for @languageSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save language. Try again.'**
  String get languageSaveError;

  /// No description provided for @viewStokvels.
  ///
  /// In en, this message translates to:
  /// **'View stokvels'**
  String get viewStokvels;

  /// No description provided for @offlineSavedData.
  ///
  /// In en, this message translates to:
  /// **'Offline - showing saved data'**
  String get offlineSavedData;

  /// No description provided for @cachedSavedData.
  ///
  /// In en, this message translates to:
  /// **'Unable to refresh - showing saved data'**
  String get cachedSavedData;

  /// No description provided for @updatedJustNow.
  ///
  /// In en, this message translates to:
  /// **'Updated just now'**
  String get updatedJustNow;

  /// No description provided for @updatedMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Updated 1 minute ago} other{Updated {count} minutes ago}}'**
  String updatedMinutesAgo(int count);

  /// No description provided for @updatedHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Updated 1 hour ago} other{Updated {count} hours ago}}'**
  String updatedHoursAgo(int count);

  /// No description provided for @updatedDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Updated 1 day ago} other{Updated {count} days ago}}'**
  String updatedDaysAgo(int count);

  /// No description provided for @errorReference.
  ///
  /// In en, this message translates to:
  /// **'Reference: {reference}'**
  String errorReference(String reference);

  /// No description provided for @recordContribution.
  ///
  /// In en, this message translates to:
  /// **'Record contribution'**
  String get recordContribution;

  /// No description provided for @contributionAmount.
  ///
  /// In en, this message translates to:
  /// **'Contribution amount'**
  String get contributionAmount;

  /// No description provided for @contributionRecorded.
  ///
  /// In en, this message translates to:
  /// **'Contribution recorded'**
  String get contributionRecorded;

  /// No description provided for @contributionPending.
  ///
  /// In en, this message translates to:
  /// **'Contribution saved and waiting to be sent'**
  String get contributionPending;

  /// No description provided for @contributionRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Please wait before trying again'**
  String get contributionRateLimited;

  /// No description provided for @contributionAlreadyPaid.
  ///
  /// In en, this message translates to:
  /// **'This contribution has already been paid'**
  String get contributionAlreadyPaid;

  /// No description provided for @contributionCycleClosed.
  ///
  /// In en, this message translates to:
  /// **'This cycle is closed'**
  String get contributionCycleClosed;

  /// No description provided for @contributionConflict.
  ///
  /// In en, this message translates to:
  /// **'Contribution conflict. Check your records.'**
  String get contributionConflict;

  /// No description provided for @contributionRejected.
  ///
  /// In en, this message translates to:
  /// **'Contribution could not be accepted'**
  String get contributionRejected;

  /// No description provided for @contributionAuthenticationRequired.
  ///
  /// In en, this message translates to:
  /// **'Sign in again to continue'**
  String get contributionAuthenticationRequired;

  /// No description provided for @contributionExpired.
  ///
  /// In en, this message translates to:
  /// **'Pending contribution expired. Check your records.'**
  String get contributionExpired;

  /// No description provided for @contributionReviewRequired.
  ///
  /// In en, this message translates to:
  /// **'Contribution needs review before retrying'**
  String get contributionReviewRequired;

  /// No description provided for @contributionInvalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid positive amount'**
  String get contributionInvalidAmount;

  /// No description provided for @contributionSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to save contribution'**
  String get contributionSaveFailed;

  /// No description provided for @contributionProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing contribution'**
  String get contributionProcessing;

  /// No description provided for @retryPendingContributions.
  ///
  /// In en, this message translates to:
  /// **'Retry pending contributions'**
  String get retryPendingContributions;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'nso'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'nso':
      return AppLocalizationsNso();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
