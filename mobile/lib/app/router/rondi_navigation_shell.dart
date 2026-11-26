import '../../core/localization/localization_context.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/responsive/app_breakpoints.dart';

class RondiNavigationShell extends StatelessWidget {
  const RondiNavigationShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  static const destinations = [
    NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
    NavigationDestination(icon: Icon(Icons.groups_outlined), label: 'Stokvels'),
    NavigationDestination(icon: Icon(Icons.history), label: 'Activity'),
    NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
  ];

  void selectTab(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final l10n = context.l10n;

    if (AppBreakpoints.classify(width) != WindowSizeClass.compact) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: selectTab,
              labelType: NavigationRailLabelType.all,
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  label: Text(l10n.home),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.groups_outlined),
                  label: Text(l10n.stokvels),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.history),
                  label: Text(l10n.activity),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person_outline),
                  label: Text(l10n.profile),
                ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: selectTab,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            label: l10n.home,
          ),
          NavigationDestination(
            icon: const Icon(Icons.groups_outlined),
            label: l10n.stokvels,
          ),
          NavigationDestination(
            icon: const Icon(Icons.history),
            label: l10n.activity,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            label: l10n.profile,
          ),
        ],
      ),
    );
  }
}
