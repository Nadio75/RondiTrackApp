import '../../../core/localization/localization_context.dart';
import '../../../core/localization/localized_values.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/offline_home_provider.dart';

class ApiHomeView extends ConsumerWidget {
  const ApiHomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final home = ref.watch(authenticatedHomeProvider);
    final l10n = context.l10n;

    return RefreshIndicator(
      onRefresh: () {
        return ref.refresh(authenticatedHomeProvider.future);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            l10n.stokvelOverview,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          switch (home) {
            AsyncData(:final value) when value == null => Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(l10n.noHomeData),
              ),
            ),
            AsyncData(:final value)
                when value != null && value.stokvels.isEmpty =>
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(l10n.noStokvels),
                ),
              ),
            AsyncData(:final value) when value != null => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.lastUpdated(value.updatedAtUtc.toLocal().toString())),
                const SizedBox(height: 12),
                for (final stokvel in value.stokvels)
                  Card(
                    child: ListTile(
                      title: Text(stokvel.name),
                      subtitle: Text(
                        l10n.roleLabel(localizedRole(l10n, stokvel.role)),
                      ),
                    ),
                  ),
              ],
            ),
            AsyncError() => Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(l10n.loadStokvelsError),
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
                      child: Text(l10n.retry),
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
