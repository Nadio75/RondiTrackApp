import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/money/cents.dart';
import '../../session/data/demo_users.dart';
import 'stokvel_details_provider.dart';
import '../domain/stokvel_models.dart';
import '../../session/presentation/session_provider.dart';
import '../../home/domain/home_summaries_provider.dart';

class StokvelDetailsScreen extends ConsumerWidget {
  const StokvelDetailsScreen({required this.stokvelId, super.key});

  final String stokvelId;

  String money(Cents cents) => formatRands(cents);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(stokvelDetailsProvider(stokvelId));

    return detailsAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Stokvel')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: const Text('Stokvel')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Could not load stokvel details.'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () {
                  ref.invalidate(stokvelDetailsProvider(stokvelId));
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (details) {
        if (details == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Stokvel')),
            body: const Center(child: Text('Stokvel not found')),
          );
        }
        final role = details.membership.role;
        final canViewAll =
            role == StokvelRole.treasurer || role == StokvelRole.chairperson;

        return Scaffold(
          appBar: AppBar(
            title: Text(details.stokvel.name),
            actions: [
              Consumer(
                builder: (context, ref, _) {
                  final user = ref.watch(sessionProvider);
                  if (user == null) {
                    return const SizedBox.shrink();
                  }
                  final summaries = ref
                      .watch(homeSummariesProvider(user.id))
                      .asData
                      ?.value;
                  if (summaries == null || summaries.length < 2) {
                    return const SizedBox.shrink();
                  }
                  return PopupMenuButton<String>(
                    tooltip: 'Switch stokvel',
                    icon: const Icon(Icons.swap_horiz),
                    onSelected: (id) {
                      if (id == stokvelId) {
                        return;
                      }
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute<void>(
                          builder: (_) => StokvelDetailsScreen(stokvelId: id),
                        ),
                      );
                    },
                    itemBuilder: (_) => [
                      for (final summary in summaries)
                        PopupMenuItem<String>(
                          value: summary.stokvel.id,
                          child: Text(summary.stokvel.name),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                details.stokvel.description,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Monthly contribution'),
                      const SizedBox(height: 8),
                      Text(
                        money(details.stokvel.monthlyContributionCents),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 12),
                      Text('Your role: ${role.name}'),
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
                        canViewAll
                            ? 'Total paid contributions'
                            : 'Your paid contributions',
                      ),
                      const SizedBox(height: 8),
                      Text(
                        money(details.visiblePaidTotalCents),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                canViewAll ? 'Member contributions' : 'Your contributions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (details.visibleContributions.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('No contributions found.'),
                  ),
                ),
              for (final contribution in details.visibleContributions)
                Card(
                  child: ListTile(
                    leading: Icon(
                      contribution.status == ContributionStatus.paid
                          ? Icons.check_circle
                          : Icons.schedule,
                      color: contribution.status == ContributionStatus.paid
                          ? Colors.green
                          : Colors.orange,
                    ),
                    title: Text(
                      demoUsers
                              .where(
                                (member) => member.id == contribution.memberId,
                              )
                              .map((member) => member.name)
                              .firstOrNull ??
                          'Unknown member',
                    ),
                    subtitle: Text(contribution.status.name.toUpperCase()),
                    trailing: Text(money(contribution.amountCents)),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
