import '../../../core/localization/localization_context.dart';
import '../../../core/localization/localized_values.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/money/cents.dart';
import '../../session/presentation/session_provider.dart';
import '../../session/presentation/session_origin_provider.dart';
import 'api_home_view.dart';
import '../../../app/router/app_routes.dart';
import '../domain/home_summaries_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider);
    final l10n = context.l10n;
    final origin = ref.watch(sessionOriginProvider);

    if (user == null) {
      return Scaffold(body: Center(child: Text(l10n.pleaseSignIn)));
    }

    if (origin == SessionOrigin.api) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('RondiTrack'),
          actions: [
            IconButton(
              tooltip: l10n.logout,
              onPressed: () {
                ref.read(sessionProvider.notifier).logoutWithApi();
              },
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: const ApiHomeView(),
      );
    }

    final summariesAsync = ref.watch(homeSummariesProvider(user.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('RondiTrack'),
        actions: [
          IconButton(
            tooltip: l10n.logout,
            onPressed: () {
              ref.read(sessionProvider.notifier).logoutWithApi();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () {
          return ref.refresh(homeSummariesProvider(user.id).future);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              l10n.welcome(user.name),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(l10n.stokvelOverview),
            const SizedBox(height: 24),
            switch (summariesAsync) {
              AsyncData(:final value) when value.isEmpty => Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(l10n.noStokvels),
                ),
              ),
              AsyncData(:final value) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final summary in value)
                    Card(
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          StokvelRoute(id: summary.stokvel.id).push(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                summary.stokvel.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall,
                              ),
                              const SizedBox(height: 8),
                              Text(summary.stokvel.description),
                              const SizedBox(height: 16),
                              Text(
                                l10n.monthlyContribution(
                                  formatRands(
                                    summary.stokvel.monthlyContributionCents,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.roleLabel(
                                  localizedRole(l10n, summary.role.name),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.contributionStatus(
                                  localizedContributionStatus(
                                    l10n,
                                    summary.contributionStatus?.name ?? "none",
                                  ),
                                ),
                              ),
                            ],
                          ),
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
                      const Icon(Icons.error_outline, size: 40),
                      const SizedBox(height: 12),
                      Text(l10n.loadStokvelsError),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () {
                          ref.invalidate(homeSummariesProvider(user.id));
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
      ),
    );
  }
}
