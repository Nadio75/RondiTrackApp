import 'app_version_tile.dart';
import '../../../core/localization/localization_context.dart';
import '../../../core/localization/language_selector.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../session/presentation/demo_persona_config.dart';
import '../../session/presentation/session_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profile)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CircleAvatar(radius: 36, child: Icon(Icons.person, size: 36)),
            const SizedBox(height: 20),
            Text(
              user?.name ?? l10n.guest,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(user?.email ?? '', textAlign: TextAlign.center),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),
            const LanguageSelector(),
            const SizedBox(height: 12),
            const Divider(),
            const AppVersionTile(),
            if (kDebugMode && ref.watch(demoPersonasEnabledProvider)) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),
              Text(
                'Development personas',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Switch demo accounts to verify role-based access. '
                'Available in debug builds only.',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      ref
                          .read(sessionProvider.notifier)
                          .login('lerato@example.com', 'testpassword123');
                    },
                    child: const Text('Lerato - Treasurer'),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      ref
                          .read(sessionProvider.notifier)
                          .login('thabo@example.com', 'testpassword123');
                    },
                    child: const Text('Thabo - Member'),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      ref
                          .read(sessionProvider.notifier)
                          .login('naledi@example.com', 'testpassword123');
                    },
                    child: const Text('Naledi - Non-member'),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                ref.read(sessionProvider.notifier).logoutWithApi();
              },
              icon: const Icon(Icons.logout),
              label: Text(l10n.signOut),
            ),
          ],
        ),
      ),
    );
  }
}
