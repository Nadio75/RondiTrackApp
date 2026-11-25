import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'push_destination.dart';

abstract interface class LocalNotificationService {
  Stream<PushDestination> get opened;

  Future<PushDestination?> initialize();

  Future<void> show(Map<String, dynamic> data);

  Future<void> clear();

  void dispose();
}

class DisabledLocalNotificationService implements LocalNotificationService {
  const DisabledLocalNotificationService();

  @override
  Stream<PushDestination> get opened => const Stream.empty();

  @override
  Future<PushDestination?> initialize() async => null;

  @override
  Future<void> show(Map<String, dynamic> data) async {}

  @override
  Future<void> clear() async {}

  @override
  void dispose() {}
}

class AndroidLocalNotificationService implements LocalNotificationService {
  AndroidLocalNotificationService(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  final _opened = StreamController<PushDestination>.broadcast();

  static const channelId = 'ronditrack_updates';
  static const channelName = 'RondiTrack updates';

  bool _initialized = false;
  int _nextId = 0;

  @override
  Stream<PushDestination> get opened => _opened.stream;

  PushDestination? _decode(String? payload) {
    if (payload == null || payload.length > 1024) {
      return null;
    }

    try {
      final data = jsonDecode(payload);

      if (data is! Map<String, dynamic>) return null;

      return PushDestination.parse(data);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<PushDestination?> initialize() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return null;
    }

    if (_initialized) return null;

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: (response) {
        final destination = _decode(response.payload);

        if (destination != null && !_opened.isClosed) {
          _opened.add(destination);
        }
      },
    );

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        channelId,
        channelName,
        description: 'General application updates',
        importance: Importance.high,
      ),
    );

    _initialized = true;

    final launch = await _plugin.getNotificationAppLaunchDetails();

    if (launch?.didNotificationLaunchApp == true) {
      return _decode(launch?.notificationResponse?.payload);
    }

    return null;
  }

  @override
  Future<void> show(Map<String, dynamic> data) async {
    if (!_initialized) return;

    final destination = PushDestination.parse(data);

    if (destination == null) return;

    await _plugin.show(
      id: ++_nextId,
      title: 'RondiTrack',
      body: 'You have a new update.',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: 'General application updates',
          importance: Importance.high,
          priority: Priority.high,
          visibility: NotificationVisibility.private,
        ),
      ),
      payload: jsonEncode({
        'type': 'contribution_confirmed',
        'stokvelId': destination.stokvelId,
        'cycleId': destination.cycleId,
      }),
    );
  }

  @override
  Future<void> clear() async {
    if (_initialized) {
      await _plugin.cancelAll();
    }
  }

  @override
  void dispose() {
    unawaited(_opened.close());
  }
}
