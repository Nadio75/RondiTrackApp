import 'package:flutter/material.dart';

import '../../../core/localization/localization_context.dart';
import '../../../core/money/cents.dart';
import '../../../core/theme/rondi_theme.dart';
import '../../stokvel/domain/stokvel_models.dart';

class StokvelSummaryCard extends StatelessWidget {
  const StokvelSummaryCard({
    super.key,
    required this.stokvel,
    required this.role,
    required this.contributionStatus,
    this.onTap,
  });

  final Stokvel stokvel;
  final StokvelRole role;
  final ContributionStatus? contributionStatus;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.extension<RondiStatusColors>();

    final roleLabel = switch (role) {
      StokvelRole.treasurer => l10n.treasurer,
      StokvelRole.member => l10n.member,
      StokvelRole.chairperson => l10n.chairperson,
      StokvelRole.unknown => l10n.unknown,
    };

    final statusLabel = switch (contributionStatus) {
      ContributionStatus.paid => l10n.upToDate,
      ContributionStatus.overdue => l10n.inArrears,
      ContributionStatus.pending => l10n.pending,
      _ => l10n.unknown,
    };

    final statusColor = switch (contributionStatus) {
      ContributionStatus.paid => colors?.paid,
      ContributionStatus.overdue => colors?.overdue,
      ContributionStatus.pending => colors?.pending,
      _ => theme.colorScheme.onSurfaceVariant,
    };

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(stokvel.name, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(stokvel.description),
              const SizedBox(height: 16),
              Text(
                l10n.monthlyContribution(
                  formatRands(stokvel.monthlyContributionCents),
                ),
              ),
              const SizedBox(height: 8),
              Text(l10n.roleLabel(roleLabel)),
              const SizedBox(height: 8),
              Text(
                l10n.contributionStatus(statusLabel),
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
