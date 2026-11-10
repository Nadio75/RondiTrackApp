import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../stokvel/data/fake_stokvel_repository.dart';
import 'stokvel_summary.dart';

// Riverpod 3: a family uses a constructor argument on an AsyncNotifier.
// FamilyAsyncNotifier is not part of this project's Riverpod API.
class HomeSummariesNotifier extends AsyncNotifier<List<StokvelSummary>> {
  HomeSummariesNotifier(this.userId);

  final String userId;

  @override
  Future<List<StokvelSummary>> build() async {
    final repository = ref.watch(stokvelRepositoryProvider);
    await Future<void>.delayed(const Duration(milliseconds: 400));

    final stokvels = repository.getStokvelsForUser(userId);
    final summaries = <StokvelSummary>[];

    for (final stokvel in stokvels) {
      final details = repository.getDetails(
        userId: userId,
        stokvelId: stokvel.id,
      );
      if (details == null) {
        continue;
      }
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
  }
}

final homeSummariesProvider = AsyncNotifierProvider.autoDispose
    .family<HomeSummariesNotifier, List<StokvelSummary>, String>(
      HomeSummariesNotifier.new,
    );
