import '../../../core/localization/localization_context.dart';
import '../../../core/localization/localized_values.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/responsive/app_breakpoints.dart';
import '../../home/domain/home_summaries_provider.dart';
import '../../session/presentation/session_provider.dart';
import 'expanded_stokvel_layout.dart';

class StokvelsScreen extends ConsumerWidget {
  const StokvelsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final width = MediaQuery.sizeOf(context).width;

    if (AppBreakpoints.classify(width) == WindowSizeClass.expanded) {
      return const ExpandedStokvelLayout(selectedStokvelId: null);
    }

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
        data: (items) => ListView(
          children: [
            for (final item in items)
              ListTile(
                leading: const Icon(Icons.groups),
                title: Text(item.stokvel.name),
                subtitle: Text(
                  l10n.roleLabel(localizedRole(l10n, item.role.name)),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  StokvelRoute(id: item.stokvel.id).go(context);
                },
              ),
          ],
        ),
      ),
    );
  }
}
