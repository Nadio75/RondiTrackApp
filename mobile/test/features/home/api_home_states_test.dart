import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:ronditrack/core/offline/home_cache_repository.dart';
import 'package:ronditrack/core/theme/rondi_theme.dart';
import 'package:ronditrack/features/home/domain/offline_home_provider.dart';
import 'package:ronditrack/features/home/presentation/api_home_view.dart';
import 'package:ronditrack/l10n/generated/app_localizations_en.dart';

void main() {
  final l10n = AppLocalizationsEn();

  CachedHomeSnapshot snapshot({
    HomeDataSource source = HomeDataSource.live,
    bool empty = false,
  }) {
    return CachedHomeSnapshot(
      stokvels: empty
          ? const []
          : const [
              CachedHomeStokvel(
                id: 'synthetic-1',
                name: 'Community Savings',
                role: 'MEMBER',
              ),
            ],
      updatedAtUtc: DateTime.now().toUtc().subtract(
        const Duration(minutes: 15, seconds: 5),
      ),
      source: source,
    );
  }

  DioException apiError(Object? body) {
    final request = RequestOptions(path: '/api/v1/me/home');

    return DioException(
      requestOptions: request,
      type: DioExceptionType.badResponse,
      response: Response<dynamic>(
        requestOptions: request,
        statusCode: 503,
        data: body,
      ),
    );
  }

  Widget testApp(
    Future<CachedHomeSnapshot?> Function() load, {
    bool dark = false,
  }) {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: ApiHomeView()),
        ),
        GoRoute(
          path: '/stokvels',
          builder: (context, state) =>
              const Scaffold(body: Text('Stokvel destination')),
        ),
      ],
    );

    addTearDown(router.dispose);

    return ProviderScope(
      retry: (_, _) => null,
      overrides: [authenticatedHomeProvider.overrideWith((ref) => load())],
      child: MaterialApp.router(
        routerConfig: router,
        theme: RondiTheme.light,
        darkTheme: RondiTheme.dark,
        themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      ),
    );
  }

  testWidgets('offline Home displays saved data and its age', (tester) async {
    await tester.pumpWidget(
      testApp(() async => snapshot(source: HomeDataSource.offlineCache)),
    );
    await tester.pumpAndSettle();

    expect(find.text(l10n.offlineSavedData), findsOneWidget);
    expect(find.text('Updated 15 minutes ago'), findsOneWidget);
    expect(find.text('Community Savings'), findsOneWidget);
  });

  testWidgets('server fallback does not claim device is offline', (
    tester,
  ) async {
    await tester.pumpWidget(
      testApp(() async => snapshot(source: HomeDataSource.unavailableCache)),
    );
    await tester.pumpAndSettle();

    expect(find.text(l10n.cachedSavedData), findsOneWidget);
    expect(find.text(l10n.offlineSavedData), findsNothing);
  });

  testWidgets('live data does not display a cache warning', (tester) async {
    await tester.pumpWidget(testApp(() async => snapshot()));
    await tester.pumpAndSettle();

    expect(find.text('Community Savings'), findsOneWidget);
    expect(find.text(l10n.offlineSavedData), findsNothing);
    expect(find.text(l10n.cachedSavedData), findsNothing);
  });

  testWidgets('empty Home action opens Stokvels', (tester) async {
    await tester.pumpWidget(testApp(() async => snapshot(empty: true)));
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10n.viewStokvels));
    await tester.pumpAndSettle();

    expect(find.text('Stokvel destination'), findsOneWidget);
  });

  testWidgets('empty cached Home retains its offline warning', (tester) async {
    await tester.pumpWidget(
      testApp(
        () async => snapshot(empty: true, source: HomeDataSource.offlineCache),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(l10n.offlineSavedData), findsOneWidget);
    expect(find.text(l10n.noStokvels), findsOneWidget);
  });

  testWidgets('API failure displays a safe correlation reference', (
    tester,
  ) async {
    await tester.pumpWidget(
      testApp(
        () async => throw apiError({
          'correlationId': 'RT-TEST-001',
          'detail': 'Private diagnostic information',
        }),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(l10n.errorReference('RT-TEST-001')), findsOneWidget);
    expect(find.text('Private diagnostic information'), findsNothing);
    expect(find.text(l10n.retry), findsOneWidget);
  });

  testWidgets('unsafe reference and raw response are not displayed', (
    tester,
  ) async {
    await tester.pumpWidget(
      testApp(
        () async => throw apiError({
          'correlationId': 'member@example.com',
          'detail': 'Synthetic private information',
        }),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(l10n.loadStokvelsError), findsOneWidget);
    expect(find.textContaining('Reference:'), findsNothing);
    expect(find.textContaining('member@example.com'), findsNothing);
    expect(find.textContaining('Synthetic private information'), findsNothing);
  });

  testWidgets('cached Home can recover to live data', (tester) async {
    var attempts = 0;

    await tester.pumpWidget(
      testApp(() async {
        attempts++;

        return snapshot(
          source: attempts == 1
              ? HomeDataSource.offlineCache
              : HomeDataSource.live,
        );
      }),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10n.retry));
    await tester.pumpAndSettle();

    expect(attempts, 2);
    expect(find.text(l10n.offlineSavedData), findsNothing);
    expect(find.text('Community Savings'), findsOneWidget);
  });

  for (final dark in [false, true]) {
    final mode = dark ? 'dark' : 'light';

    testWidgets('cached Home accessibility in $mode mode', (tester) async {
      final semantics = tester.ensureSemantics();

      try {
        await tester.pumpWidget(
          testApp(
            () async => snapshot(source: HomeDataSource.offlineCache),
            dark: dark,
          ),
        );

        await tester.pumpAndSettle();

        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));

        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

        await expectLater(tester, meetsGuideline(textContrastGuideline));
      } finally {
        semantics.dispose();
      }
    });

    testWidgets('error Home accessibility in $mode mode', (tester) async {
      final semantics = tester.ensureSemantics();

      try {
        await tester.pumpWidget(
          testApp(
            () async => throw apiError({'correlationId': 'RT-TEST-001'}),
            dark: dark,
          ),
        );

        await tester.pumpAndSettle();

        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));

        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

        await expectLater(tester, meetsGuideline(textContrastGuideline));
      } finally {
        semantics.dispose();
      }
    });
  }
}
