import '../../contributions/presentation/api_contribution_screen.dart';
import '../../session/presentation/session_provider.dart';
import '../../session/presentation/session_origin_provider.dart';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/localization/localization_context.dart';
import '../../../core/localization/localized_values.dart';
import '../../../core/offline/home_cache_repository.dart';
import '../domain/offline_home_provider.dart';
import 'home_age_formatter.dart';

class ApiHomeView extends ConsumerWidget {
  const ApiHomeView({super.key, this.showOverviewHeading = true});

  final bool showOverviewHeading;

  String? _safeReference(Object error) {
    if (error is! DioException) {
      return null;
    }

    final body = error.response?.data;

    if (body is! Map) {
      return null;
    }

    final reference = body['correlationId'];

    if (reference is! String) {
      return null;
    }

    final value = reference.trim();

    if (!RegExp(r'^[A-Za-z0-9_-]{1,128}$').hasMatch(value)) {
      return null;
    }

    return value;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final home = ref.watch(authenticatedHomeProvider);
    final l10n = context.l10n;

    Future<void> reloadHome() async {
      try {
        ref.invalidate(authenticatedHomeProvider);
        await ref.read(authenticatedHomeProvider.future);
      } catch (_) {
        // The provider displays the resulting error state.
      }
    }

    return RefreshIndicator(
      onRefresh: () => reloadHome(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          if (showOverviewHeading) ...[
            Text(
              l10n.stokvelOverview,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
          ],
          switch (home) {
            AsyncData(:final value) when value == null => Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(l10n.noHomeData),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () async {
                        await reloadHome();
                      },
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            ),
            AsyncData(:final value) when value != null => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (value.isCached)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            value.source == HomeDataSource.offlineCache
                                ? Icons.wifi_off
                                : Icons.cloud_off_outlined,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  value.source == HomeDataSource.offlineCache
                                      ? l10n.offlineSavedData
                                      : l10n.cachedSavedData,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(formatHomeAge(l10n, value.updatedAtUtc)),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: () async {
                                    await reloadHome();
                                  },
                                  child: Text(l10n.retry),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Text(
                    l10n.lastUpdated(value.updatedAtUtc.toLocal().toString()),
                  ),
                const SizedBox(height: 12),
                if (value.stokvels.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const Icon(Icons.groups_outlined, size: 40),
                          const SizedBox(height: 12),
                          Text(l10n.noStokvels, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () {
                              const StokvelsRoute().go(context);
                            },
                            child: Text(l10n.viewStokvels),
                          ),
                        ],
                      ),
                    ),
                  ),
                for (final stokvel in value.stokvels)
                  Card(
                    child: ListTile(
                      title: Text(stokvel.name),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        final user = ref.read(sessionProvider);

                        if (user == null ||
                            ref.read(sessionOriginProvider) !=
                                SessionOrigin.api) {
                          return;
                        }

                        Navigator.of(context).push<void>(
                          MaterialPageRoute<void>(
                            builder: (_) => ApiContributionScreen(
                              stokvelId: stokvel.id,
                              stokvelName: stokvel.name,
                              accountId: user.id,
                              sessionGeneration: ref
                                  .read(sessionProvider.notifier)
                                  .sessionGeneration,
                            ),
                          ),
                        );
                      },
                      subtitle: Text(
                        l10n.roleLabel(localizedRole(l10n, stokvel.role)),
                      ),
                    ),
                  ),
              ],
            ),
            AsyncError(:final error) => Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(Icons.error_outline, size: 32),
                    const SizedBox(height: 12),
                    Text(l10n.loadStokvelsError, textAlign: TextAlign.center),
                    if (_safeReference(error) case final reference?) ...[
                      const SizedBox(height: 8),
                      Text(l10n.errorReference(reference)),
                    ],
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () async {
                        await reloadHome();
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
