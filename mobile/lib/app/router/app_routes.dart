import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/activity/presentation/activity_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/session/presentation/login_screen.dart';
import '../../features/stokvel/presentation/stokvel_details_screen.dart';
import '../../features/stokvel/presentation/stokvels_screen.dart';
import 'rondi_navigation_shell.dart';
import '../../core/responsive/app_breakpoints.dart';
import '../../features/stokvel/presentation/expanded_stokvel_layout.dart';

import '../../features/invitations/presentation/join_invitation_screen.dart';

import '../../features/cycles/presentation/cycle_details_screen.dart';

part 'app_routes.g.dart';

@TypedGoRoute<SignInRoute>(path: '/sign-in')
class SignInRoute extends GoRouteData with $SignInRoute {
  const SignInRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const LoginScreen();
  }
}

@TypedGoRoute<JoinInvitationRoute>(path: '/join/:code')
class JoinInvitationRoute extends GoRouteData with $JoinInvitationRoute {
  const JoinInvitationRoute({required this.code});

  final String code;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return JoinInvitationScreen(code: code);
  }
}

@TypedStatefulShellRoute<RondiShellRoute>(
  branches: [
    TypedStatefulShellBranch<HomeBranch>(
      routes: [TypedGoRoute<HomeRoute>(path: '/home')],
    ),
    TypedStatefulShellBranch<StokvelsBranch>(
      routes: [
        TypedGoRoute<StokvelsRoute>(
          path: '/stokvels',
          routes: [
            TypedGoRoute<StokvelRoute>(
              path: ':id',
              routes: [TypedGoRoute<CycleRoute>(path: 'cycles/:cycleId')],
            ),
          ],
        ),
      ],
    ),
    TypedStatefulShellBranch<ActivityBranch>(
      routes: [TypedGoRoute<ActivityRoute>(path: '/activity')],
    ),
    TypedStatefulShellBranch<ProfileBranch>(
      routes: [TypedGoRoute<ProfileRoute>(path: '/profile')],
    ),
  ],
)
class RondiShellRoute extends StatefulShellRouteData {
  const RondiShellRoute();

  static const String $restorationScopeId = 'rondi-shell';

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) {
    return RondiNavigationShell(navigationShell: navigationShell);
  }
}

class HomeBranch extends StatefulShellBranchData {
  const HomeBranch();
}

class StokvelsBranch extends StatefulShellBranchData {
  const StokvelsBranch();
}

class ActivityBranch extends StatefulShellBranchData {
  const ActivityBranch();
}

class ProfileBranch extends StatefulShellBranchData {
  const ProfileBranch();
}

class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const HomeScreen();
  }
}

class StokvelsRoute extends GoRouteData with $StokvelsRoute {
  const StokvelsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const StokvelsScreen();
  }
}

class StokvelRoute extends GoRouteData with $StokvelRoute {
  const StokvelRoute({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final width = MediaQuery.sizeOf(context).width;

    if (AppBreakpoints.classify(width) == WindowSizeClass.expanded) {
      return ExpandedStokvelLayout(selectedStokvelId: id);
    }

    return StokvelDetailsScreen(stokvelId: id);
  }
}

class CycleRoute extends GoRouteData with $CycleRoute {
  const CycleRoute({required this.id, required this.cycleId});

  final String id;
  final String cycleId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return CycleDetailsScreen(stokvelId: id, cycleId: cycleId);
  }
}

class ActivityRoute extends GoRouteData with $ActivityRoute {
  const ActivityRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ActivityScreen();
  }
}

class ProfileRoute extends GoRouteData with $ProfileRoute {
  const ProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ProfileScreen();
  }
}
