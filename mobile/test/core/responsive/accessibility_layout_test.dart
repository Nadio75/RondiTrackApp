import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Navigation destinations fit at 360dp and 200% text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(360, 800),
            textScaler: TextScaler.linear(2),
          ),
          child: Scaffold(
            bottomNavigationBar: NavigationBar(
              destinations: [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.groups_outlined),
                  label: 'Stokvels',
                ),
                NavigationDestination(
                  icon: Icon(Icons.history),
                  label: 'Activity',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
