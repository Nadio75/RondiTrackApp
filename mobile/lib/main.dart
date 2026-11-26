import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:ronditrack/core/config/app_config.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'app/ronditrack_root.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'core/notifications/local_notification_service.dart';
import 'core/notifications/local_notification_provider.dart';
import 'core/notifications/push_bootstrap.dart';
import 'core/notifications/push_destination.dart';
import 'core/notifications/push_providers.dart';

Future<void> main() async {
  const flavor = String.fromEnvironment('APP_FLAVOR');
  const apiUrl = String.fromEnvironment('API_BASE_URL');
  const sentryDsn = String.fromEnvironment('SENTRY_DSN');
  const sentryRelease = String.fromEnvironment('SENTRY_RELEASE');
  const sentryDist = String.fromEnvironment('SENTRY_DIST');

  validateAppConfig(
    flavor: flavor,
    apiUrl: apiUrl,
    nativeFlavor: kIsWeb ? null : appFlavor,
    runningOnWeb: kIsWeb,
  );

  Future<void> startApplication() async {
    WidgetsFlutterBinding.ensureInitialized();

    final gateway = await initializePushGateway();
    final message = await gateway.initialMessage();

    LocalNotificationService localNotifications =
        const DisabledLocalNotificationService();

    PushDestination? localDestination;

    if (gateway.enabled &&
        !kIsWeb &&
        defaultTargetPlatform == TargetPlatform.android) {
      final service = AndroidLocalNotificationService(
        FlutterLocalNotificationsPlugin(),
      );

      try {
        localDestination = await service.initialize();
        localNotifications = service;
      } catch (_) {
        service.dispose();
        // Local notification failure must not prevent startup.
      }
    }

    final destination = message == null
        ? localDestination
        : PushDestination.parse(message) ?? localDestination;

    runApp(
      ProviderScope(
        overrides: [
          pushGatewayProvider.overrideWithValue(gateway),
          localNotificationServiceProvider.overrideWith((ref) {
            ref.onDispose(localNotifications.dispose);
            return localNotifications;
          }),
          initialPushLocationProvider.overrideWithValue(destination?.location),
        ],
        child: const RondiTrackApp(),
      ),
    );
  }

  if (sentryDsn.isEmpty) {
    await startApplication();
    return;
  }

  await SentryFlutter.init(
    (options) {
      options.dsn = sentryDsn;
      options.environment = flavor;

      if (sentryRelease.isNotEmpty) {
        options.release = sentryRelease;
      }

      if (sentryDist.isNotEmpty) {
        options.dist = sentryDist;
      }
      options.sendDefaultPii = false;
      options.tracesSampleRate = 0.0;
      options.attachScreenshot = false;
      options.attachViewHierarchy = false;
      options.maxBreadcrumbs = 0;

      options.beforeSend = (event, hint) {
        // Send only a fixed diagnostic message.
        // Do not forward the original exception or user context.
        return SentryEvent(
          eventId: event.eventId,
          timestamp: event.timestamp,
          level: SentryLevel.error,
          environment: flavor,
          message: SentryMessage('RondiTrack application error'),
        );
      };
    },
    appRunner: () async {
      await startApplication();

      if (kDebugMode &&
          flavor == 'dev' &&
          const bool.fromEnvironment('SENTRY_TEST_EVENT')) {
        await Sentry.captureMessage(
          'RondiTrack diagnostic test',
          level: SentryLevel.error,
        );
      }
    },
  );
}

class RondiTrackApp extends StatelessWidget {
  const RondiTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const RondiTrackRoot();
  }
}
