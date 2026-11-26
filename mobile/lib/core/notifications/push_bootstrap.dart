import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'firebase_push_gateway.dart';
import 'push_config.dart';
import 'push_gateway.dart';

Future<PushGateway> initializePushGateway() async {
  final config = PushConfig.fromEnvironment();
  final enabled = config.enabled;

  debugPrint(
    '[RondiTrackPush] Bootstrap: '
    'configured=$enabled, web=$kIsWeb, '
    'platform=${defaultTargetPlatform.name}',
  );

  if (!enabled || kIsWeb) {
    return const DisabledPushGateway();
  }

  if (defaultTargetPlatform != TargetPlatform.android &&
      defaultTargetPlatform != TargetPlatform.iOS) {
    return const DisabledPushGateway();
  }

  debugPrint('[RondiTrackPush] Initializing Firebase.');

  await Firebase.initializeApp(options: config.options);

  debugPrint('[RondiTrackPush] Firebase initialized.');

  final messaging = FirebaseMessaging.instance;

  await messaging.setAutoInitEnabled(false);

  debugPrint('[RondiTrackPush] Native gateway enabled.');

  return FirebasePushGateway(messaging);
}
