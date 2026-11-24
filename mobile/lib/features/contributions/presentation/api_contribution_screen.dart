import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/localization_context.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/network/generated/rest_client.dart';
import '../../../core/network/generated/models/contribution_cycle_response.dart';
import '../../session/presentation/session_provider.dart';
import '../../session/presentation/session_origin_provider.dart';
import 'contribution_form.dart';

final apiContributionCyclesProvider = FutureProvider.autoDispose
    .family<List<ContributionCycleResponse>, String>((ref, stokvelId) async {
      final user = ref.watch(sessionProvider);
      final origin = ref.watch(sessionOriginProvider);

      if (user == null || origin != SessionOrigin.api) {
        return [];
      }

      final generation = ref.read(sessionProvider.notifier).sessionGeneration;

      var active = true;
      ref.onDispose(() => active = false);

      final dio = ref.watch(dioProvider);

      final cycles = await RestClient(dio).contributionCycles
          .getApiV1StokvelsStokvelIdCycles(stokvelId: stokvelId);

      if (!active) return [];

      if (ref.read(sessionProvider)?.id != user.id ||
          ref.read(sessionOriginProvider) != SessionOrigin.api ||
          ref.read(sessionProvider.notifier).sessionGeneration != generation) {
        return [];
      }

      return cycles
          .where((cycle) => cycle.stokvelId == stokvelId && cycle.id.isNotEmpty)
          .toList(growable: false);
    });

class ApiContributionScreen extends ConsumerWidget {
  const ApiContributionScreen({
    super.key,
    required this.stokvelId,
    required this.stokvelName,
    required this.accountId,
    required this.sessionGeneration,
  });

  final String stokvelId;
  final String stokvelName;
  final String accountId;
  final int sessionGeneration;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final user = ref.watch(sessionProvider);
    final origin = ref.watch(sessionOriginProvider);

    if (user == null ||
        user.id != accountId ||
        origin != SessionOrigin.api ||
        ref.read(sessionProvider.notifier).sessionGeneration !=
            sessionGeneration) {
      return Scaffold(body: Center(child: Text(l10n.pleaseSignIn)));
    }

    final cycles = ref.watch(apiContributionCyclesProvider(stokvelId));

    return Scaffold(
      appBar: AppBar(title: Text(stokvelName)),
      body: SafeArea(
        child: cycles.when(
          skipLoadingOnRefresh: false,
          skipLoadingOnReload: false,
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.loadStokvelDetailsError),
                FilledButton(
                  onPressed: () =>
                      ref.invalidate(apiContributionCyclesProvider(stokvelId)),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
          data: (items) => items.isEmpty
              ? Center(child: Text(l10n.cycleNotFound))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    for (final cycle in items)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                cycle.period,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 12),
                              if (cycle.isClosed == true ||
                                  cycle.closedAtUtc != null ||
                                  cycle.status?.toLowerCase() == 'closed')
                                Text(l10n.closed)
                              else if (cycle.status?.toLowerCase() ==
                                      'active' ||
                                  cycle.status?.toLowerCase() == 'open')
                                ContributionForm(
                                  key: ValueKey(
                                    '$accountId:$sessionGeneration:${cycle.id}',
                                  ),
                                  stokvelId: stokvelId,
                                  cycleId: cycle.id,
                                  memberId: accountId,
                                )
                              else
                                Text(l10n.unknown),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}
