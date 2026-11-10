import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../stokvel/data/fake_stokvel_repository.dart';
import 'stokvel_summary.dart';

final homeSummariesProvider = FutureProvider.autoDispose
    .family<List<StokvelSummary>, String>((ref, userId) async {
      final repository = ref.watch(stokvelRepositoryProvider);

      await Future<void>.delayed(const Duration(milliseconds: 400));

      final stokvels = repository.getStokvelsForUser(userId);
      final summaries = <StokvelSummary>[];

      for (final stokvel in stokvels) {
        final details = repository.getDetails(
          userId: userId,
          stokvelId: stokvel.id,
        );

        if (details == null) continue;

        final ownContribution = details.visibleContributions
            .where((item) => item.memberId == userId)
            .firstOrNull;

        summaries.add(
          StokvelSummary(
            stokvel: stokvel,
            role: details.membership.role,
            contributionStatus: ownContribution?.status,
          ),
        );
      }

      return List.unmodifiable(summaries);
    });
