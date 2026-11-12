// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
  $signInRoute,
  $joinInvitationRoute,
  $rondiShellRoute,
];

RouteBase get $signInRoute => GoRouteData.$route(
  path: '/sign-in',
  hasOverriddenOnExit: false,
  factory: $SignInRoute._fromState,
);

mixin $SignInRoute on GoRouteData {
  static SignInRoute _fromState(GoRouterState state) => const SignInRoute();

  @override
  String get location => GoRouteData.$location('/sign-in');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $joinInvitationRoute => GoRouteData.$route(
  path: '/join/:code',
  hasOverriddenOnExit: false,
  factory: $JoinInvitationRoute._fromState,
);

mixin $JoinInvitationRoute on GoRouteData {
  static JoinInvitationRoute _fromState(GoRouterState state) =>
      JoinInvitationRoute(code: state.pathParameters['code']!);

  JoinInvitationRoute get _self => this as JoinInvitationRoute;

  @override
  String get location =>
      GoRouteData.$location('/join/${Uri.encodeComponent(_self.code)}');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $rondiShellRoute => StatefulShellRouteData.$route(
  restorationScopeId: RondiShellRoute.$restorationScopeId,
  factory: $RondiShellRouteExtension._fromState,
  branches: [
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/home',
          hasOverriddenOnExit: false,
          factory: $HomeRoute._fromState,
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/stokvels',
          hasOverriddenOnExit: false,
          factory: $StokvelsRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: ':id',
              hasOverriddenOnExit: false,
              factory: $StokvelRoute._fromState,
              routes: [
                GoRouteData.$route(
                  path: 'cycles/:cycleId',
                  hasOverriddenOnExit: false,
                  factory: $CycleRoute._fromState,
                  routes: [
                    GoRouteData.$route(
                      path: 'payout-rotation',
                      hasOverriddenOnExit: false,
                      factory: $PayoutRotationRoute._fromState,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/activity',
          hasOverriddenOnExit: false,
          factory: $ActivityRoute._fromState,
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/profile',
          hasOverriddenOnExit: false,
          factory: $ProfileRoute._fromState,
        ),
      ],
    ),
  ],
);

extension $RondiShellRouteExtension on RondiShellRoute {
  static RondiShellRoute _fromState(GoRouterState state) =>
      const RondiShellRoute();
}

mixin $HomeRoute on GoRouteData {
  static HomeRoute _fromState(GoRouterState state) => const HomeRoute();

  @override
  String get location => GoRouteData.$location('/home');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $StokvelsRoute on GoRouteData {
  static StokvelsRoute _fromState(GoRouterState state) => const StokvelsRoute();

  @override
  String get location => GoRouteData.$location('/stokvels');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $StokvelRoute on GoRouteData {
  static StokvelRoute _fromState(GoRouterState state) =>
      StokvelRoute(id: state.pathParameters['id']!);

  StokvelRoute get _self => this as StokvelRoute;

  @override
  String get location =>
      GoRouteData.$location('/stokvels/${Uri.encodeComponent(_self.id)}');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $CycleRoute on GoRouteData {
  static CycleRoute _fromState(GoRouterState state) => CycleRoute(
    id: state.pathParameters['id']!,
    cycleId: state.pathParameters['cycleId']!,
  );

  CycleRoute get _self => this as CycleRoute;

  @override
  String get location => GoRouteData.$location(
    '/stokvels/${Uri.encodeComponent(_self.id)}/cycles/${Uri.encodeComponent(_self.cycleId)}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $PayoutRotationRoute on GoRouteData {
  static PayoutRotationRoute _fromState(GoRouterState state) =>
      PayoutRotationRoute(
        id: state.pathParameters['id']!,
        cycleId: state.pathParameters['cycleId']!,
      );

  PayoutRotationRoute get _self => this as PayoutRotationRoute;

  @override
  String get location => GoRouteData.$location(
    '/stokvels/${Uri.encodeComponent(_self.id)}/cycles/${Uri.encodeComponent(_self.cycleId)}/payout-rotation',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ActivityRoute on GoRouteData {
  static ActivityRoute _fromState(GoRouterState state) => const ActivityRoute();

  @override
  String get location => GoRouteData.$location('/activity');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ProfileRoute on GoRouteData {
  static ProfileRoute _fromState(GoRouterState state) => const ProfileRoute();

  @override
  String get location => GoRouteData.$location('/profile');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
