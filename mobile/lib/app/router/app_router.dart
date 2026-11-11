import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/session/presentation/session_provider.dart';
import 'app_routes.dart';
import 'auth_redirect.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: const HomeRoute().location,
    routes: $appRoutes,
    redirect: (context, state) {
      return authRedirect(
        signedIn: ref.read(sessionProvider) != null,
        location: state.uri.toString(),
      );
    },
  );

  ref.listen(sessionProvider, (previous, next) {
    router.refresh();
  });

  ref.onDispose(router.dispose);

  return router;
});
