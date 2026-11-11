import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/router/app_routes.dart';
import '../../home/domain/home_summaries_provider.dart';
import '../../session/presentation/session_provider.dart';
import 'stokvel_details_screen.dart';

class ExpandedStokvelLayout extends ConsumerWidget {
  const ExpandedStokvelLayout({required this.selectedStokvelId, super.key});

  final String? selectedStokvelId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider);

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please sign in')));
    }

    final summaries = ref.watch(homeSummariesProvider(user.id));

    return Scaffold(
      appBar: AppBar(title: const Text('My Stokvels')),
      body: summaries.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            const Center(child: Text('Could not load stokvels.')),
        data: (items) {
          final selectedItems = items.where(
            (item) => item.stokvel.id == selectedStokvelId,
          );

          final selected = selectedItems.firstOrNull;

          return Row(
            children: [
              SizedBox(
                width: 300,
                child: ListView(
                  children: [
                    for (final item in items)
                      ListTile(
                        selected: item.stokvel.id == selectedStokvelId,
                        leading: const Icon(Icons.groups),
                        title: Text(item.stokvel.name),
                        subtitle: Text('Role: ${item.role.name}'),
                        onTap: () {
                          StokvelRoute(id: item.stokvel.id).go(context);
                        },
                      ),
                  ],
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: selectedStokvelId == null
                    ? const Center(
                        child: Text('Select a stokvel to view its details.'),
                      )
                    : selected == null
                    ? const Center(child: Text('Stokvel not found'))
                    : StokvelDetailsScreen(
                        key: ValueKey(selectedStokvelId),
                        stokvelId: selectedStokvelId!,
                        embedded: true,
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
