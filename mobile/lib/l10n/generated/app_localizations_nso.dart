// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Pedi Northern Sotho Sepedi (`nso`).
class AppLocalizationsNso extends AppLocalizations {
  AppLocalizationsNso([String locale = 'nso']) : super(locale);

  @override
  String get appName => 'RondiTrack';

  @override
  String get home => 'Gae';

  @override
  String get stokvels => 'Mekgatlo ya poloko';

  @override
  String get activity => 'Ditiro';

  @override
  String get profile => 'Profaele';

  @override
  String get language => 'Polelo';

  @override
  String get appLanguage => 'Polelo ya tirišo';

  @override
  String get chooseLanguage => 'Kgetha polelo ye o e ratago';

  @override
  String get english => 'Seisemane';

  @override
  String get sepedi => 'Sepedi';

  @override
  String get saveLanguage => 'Boloka polelo';

  @override
  String get languageChanged => 'Polelo e fetotšwe ka katlego';

  @override
  String get guest => 'Moeng';

  @override
  String get signOut => 'Tšwa';

  @override
  String get logout => 'Tšwa';

  @override
  String get login => 'Tsena';

  @override
  String get email => 'Imeile';

  @override
  String get password => 'Lentšuphetišo';

  @override
  String get signInSubtitle => 'Tsena go laola mokgatlo wa gago wa poloko';

  @override
  String get pleaseSignIn => 'Hle, tsena';

  @override
  String get invalidCredentials => 'Imeile goba lentšuphetišo le fošagetše';

  @override
  String get tooManyAttempts =>
      'Maiteko a mantši kudu. Hle, leka gape ka morago.';

  @override
  String get signInConnectionError =>
      'Ga o kgone go tsena. Lekola kgokagano gomme o leke gape.';

  @override
  String get signInError => 'Ga o kgone go tsena. Hle, leka gape.';

  @override
  String get stokvelOverview => 'Kakaretšo ya mekgatlo ya gago ya poloko';

  @override
  String get noStokvels => 'Ga se wa hlwa o tsenela mokgatlo wa poloko.';

  @override
  String get noHomeData => 'Ga go na tshedimošo ya letlakala la gae gabjale.';

  @override
  String get loadStokvelsError =>
      'Ga go kgonege go laetša mekgatlo ya gago ya poloko.';

  @override
  String get retry => 'Leka gape';

  @override
  String get tryAgain => 'Leka gape';

  @override
  String get loading => 'E a laetša...';

  @override
  String get offline => 'Ga go na kgokagano';

  @override
  String get cancel => 'Khansela';

  @override
  String get save => 'Boloka';

  @override
  String get close => 'Tswalela';

  @override
  String get treasurer => 'Ramatlotlo';

  @override
  String get chairperson => 'Modulasetulo';

  @override
  String get member => 'Leloko';

  @override
  String get paid => 'E lefilwe';

  @override
  String get pending => 'E sa letetšwe';

  @override
  String get inArrears => 'E na le sekoloto';

  @override
  String get upToDate => 'Ditefo di feletše';

  @override
  String get unknown => 'Ga e tsebje';

  @override
  String welcome(String name) {
    return 'O amogetšwe, $name!';
  }

  @override
  String monthlyContribution(String amount) {
    return 'Moneelo wa kgwedi: $amount';
  }

  @override
  String roleLabel(String role) {
    return 'Maikarabelo: $role';
  }

  @override
  String contributionStatus(String status) {
    return 'Maemo a moneelo: $status';
  }

  @override
  String lastUpdated(String date) {
    return 'E mpshafaditšwe la mafelelo: $date';
  }

  @override
  String contributionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Meneelo ye $count',
      one: 'Moneelo o tee',
      zero: 'Ga go na meneelo',
    );
    return '$_temp0';
  }

  @override
  String get activityEmpty =>
      'Ditiro tša mokgatlo wa gago wa poloko di tla tšwelela mo.';

  @override
  String get myStokvels => 'Mekgatlo ya ka ya poloko';

  @override
  String get loadStokvelsListError =>
      'Ga go kgonege go laetša mekgatlo ya poloko.';

  @override
  String get stokvel => 'Mokgatlo wa poloko';

  @override
  String get loadStokvelDetailsError =>
      'Ga go kgonege go laetša dintlha tša mokgatlo wa poloko.';

  @override
  String get stokvelNotFound => 'Mokgatlo wa poloko ga se wa hwetšwa';

  @override
  String get switchStokvel => 'Fetola mokgatlo wa poloko';

  @override
  String get monthlyContributionTitle => 'Moneelo wa kgwedi';

  @override
  String yourRole(String value) {
    return 'Maikarabelo a gago: $value';
  }

  @override
  String get currentCycle => 'Modikologo wa bjale';

  @override
  String statusLabel(String value) {
    return 'Maemo: $value';
  }

  @override
  String get viewCurrentCycle => 'Lebelela modikologo wa bjale';

  @override
  String get totalPaidContributions => 'Palomoka ya meneelo ye e lefilwego';

  @override
  String get yourPaidContributions => 'Meneelo ya gago ye e lefilwego';

  @override
  String get memberContributions => 'Meneelo ya maloko';

  @override
  String get yourContributions => 'Meneelo ya gago';

  @override
  String get noContributionsFound => 'Ga go na meneelo ye e hweditšwego.';

  @override
  String get unknownMember => 'Leloko leo le sa tsebjego';

  @override
  String get selectStokvel =>
      'Kgetha mokgatlo wa poloko go bona dintlha tša wona.';

  @override
  String get payoutRotation => 'Tatelano ya ditefo';

  @override
  String get payoutEmpty => 'Ga go na tatelano ya ditefo ya modikologo wo.';

  @override
  String get payoutLoadError => 'Ga go kgonege go laetša tatelano ya ditefo.';

  @override
  String get payoutSchedule => 'Lenaneo la ditefo';

  @override
  String get recipientOrderDescription =>
      'Baamogedi ba bontšhwa go ya ka tatelano ya bona ya ditefo.';

  @override
  String get nextRecipient => 'Moamogedi yo a latelago';

  @override
  String get rotationOrder => 'Tatelano ya modikologo';

  @override
  String get next => 'Latelago';

  @override
  String get upcoming => 'E tlago';

  @override
  String get active => 'E a šoma';

  @override
  String get closed => 'E tswaletšwe';

  @override
  String get overdue => 'E fetilwe ke nako';

  @override
  String get nextPayoutRecipient => 'Moamogedi wa tefo yo a latelago';

  @override
  String scheduled(String value) {
    return 'E beakantšwe: $value';
  }

  @override
  String get cycle => 'Modikologo';

  @override
  String get cycleNotFound => 'Modikologo ga se wa hwetšwa';

  @override
  String get cycleDashboard => 'Kakaretšo ya modikologo';

  @override
  String cycleIdentifier(String value) {
    return 'Modikologo $value';
  }

  @override
  String get cycleOverview => 'Kakaretšo ya modikologo';

  @override
  String startDate(String value) {
    return 'Letšatši la go thoma: $value';
  }

  @override
  String endDate(String value) {
    return 'Letšatši la go fetša: $value';
  }

  @override
  String get contributionSummary => 'Kakaretšo ya meneelo';

  @override
  String get demoContributionCounts =>
      'Palo ya maloko ao a lefilego le ao a sa lefago ga e hwetšagale mo tshedimošong ya teko ya modikologo wo.';

  @override
  String get payoutInformation => 'Tshedimošo ya ditefo';

  @override
  String get payoutDescription =>
      'Lebelela tatelano ya baamogedi le tefo ye e latelago ya modikologo wo.';

  @override
  String get viewPayoutRotation => 'Lebelela tatelano ya ditefo';

  @override
  String get stokvelInvitation => 'Taletšo ya mokgatlo wa poloko';

  @override
  String get youAreInvited => 'O laleditšwe!';

  @override
  String get invitationCode => 'Khoutu ya gago ya taletšo ke:';

  @override
  String get invitationUnavailable =>
      'Go amogela taletšo go tla kgonega ge tirelo ya ditaletšo e kgokagantšwe.';

  @override
  String get restoringSession => 'Go tsošološwa lenaneo la gago...';

  @override
  String get restoreSessionError =>
      'Ga go kgonege go tsošološa lenaneo la gago.';

  @override
  String get languageSaveError => 'Ga go kgonege go boloka polelo. Leka gape.';
}
