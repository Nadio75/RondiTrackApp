import 'dart:async';

import 'package:alchemist/alchemist.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  return AlchemistConfig.runWithConfig(
    config: AlchemistConfig(
      platformGoldensConfig: PlatformGoldensConfig(
        enabled: true,
        platforms: {HostPlatform.windows},
      ),
      ciGoldensConfig: const CiGoldensConfig(enabled: true),
    ),
    run: testMain,
  );
}
