import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'session_lifecycle.dart';

class SessionLifecycleNotifier extends Notifier<SessionLifecycle> {
  @override
  SessionLifecycle build() => SessionLifecycle.restoring;

  void markRestoring() {
    state = SessionLifecycle.restoring;
  }

  void markSignedIn() {
    state = SessionLifecycle.signedIn;
  }

  void markSignedOut() {
    state = SessionLifecycle.signedOut;
  }

  void markRetryRequired() {
    state = SessionLifecycle.retryRequired;
  }
}

final sessionLifecycleProvider =
    NotifierProvider<SessionLifecycleNotifier, SessionLifecycle>(
      SessionLifecycleNotifier.new,
    );
