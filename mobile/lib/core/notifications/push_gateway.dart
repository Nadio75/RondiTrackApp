abstract interface class PushGateway {
  bool get enabled;

  Stream<String> get onRegistered;

  Stream<Map<String, dynamic>> get foregroundMessages;

  Stream<Map<String, dynamic>> get openedMessages;

  Future<Map<String, dynamic>?> initialMessage();

  Future<void> register();

  Future<void> unregister();

  Future<bool> requestPermission();
}

class DisabledPushGateway implements PushGateway {
  const DisabledPushGateway();

  @override
  bool get enabled => false;

  @override
  Stream<String> get onRegistered => const Stream.empty();

  @override
  Stream<Map<String, dynamic>> get foregroundMessages => const Stream.empty();

  @override
  Stream<Map<String, dynamic>> get openedMessages => const Stream.empty();

  @override
  Future<Map<String, dynamic>?> initialMessage() async => null;

  @override
  Future<void> register() async {}

  @override
  Future<void> unregister() async {}

  @override
  Future<bool> requestPermission() async => false;
}
