import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/demo_users.dart';

class SessionNotifier extends Notifier<DemoUser?> {
  @override
  DemoUser? build() => null;

  bool login(String email, String password) {
    final user = authenticateDemoUser(email, password);

    if (user == null) return false;

    state = user;
    return true;
  }

  void logout() {
    state = null;
  }
}

final sessionProvider = NotifierProvider<SessionNotifier, DemoUser?>(
  SessionNotifier.new,
);
