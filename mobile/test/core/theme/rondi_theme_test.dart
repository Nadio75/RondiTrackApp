import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/core/theme/rondi_theme.dart';

void main() {
  group('RondiTrack themes', () {
    test('Light theme uses Material 3', () {
      expect(RondiTheme.light.useMaterial3, isTrue);
      expect(RondiTheme.light.brightness, Brightness.light);
    });

    test('Dark theme uses Material 3', () {
      expect(RondiTheme.dark.useMaterial3, isTrue);
      expect(RondiTheme.dark.brightness, Brightness.dark);
    });

    test('Light theme provides status colors', () {
      final colors = RondiTheme.light.extension<RondiStatusColors>();

      expect(colors, isNotNull);
      expect(colors!.paid, isNot(colors.pending));
      expect(colors.pending, isNot(colors.overdue));
    });

    test('Dark theme provides status colors', () {
      final colors = RondiTheme.dark.extension<RondiStatusColors>();

      expect(colors, isNotNull);
      expect(colors!.paid, isNot(colors.pending));
      expect(colors.pending, isNot(colors.overdue));
    });
  });
}
