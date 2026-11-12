import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/money/cents.dart';
import '../domain/payout_models.dart';
import 'payout_provider.dart';
import 'payout_view_state.dart';

class PayoutRotationScreen extends ConsumerWidget {
  const PayoutRotationScreen({
    super.key,
    required this.stokvelId,
    required this.cycleId,
  });

  final String stokvelId;
  final String cycleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = (stokvelId: stokvelId, cycleId: cycleId);
    final provider = payoutRotationProvider(key);
    final state = payoutViewStateFromAsync(ref.watch(provider));

    return Scaffold(
      appBar: AppBar(title: const Text('Payout rotation')),
      body: SafeArea(
        child: switch (state) {
          PayoutLoading() => const Center(child: CircularProgressIndicator()),
          PayoutEmpty() => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No payout rotation is available for this cycle.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
          PayoutFailure() => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Could not load the payout rotation.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => ref.invalidate(provider),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          PayoutData(:final rotation) => _RotationContent(rotation: rotation),
        },
      ),
    );
  }
}

class _RotationContent extends StatelessWidget {
  const _RotationContent({required this.rotation});

  final PayoutRotation rotation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final next = rotation.entries.where((entry) => entry.isNext).firstOrNull;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Payout schedule', style: theme.textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  'Recipients are shown in their assigned payout order.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                if (next != null) ...[
                  Card(
                    color: theme.colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Next recipient',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            next.memberName,
                            style: theme.textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            formatRands(next.amountCents),
                            style: theme.textTheme.titleLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                Text('Rotation order', style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),
                for (final entry in rotation.entries) ...[
                  _PayoutEntryCard(entry: entry),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PayoutEntryCard extends StatelessWidget {
  const _PayoutEntryCard({required this.entry});

  final PayoutRotationEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final label = switch (entry.status) {
      PayoutStatus.paid => 'Paid',
      PayoutStatus.next => 'Next',
      PayoutStatus.upcoming => 'Upcoming',
      PayoutStatus.unknown => 'Unknown',
    };

    final icon = switch (entry.status) {
      PayoutStatus.paid => Icons.check_circle_outline,
      PayoutStatus.next => Icons.arrow_circle_right_outlined,
      PayoutStatus.upcoming => Icons.schedule,
      PayoutStatus.unknown => Icons.help_outline,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, semanticLabel: label),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${entry.position}. ${entry.memberName}',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text('Status: $label'),
                  const SizedBox(height: 6),
                  Text(formatRands(entry.amountCents)),
                  if (entry.isNext) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Next payout recipient',
                      style: theme.textTheme.labelLarge,
                    ),
                  ],
                  if (entry.scheduledDate != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Scheduled: '
                      '${entry.scheduledDate!.day}/'
                      '${entry.scheduledDate!.month}/'
                      '${entry.scheduledDate!.year}',
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
