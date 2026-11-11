import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/core/theme/rondi_theme.dart';

double contrastRatio(Color first, Color second) {
  final a = first.computeLuminance();
  final b = second.computeLuminance();

  return (math.max(a, b) + 0.05) / (math.min(a, b) + 0.05);
}

void main() {
  for (final theme in [RondiTheme.light, RondiTheme.dark]) {
    final mode = theme.brightness.name;

    group('$mode theme contrast', () {
      test('Normal text meets 4.5:1', () {
        final ratio = contrastRatio(
          theme.colorScheme.onSurface,
          theme.colorScheme.surface,
        );

        expect(ratio, greaterThanOrEqualTo(4.5));
      });

      test('Paid status meets 4.5:1', () {
        final colors = theme.extension<RondiStatusColors>()!;
        final ratio = contrastRatio(colors.paid, theme.colorScheme.surface);

        expect(ratio, greaterThanOrEqualTo(4.5));
      });

      test('Pending status meets 4.5:1', () {
        final colors = theme.extension<RondiStatusColors>()!;
        final ratio = contrastRatio(colors.pending, theme.colorScheme.surface);

        expect(ratio, greaterThanOrEqualTo(4.5));
      });

      test('Overdue status meets 4.5:1', () {
        final colors = theme.extension<RondiStatusColors>()!;
        final ratio = contrastRatio(colors.overdue, theme.colorScheme.surface);

        expect(ratio, greaterThanOrEqualTo(4.5));
      });
    });
  }
}
