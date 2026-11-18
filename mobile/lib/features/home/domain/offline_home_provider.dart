import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/offline/home_cache_repository.dart';
import '../../../core/offline/offline_home_providers.dart';
import '../../session/presentation/session_lifecycle.dart';
import '../../session/presentation/session_lifecycle_provider.dart';
import '../../session/presentation/session_provider.dart';

final authenticatedHomeProvider =
    FutureProvider.autoDispose<CachedHomeSnapshot?>((ref) async {
      final user = ref.watch(sessionProvider);
      final lifecycle = ref.watch(sessionLifecycleProvider);

      if (user == null || lifecycle != SessionLifecycle.signedIn) {
        return null;
      }
      final accountId = user.id;
      final sessionGeneration = ref
          .read(sessionProvider.notifier)
          .sessionGeneration;
      var active = true;

      ref.onDispose(() {
        active = false;
      });

      bool isSessionCurrent() {
        if (!active) return false;

        final currentUser = ref.read(sessionProvider);
        final currentLifecycle = ref.read(sessionLifecycleProvider);
        final currentGeneration = ref
            .read(sessionProvider.notifier)
            .sessionGeneration;

        return currentUser != null &&
            currentUser.id == accountId &&
            currentLifecycle == SessionLifecycle.signedIn &&
            currentGeneration == sessionGeneration;
      }

      final service = ref.watch(offlineHomeServiceProvider);

      final snapshot = await service.loadWithFallback(
        accountId,
        isSessionCurrent: isSessionCurrent,
      );

      if (!isSessionCurrent()) {
        return null;
      }

      return snapshot;
    });
