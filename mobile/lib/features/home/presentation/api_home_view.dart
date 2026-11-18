import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/offline_home_provider.dart';

class ApiHomeView extends ConsumerWidget {
  const ApiHomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final home = ref.watch(authenticatedHomeProvider);

    return RefreshIndicator(
      onRefresh: () {
        return ref.refresh(authenticatedHomeProvider.future);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Your stokvel overview',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          switch (home) {
            AsyncData(:final value) when value == null => const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('No Home data is available yet.'),
              ),
            ),
            AsyncData(:final value)
                when value != null && value.stokvels.isEmpty =>
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('You have not joined any stokvels yet.'),
                ),
              ),
            AsyncData(:final value) when value != null => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Last updated: ${value.updatedAtUtc.toLocal()}'),
                const SizedBox(height: 12),
                for (final stokvel in value.stokvels)
                  Card(
                    child: ListTile(
                      title: Text(stokvel.name),
                      subtitle: Text('Role: ${stokvel.role}'),
                    ),
                  ),
              ],
            ),
            AsyncError() => Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text('Could not load your stokvels.'),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () async {
                        try {
                          final refreshFuture = ref.refresh(
                            authenticatedHomeProvider.future,
                          );
                          await refreshFuture;
                        } catch (_) {
                          // The provider displays the error state.
                        }
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
            _ => const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            ),
          },
        ],
      ),
    );
  }
}
