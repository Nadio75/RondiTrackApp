import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../session/presentation/session_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const CircleAvatar(radius: 36, child: Icon(Icons.person, size: 36)),
          const SizedBox(height: 20),
          Text(
            user?.name ?? 'Guest',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(user?.email ?? '', textAlign: TextAlign.center),
          if (kDebugMode) ...[
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
              ref.read(sessionProvider.notifier).logout();
            },
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}
