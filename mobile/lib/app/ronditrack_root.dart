import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router/app_router.dart';
import '../core/theme/rondi_theme.dart';
import '../features/session/presentation/session_startup.dart';
import '../features/session/presentation/session_startup_view.dart';

class RondiTrackRoot extends ConsumerWidget {
  const RondiTrackRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'RondiTrack',
      debugShowCheckedModeBanner: false,
      theme: RondiTheme.light,
      darkTheme: RondiTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
      builder: (context, child) {
        return SessionStartup(
          child: SessionStartupView(child: child ?? const SizedBox.shrink()),
        );
      },
    );
  }
}
