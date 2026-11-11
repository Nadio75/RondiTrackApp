import 'package:flutter/material.dart';

@immutable
class RondiStatusColors extends ThemeExtension<RondiStatusColors> {
  const RondiStatusColors({
    required this.paid,
    required this.pending,
    required this.overdue,
  });

  final Color paid;
  final Color pending;
  final Color overdue;

  @override
  RondiStatusColors copyWith({Color? paid, Color? pending, Color? overdue}) {
    return RondiStatusColors(
      paid: paid ?? this.paid,
      pending: pending ?? this.pending,
      overdue: overdue ?? this.overdue,
    );
  }

  @override
  RondiStatusColors lerp(ThemeExtension<RondiStatusColors>? other, double t) {
    if (other is! RondiStatusColors) {
      return this;
    }

    return RondiStatusColors(
      paid: Color.lerp(paid, other.paid, t)!,
      pending: Color.lerp(pending, other.pending, t)!,
      overdue: Color.lerp(overdue, other.overdue, t)!,
    );
  }
}

class RondiTheme {
  static const Color seed = Color(0xFF386A3B);

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    );

    final statusColors = brightness == Brightness.light
        ? const RondiStatusColors(
            paid: Color(0xFF216E39),
            pending: Color(0xFF855400),
            overdue: Color(0xFFB3261E),
          )
        : const RondiStatusColors(
            paid: Color(0xFF91D5A2),
            pending: Color(0xFFFFCA78),
            overdue: Color(0xFFFFB4AB),
          );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      extensions: [statusColors],
    );
  }
}
