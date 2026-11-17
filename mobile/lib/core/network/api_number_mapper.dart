import '../money/cents.dart';

/// Parses an API integer represented as either a JSON integer
/// or a base-10 integer string.
int parseApiInteger(Object? value) {
  if (value is int) {
    return value;
  }

  if (value is String && RegExp(r'^-?(0|[1-9][0-9]*)$').hasMatch(value)) {
    final parsed = int.tryParse(value);
    if (parsed != null) {
      return parsed;
    }
  }

  throw FormatException('Invalid API integer');
}

/// Converts an integer-cent API value without changing its unit.
Cents parseApiCents(Object? value) {
  return Cents(parseApiInteger(value));
}

/// Converts a decimal rand amount into integer cents.
///
/// Uses decimal string arithmetic to avoid binary floating-point
/// rounding errors and rounds half away from zero.
Cents parseApiRands(Object? value) {
  if (value is! num && value is! String) {
    throw FormatException('Invalid rand amount');
  }

  final text = value.toString();

  final match = RegExp(r'^(-?)([0-9]+)(?:\.([0-9]+))?$').firstMatch(text);

  if (match == null) {
    throw FormatException('Invalid rand amount');
  }

  final negative = match.group(1) == '-';
  final whole = int.tryParse(match.group(2)!);

  if (whole == null) {
    throw FormatException('Rand amount is too large');
  }

  final fraction = match.group(3) ?? '';
  final firstTwo = fraction.padRight(2, '0').substring(0, 2);
  final centsPart = int.parse(firstTwo);

  final roundUp = fraction.length > 2 && int.parse(fraction[2]) >= 5;

  final amount = whole * 100 + centsPart + (roundUp ? 1 : 0);

  return Cents(negative ? -amount : amount);
}
