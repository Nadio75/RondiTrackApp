import '../../../core/localization/localization_context.dart';
import '../../../core/localization/localized_values.dart';

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
    final l10n = context.l10n;
    final user = ref.watch(sessionProvider);

    if (user == null) {
      return Scaffold(body: Center(child: Text(l10n.pleaseSignIn)));
    }

    final summaries = ref.watch(homeSummariesProvider(user.id));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myStokvels)),
      body: summaries.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text(l10n.loadStokvelsListError)),
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
                        subtitle: Text(
                          l10n.roleLabel(localizedRole(l10n, item.role.name)),
                        ),
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
                    ? Center(child: Text(l10n.selectStokvel))
                    : selected == null
                    ? Center(child: Text(l10n.stokvelNotFound))
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
