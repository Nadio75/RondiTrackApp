extension type const Cents(int value) {
  Cents operator +(Cents other) => Cents(value + other.value);

  Cents operator -(Cents other) => Cents(value - other.value);
}

sealed class RandParseResult {
  const new();
}

final class ParseSuccess extends RandParseResult {
  const new(this.cents);

  final Cents cents;
}

final class ParseFailure extends RandParseResult {
  const new(this.reason);

  final String reason;
}

String formatRands(Cents amount) {
  final negative = amount.value < 0;
  final absolute = amount.value.abs();
  var rands = absolute ~/ 100;
  final cents = absolute % 100;

  final groups = <String>[];

  do {
    final group = rands % 1000;
    rands ~/= 1000;

    groups.insert(
      0,
      rands > 0 ? group.toString().padLeft(3, '0') : group.toString(),
    );
  } while (rands > 0);

  final wholePart = groups.join('\u00A0');
  final centsPart = cents.toString().padLeft(2, '0');
  final sign = negative ? '-' : '';

  return '$sign'
      'R\u00A0$wholePart,$centsPart';
}

RandParseResult parseRands(String input) {
  var text = input.replaceAll('\u00A0', ' ').trim();

  if (text.startsWith('R')) {
    text = text.substring(1).trimLeft();
  }

  final pattern = RegExp(
    r'^([0-9]{1,3}(?: [0-9]{3})+|[0-9]+)(?:,([0-9]{1,2}))?$',
  );

  final match = pattern.firstMatch(text);

  if (match == null) {
    return const ParseFailure('Invalid rand amount. Example: R 1 500,50');
  }

  final wholeText = match.group(1)!.replaceAll(' ', '');
  final whole = int.tryParse(wholeText);

  if (whole == null) {
    return const ParseFailure('Amount is too large');
  }

  final decimalText = match.group(2) ?? '00';
  final decimal = int.parse(decimalText.padRight(2, '0'));

  return ParseSuccess(Cents(whole * 100 + decimal));
}
