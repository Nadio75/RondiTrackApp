import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:ronditrack/core/config/app_config.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'app/ronditrack_root.dart';

Future<void> main() async {
  const flavor = String.fromEnvironment('APP_FLAVOR');
  const apiUrl = String.fromEnvironment('API_BASE_URL');
  const sentryDsn = String.fromEnvironment('SENTRY_DSN');

  validateAppConfig(
    flavor: flavor,
    apiUrl: apiUrl,
    nativeFlavor: kIsWeb ? null : appFlavor,
    runningOnWeb: kIsWeb,
  );

  if (sentryDsn.isEmpty) {
    runApp(const ProviderScope(child: RondiTrackApp()));
    return;
  }

  await SentryFlutter.init(
    (options) {
      options.dsn = sentryDsn;
      options.environment = flavor;
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
      runApp(const ProviderScope(child: RondiTrackApp()));

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
