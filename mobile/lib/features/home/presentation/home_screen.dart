import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/money/cents.dart';
import '../../session/presentation/session_provider.dart';
import '../../../app/router/app_routes.dart';
import '../domain/home_summaries_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider);

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please sign in')));
    }

    final summariesAsync = ref.watch(homeSummariesProvider(user.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('RondiTrack'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () {
              ref.read(sessionProvider.notifier).logout();
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
              'Welcome, ${user.name}!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text('Your stokvel overview'),
            const SizedBox(height: 24),
            switch (summariesAsync) {
              AsyncData(:final value) when value.isEmpty => const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('You have not joined any stokvels yet.'),
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
                                'Monthly contribution: '
                                '${formatRands(summary.stokvel.monthlyContributionCents)}',
                              ),
                              const SizedBox(height: 8),
                              Text('Role: ${summary.role.name}'),
                              const SizedBox(height: 8),
                              Text(
                                'Contribution status: '
                                '${summary.contributionStatus?.name ?? "none"}',
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
                      const Text('Could not load your stokvels.'),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () {
                          ref.invalidate(homeSummariesProvider(user.id));
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
      ),
    );
  }
}
