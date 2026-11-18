import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/offline/offline_home_providers.dart';
import '../data/api_session_provider.dart';
import '../data/demo_users.dart';
import 'session_lifecycle_provider.dart';
import 'session_origin_provider.dart';

class SessionNotifier extends Notifier<DemoUser?> {
  int _sessionGeneration = 0;

  /// Changes whenever a login, restoration, or logout starts.
  int get sessionGeneration => _sessionGeneration;

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
    ref.read(sessionOriginProvider.notifier).markDemo();
    ref.read(sessionLifecycleProvider.notifier).markSignedIn();
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
    ref.read(sessionOriginProvider.notifier).markApi();
    ref.read(sessionLifecycleProvider.notifier).markSignedIn();
  }

  /// Attempts to restore an existing backend session.
  ///
  /// A generation check prevents a late response from restoring
  /// a session after logout or another authentication operation.
  Future<void> restoreWithApi() async {
    final generation = ++_sessionGeneration;

    ref.read(sessionOriginProvider.notifier).clear();
    ref.read(sessionLifecycleProvider.notifier).markRestoring();

    final service = ref.read(apiSessionServiceProvider);

    try {
      final user = await service.restore();

      if (generation != _sessionGeneration) return;

      state = user;
      ref.read(sessionOriginProvider.notifier).markApi();
      ref.read(sessionLifecycleProvider.notifier).markSignedIn();
    } on DioException catch (error) {
      if (generation != _sessionGeneration) return;

      if (error.response?.statusCode == 401 ||
          error.response?.statusCode == 403) {
        state = null;
        ref.read(sessionOriginProvider.notifier).clear();
        ref.read(sessionLifecycleProvider.notifier).markSignedOut();
      } else {
        ref.read(sessionLifecycleProvider.notifier).markRetryRequired();
      }
    } catch (_) {
      if (generation != _sessionGeneration) return;

      ref.read(sessionLifecycleProvider.notifier).markRetryRequired();
    }
  }

  void logout() {
    ++_sessionGeneration;

    state = null;
    ref.read(sessionOriginProvider.notifier).clear();
    ref.read(sessionLifecycleProvider.notifier).markSignedOut();
  }

  /// Clears the UI session immediately, then revokes backend auth.
  Future<void> logoutWithApi() async {
    final accountId = state?.id;
    final service = ref.read(apiSessionServiceProvider);

    // Immediately invalidate in-flight requests and signed-in UI.
    logout();

    Object? cleanupError;
    StackTrace? cleanupStackTrace;

    if (accountId != null) {
      try {
        await ref.read(homeCacheRepositoryProvider).clearAccount(accountId);
      } catch (error, stackTrace) {
        cleanupError = error;
        cleanupStackTrace = stackTrace;
      }
    }

    // Always attempt backend logout, even if local cleanup fails.
    await service.logout();

    if (cleanupError != null) {
      Error.throwWithStackTrace(cleanupError, cleanupStackTrace!);
    }
  }
}

final sessionProvider = NotifierProvider<SessionNotifier, DemoUser?>(
  SessionNotifier.new,
);
