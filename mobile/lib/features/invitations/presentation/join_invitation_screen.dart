import '../../../core/localization/localization_context.dart';

import 'package:flutter/material.dart';

class JoinInvitationScreen extends StatelessWidget {
  const JoinInvitationScreen({super.key, required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.stokvelInvitation)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.group_add_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.youAreInvited,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(l10n.invitationCode, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                SelectableText(
                  code,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(l10n.invitationUnavailable, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
