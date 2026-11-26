import '../../home/domain/offline_home_provider.dart';
import '../../../core/localization/localization_context.dart';
import '../../../core/localization/localized_values.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/responsive/app_breakpoints.dart';
import '../../home/domain/home_summaries_provider.dart';
import '../../session/presentation/session_provider.dart';
import 'expanded_stokvel_layout.dart';
import 'create_stokvel_screen.dart';
import 'join_stokvel_screen.dart';
import '../../home/presentation/api_home_view.dart';
import '../../session/presentation/session_origin_provider.dart';

class StokvelsScreen extends ConsumerWidget {
  const StokvelsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final origin = ref.watch(sessionOriginProvider);

    if (origin == SessionOrigin.api) {
      final apiUser = ref.watch(sessionProvider);

      if (apiUser == null) {
        return Scaffold(body: Center(child: Text(l10n.pleaseSignIn)));
      }

      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.myStokvels),
          actions: [
            TextButton.icon(
              key: const Key('open_join_stokvel'),
              icon: const Icon(Icons.group_add_outlined),
              label: Text(
                Localizations.localeOf(context).languageCode == 'nso'
                    ? 'Tsena'
                    : 'Join stokvel',
              ),
              onPressed: () async {
                final id = await Navigator.of(context).push<String>(
                  MaterialPageRoute(builder: (_) => const JoinStokvelScreen()),
                );

                if (!context.mounted || id == null) return;

                if (ref.read(sessionProvider)?.id != apiUser.id ||
                    ref.read(sessionOriginProvider) != SessionOrigin.api) {
                  return;
                }

                ref.invalidate(authenticatedHomeProvider);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      Localizations.localeOf(context).languageCode == 'nso'
                          ? 'O tsene stokvel.'
                          : 'Successfully joined stokvel.',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: const ApiHomeView(showOverviewHeading: false),
        floatingActionButton: FloatingActionButton.extended(
          key: const Key('open_create_stokvel'),
          onPressed: () async {
            final id = await Navigator.of(context).push<String>(
              MaterialPageRoute(builder: (_) => const CreateStokvelScreen()),
            );

            if (!context.mounted || id == null) return;

            ref.invalidate(authenticatedHomeProvider);

            final nso = Localizations.localeOf(context).languageCode == 'nso';

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  nso ? 'Stokvel e hlamilwe.' : 'Stokvel created successfully.',
                ),
              ),
            );
          },
          icon: const Icon(Icons.add),
          label: Text(
            Localizations.localeOf(context).languageCode == 'nso'
                ? 'Hlama stokvel'
                : 'Create stokvel',
          ),
        ),
      );
    }

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
