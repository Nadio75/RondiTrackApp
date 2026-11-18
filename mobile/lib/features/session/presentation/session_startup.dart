import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'session_provider.dart';

/// Starts backend session restoration when mounted.
///
/// The child is responsible for presenting the appropriate
/// loading, retry, or authenticated experience.
class SessionStartup extends ConsumerStatefulWidget {
  const SessionStartup({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<SessionStartup> createState() => _SessionStartupState();
}

class _SessionStartupState extends ConsumerState<SessionStartup> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) return;

      // Do not restore over an already authenticated session.
      if (ref.read(sessionProvider) != null) return;

      ref.read(sessionProvider.notifier).restoreWithApi();
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
