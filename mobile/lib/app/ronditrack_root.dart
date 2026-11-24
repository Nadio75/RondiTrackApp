import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/localization/language_provider.dart';
import '../core/localization/sepedi_localizations.dart';
import '../core/theme/rondi_theme.dart';
import '../features/session/presentation/session_startup.dart';
import '../features/session/presentation/session_startup_view.dart';
import '../l10n/generated/app_localizations.dart';
import 'router/app_router.dart';

class RondiTrackRoot extends ConsumerWidget {
  const RondiTrackRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final language = ref.watch(languageProvider);
    final locale = language.asData?.value ?? const Locale('en');

    return MaterialApp.router(
      title: 'RondiTrack',
      debugShowCheckedModeBanner: false,
      theme: RondiTheme.light,
      darkTheme: RondiTheme.dark,
      themeMode: ThemeMode.system,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        SepediMaterialLocalizationsDelegate(),
        SepediWidgetsLocalizationsDelegate(),
        SepediCupertinoLocalizationsDelegate(),
        ...AppLocalizations.localizationsDelegates,
      ],
      routerConfig: router,
      builder: (context, child) {
        return SessionStartup(
          child: SessionStartupView(child: child ?? const SizedBox.shrink()),
        );
      },
    );
  }
}
