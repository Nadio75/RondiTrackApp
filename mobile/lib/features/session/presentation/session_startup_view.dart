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
    final lifecycle = ref.watch(sessionLifecycleProvider);

    if (lifecycle == SessionLifecycle.restoring) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Restoring your session...'),
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
              const Text('Unable to restore your session.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(sessionProvider.notifier).restoreWithApi();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return child;
  }
}
