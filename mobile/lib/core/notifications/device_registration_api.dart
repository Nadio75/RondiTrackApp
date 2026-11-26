import 'package:dio/dio.dart';

abstract interface class DeviceRegistrationApi {
  Future<void> register(String installationId, int generation);

  Future<void> unregister(String installationId, int generation);
}

class DioDeviceRegistrationApi implements DeviceRegistrationApi {
  DioDeviceRegistrationApi(this._dio);

  final Dio _dio;

  Options _options(int generation) => Options(
    extra: {'requiredAuthSessionGeneration': generation},
    sendTimeout: const Duration(seconds: 3),
    receiveTimeout: const Duration(seconds: 3),
  );

  @override
  Future<void> register(String installationId, int generation) async {
    await _dio.post<void>(
      '/api/v1/me/devices',
      data: {'installationId': installationId},
      options: _options(generation),
    );
  }

  @override
  Future<void> unregister(String installationId, int generation) async {
    await _dio.delete<void>(
      '/api/v1/me/devices/${Uri.encodeComponent(installationId)}',
      options: _options(generation),
    );
  }
}
