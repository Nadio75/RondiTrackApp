import '../../../core/localization/localization_context.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'session_lifecycle.dart';
import 'session_lifecycle_provider.dart';
import 'session_provider.dart';

class SessionStartupView extends ConsumerWidget {
  const SessionStartupView({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final lifecycle = ref.watch(sessionLifecycleProvider);

    if (lifecycle == SessionLifecycle.restoring) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(l10n.restoringSession),
            ],
          ),
        ),
      );
    }

    if (lifecycle == SessionLifecycle.retryRequired) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.restoreSessionError),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(sessionProvider.notifier).restoreWithApi();
                },
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    return child;
  }
}
