import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:ronditrack/core/config/app_version_provider.dart';
import 'package:ronditrack/features/profile/presentation/app_version_tile.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('reads installed package metadata', () async {
    PackageInfo.setMockInitialValues(
      appName: 'RondiTrack',
      packageName: 'za.co.maja.ronditrack',
      version: '2.3.4',
      buildNumber: '57',
      buildSignature: '',
    );

    final container = ProviderContainer();
    addTearDown(container.dispose);

    final info = await container.read(appVersionProvider.future);

    expect(info.version, '2.3.4');
    expect(info.buildNumber, '57');
  });

  test('environment labels match configured flavours', () {
    expect(appEnvironmentLabel('dev'), 'Development');
    expect(appEnvironmentLabel('staging'), 'Staging');
    expect(appEnvironmentLabel('prod'), 'Production');
    expect(appEnvironmentLabel('invalid'), 'Unknown');
  });

  testWidgets('displays actual supplied version and build number', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appVersionProvider.overrideWith((ref) async {
            return PackageInfo(
              appName: 'RondiTrack',
              packageName: 'za.co.maja.ronditrack',
              version: '3.2.1',
              buildNumber: '42',
              buildSignature: '',
            );
          }),
        ],
        child: const MaterialApp(home: Scaffold(body: AppVersionTile())),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('3.2.1 (42)'), findsOneWidget);
    expect(find.byKey(const Key('installed_app_environment')), findsOneWidget);
  });

  testWidgets('handles unavailable package metadata', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appVersionProvider.overrideWith((ref) async {
            throw StateError('Metadata unavailable');
          }),
        ],
        child: const MaterialApp(home: Scaffold(body: AppVersionTile())),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Version unavailable'), findsOneWidget);
  });
}
