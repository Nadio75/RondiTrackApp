import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

final appVersionProvider = FutureProvider<PackageInfo>((ref) {
  return PackageInfo.fromPlatform();
});

const configuredAppFlavor = String.fromEnvironment(
  'APP_FLAVOR',
  defaultValue: 'unknown',
);

String appEnvironmentLabel(String flavor) {
  return switch (flavor) {
    'dev' => 'Development',
    'staging' => 'Staging',
    'prod' => 'Production',
    _ => 'Unknown',
  };
}
