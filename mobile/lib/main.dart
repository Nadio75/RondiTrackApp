import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:ronditrack/core/config/app_config.dart';

import 'app/ronditrack_root.dart';

void main() {
  const flavor = String.fromEnvironment('APP_FLAVOR');
  const apiUrl = String.fromEnvironment('API_BASE_URL');

  validateAppConfig(
    flavor: flavor,
    apiUrl: apiUrl,
    nativeFlavor: kIsWeb ? null : appFlavor,
    runningOnWeb: kIsWeb,
  );

  runApp(const ProviderScope(child: RondiTrackApp()));
  //read up on this
}

class RondiTrackApp extends StatelessWidget {
  const RondiTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const RondiTrackRoot();
  }
}
