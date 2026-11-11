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

    if (AppBreakpoints.classify(width) != WindowSizeClass.compact) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: selectTab,
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.groups_outlined),
                  label: Text('Stokvels'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.history),
                  label: Text('Activity'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person_outline),
                  label: Text('Profile'),
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
        destinations: destinations,
      ),
    );
  }
}
