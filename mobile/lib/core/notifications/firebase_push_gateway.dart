import 'package:firebase_messaging/firebase_messaging.dart';

import 'push_gateway.dart';

class FirebasePushGateway implements PushGateway {
  FirebasePushGateway(this._messaging);

  final FirebaseMessaging _messaging;

  @override
  bool get enabled => true;

  @override
  Stream<String> get onRegistered => _messaging.onRegistered;

  @override
  Stream<Map<String, dynamic>> get foregroundMessages =>
      FirebaseMessaging.onMessage.map((message) => message.data);

  @override
  Stream<Map<String, dynamic>> get openedMessages =>
      FirebaseMessaging.onMessageOpenedApp.map((message) => message.data);

  @override
  Future<Map<String, dynamic>?> initialMessage() async {
    final message = await _messaging.getInitialMessage();
    return message?.data;
  }

  @override
  Future<void> register() => _messaging.register();

  @override
  Future<void> unregister() => _messaging.unregister();

  @override
  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission();

    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }
}
