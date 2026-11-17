import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api_session_provider.dart';
import '../data/demo_users.dart';

class SessionNotifier extends Notifier<DemoUser?> {
  int _sessionGeneration = 0;

  @override
  DemoUser? build() {
    return null;
  }

  /// Existing synchronous demo login retained for legacy tests.
  bool login(String email, String password) {
    final user = authenticateDemoUser(email, password);

    if (user == null) return false;

    ++_sessionGeneration;

    state = user;
    return true;
  }

  /// Real backend authentication for the running application.
  Future<void> loginWithApi(String email, String password) async {
    final generation = ++_sessionGeneration;

    final service = ref.read(apiSessionServiceProvider);

    final user = await service.login(email: email, password: password);

    if (generation != _sessionGeneration) {
      return;
    }

    state = user;
  }

  void logout() {
    ++_sessionGeneration;

    state = null;
  }

  /// Clears the UI session immediately, then revokes backend auth.
  Future<void> logoutWithApi() async {
    final service = ref.read(apiSessionServiceProvider);

    logout();

    await service.logout();
  }
}

final sessionProvider = NotifierProvider<SessionNotifier, DemoUser?>(
  SessionNotifier.new,
);
