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
        appBar: AppBar(title: const Text('Cycle')),
        body: const Center(child: Text('Cycle not found')),
      );
    }

    final status = switch (cycle.status) {
      CycleStatus.active => 'Active',
      CycleStatus.upcoming => 'Upcoming',
      CycleStatus.closed => 'Closed',
      CycleStatus.unknown => 'Unknown',
    };

    String dateLabel(DateTime date) {
      return '${date.day}/${date.month}/${date.year}';
    }

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Cycle dashboard')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Current cycle', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text('Cycle $cycleId', style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cycle overview',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          Text('Status: $status'),
                          const SizedBox(height: 12),
                          Text('Start date: ${dateLabel(cycle.startDate)}'),
                          const SizedBox(height: 12),
                          Text('End date: ${dateLabel(cycle.endDate)}'),
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
                            'Contribution summary',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Paid and unpaid member counts are not '
                            'available for this cycle in the current '
                            'demo data.',
                          ),
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
                            'Payout information',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'View the assigned recipient order and '
                            'the next payout for this cycle.',
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: () {
                              PayoutRotationRoute(
                                id: stokvelId,
                                cycleId: cycleId,
                              ).go(context);
                            },
                            icon: const Icon(Icons.list_alt),
                            label: const Text('View payout rotation'),
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
