import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/main.dart';

void main() {
  testWidgets('RondiTrack application starts successfully', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: RondiTrackApp()));

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
