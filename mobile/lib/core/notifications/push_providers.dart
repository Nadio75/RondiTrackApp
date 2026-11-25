import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/dio_provider.dart';
import 'device_registration_api.dart';
import 'device_registration_coordinator.dart';
import 'push_gateway.dart';

final pushGatewayProvider = Provider<PushGateway>((ref) {
  return const DisabledPushGateway();
});

final deviceRegistrationApiProvider = Provider<DeviceRegistrationApi>((ref) {
  return DioDeviceRegistrationApi(ref.watch(dioProvider));
});

final deviceRegistrationCoordinatorProvider =
    Provider<DeviceRegistrationCoordinator>((ref) {
      final coordinator = DeviceRegistrationCoordinator(
        gateway: ref.watch(pushGatewayProvider),
        api: ref.watch(deviceRegistrationApiProvider),
      );

      ref.onDispose(coordinator.dispose);

      return coordinator;
    });

final initialPushLocationProvider = Provider<String?>((ref) {
  return null;
});
