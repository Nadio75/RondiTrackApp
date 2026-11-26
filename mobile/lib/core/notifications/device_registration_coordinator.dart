import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'device_registration_api.dart';
import 'push_gateway.dart';

class DeviceRegistrationCoordinator {
  DeviceRegistrationCoordinator({required this.gateway, required this.api});

  final PushGateway gateway;
  final DeviceRegistrationApi api;

  StreamSubscription<String>? _subscription;
  String? _installationId;
  int _epoch = 0;

  Future<void> _pending = Future<void>.value();

  Future<void> start({
    required int generation,
    required bool Function() isSessionCurrent,
  }) async {
    if (!gateway.enabled) {
      debugPrint('[RondiTrackPush] Gateway disabled.');
      return;
    }

    debugPrint('[RondiTrackPush] Starting registration.');

    final epoch = ++_epoch;

    await _subscription?.cancel();

    if (epoch != _epoch || !isSessionCurrent()) return;

    _subscription = gateway.onRegistered.listen(
      (installationId) {
        if (epoch != _epoch || !isSessionCurrent()) return;

        if (!RegExp(r'^[A-Za-z0-9_-]{1,256}$').hasMatch(installationId)) {
          return;
        }

        debugPrint('[RondiTrackPush] Registration event received.');

        _installationId = installationId;

        _pending = _pending.then((_) async {
          if (epoch != _epoch || !isSessionCurrent()) return;

          try {
            debugPrint('[RondiTrackPush] Registering with API.');

            await api.register(installationId, generation);

            debugPrint('[RondiTrackPush] API registration successful.');
          } on DioException catch (error) {
            debugPrint(
              '[RondiTrackPush] API registration failed: '
              '${error.type.name}, HTTP ${error.response?.statusCode}',
            );
          } catch (error) {
            debugPrint(
              '[RondiTrackPush] API registration failed: '
              '${error.runtimeType}',
            );
          }
        });
      },
      onError: (Object error) {
        debugPrint(
          '[RondiTrackPush] Registration stream error: '
          '${error.runtimeType}',
        );
      },
    );

    try {
      debugPrint('[RondiTrackPush] Requesting Firebase registration.');

      await gateway.register().timeout(const Duration(seconds: 30));

      debugPrint('[RondiTrackPush] Firebase register call completed.');
    } catch (error) {
      debugPrint(
        '[RondiTrackPush] Firebase registration failed: '
        '${error.runtimeType}',
      );
    }
  }

  Future<void> stop({required int generation}) async {
    ++_epoch;

    await _subscription?.cancel();
    _subscription = null;

    final installationId = _installationId;
    _installationId = null;

    try {
      await _pending.timeout(const Duration(seconds: 3));
    } catch (_) {
      // Continue with best-effort cleanup.
    }

    if (installationId != null) {
      try {
        await api
            .unregister(installationId, generation)
            .timeout(const Duration(seconds: 3));
      } catch (_) {
        // Network failures must not prevent logout.
      }
    }

    if (gateway.enabled) {
      try {
        await gateway.unregister().timeout(const Duration(seconds: 3));
      } catch (_) {
        // Continue signing out.
      }
    }
  }

  void dispose() {
    ++_epoch;
    unawaited(_subscription?.cancel());
  }
}
