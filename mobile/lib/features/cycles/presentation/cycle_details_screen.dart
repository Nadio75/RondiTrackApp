import '../../../core/localization/localization_context.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/router/app_routes.dart';
import '../../session/presentation/session_provider.dart';
import '../../stokvel/data/fake_stokvel_repository.dart';
import '../../stokvel/domain/stokvel_models.dart';

class CycleDetailsScreen extends ConsumerWidget {
  const CycleDetailsScreen({
    super.key,
    required this.stokvelId,
    required this.cycleId,
  });

  final String stokvelId;
  final String cycleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final user = ref.watch(sessionProvider);
    final repository = ref.watch(stokvelRepositoryProvider);

    final cycle = user == null
        ? null
        : repository.getCycle(
            userId: user.id,
            stokvelId: stokvelId,
            cycleId: cycleId,
          );

    if (cycle == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.cycle)),
        body: Center(child: Text(l10n.cycleNotFound)),
      );
    }

    final status = switch (cycle.status) {
      CycleStatus.active => l10n.active,
      CycleStatus.upcoming => l10n.upcoming,
      CycleStatus.closed => l10n.closed,
      CycleStatus.unknown => l10n.unknown,
    };

    String dateLabel(DateTime date) {
      return '${date.day}/${date.month}/${date.year}';
    }

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.cycleDashboard)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.currentCycle, style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(
                    l10n.cycleIdentifier(cycleId),
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.cycleOverview,
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          Text(l10n.statusLabel(status)),
                          const SizedBox(height: 12),
                          Text(l10n.startDate(dateLabel(cycle.startDate))),
                          const SizedBox(height: 12),
                          Text(l10n.endDate(dateLabel(cycle.endDate))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.contributionSummary,
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          Text(l10n.demoContributionCounts),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.payoutInformation,
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          Text(l10n.payoutDescription),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: () {
                              PayoutRotationRoute(
                                id: stokvelId,
                                cycleId: cycleId,
                              ).go(context);
                            },
                            icon: const Icon(Icons.list_alt),
                            label: Text(l10n.viewPayoutRotation),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
