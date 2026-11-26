import 'dart:async';

import '../../core/notifications/local_notification_provider.dart';
import '../../core/notifications/push_destination.dart';
import '../../core/notifications/push_providers.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/session/presentation/session_lifecycle.dart';
import '../../features/session/presentation/session_lifecycle_provider.dart';
import '../../features/session/presentation/session_provider.dart';
import 'app_routes.dart';
import 'auth_redirect.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation:
        ref.read(initialPushLocationProvider) ?? const HomeRoute().location,
    routes: $appRoutes,
    redirect: (context, state) {
      final lifecycle = ref.read(sessionLifecycleProvider);

      return authRedirect(
        signedIn: ref.read(sessionProvider) != null,
        location: state.uri.toString(),
        restoring:
            lifecycle == SessionLifecycle.restoring ||
            lifecycle == SessionLifecycle.retryRequired,
      );
    },
  );

  ref.listen(sessionProvider, (previous, next) {
    router.refresh();
  });

  ref.listen(sessionLifecycleProvider, (previous, next) {
    router.refresh();
  });

  final gateway = ref.read(pushGatewayProvider);

  final openedSubscription = gateway.openedMessages.listen((message) {
    final destination = PushDestination.parse(message);

    if (destination != null) {
      router.go(destination.location);
    }
  });

  ref.onDispose(() {
    unawaited(openedSubscription.cancel());
  });

  final localNotifications = ref.read(localNotificationServiceProvider);

  final localOpenedSubscription = localNotifications.opened.listen((
    destination,
  ) {
    router.go(destination.location);
  });

  final foregroundSubscription = gateway.foregroundMessages.listen((
    message,
  ) async {
    if (ref.read(sessionProvider) == null) return;

    final destination = PushDestination.parse(message);

    if (destination == null) return;

    ref.read(notificationRefreshProvider.notifier).refresh();

    try {
      await localNotifications.show(message);
    } catch (_) {
      // Notification display failure must not affect the UI.
    }
  });

  ref.onDispose(() {
    unawaited(localOpenedSubscription.cancel());
    unawaited(foregroundSubscription.cancel());
  });

  ref.onDispose(router.dispose);

  return router;
});
