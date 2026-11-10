import 'cents.dart';

sealed class RandParseResult {
  const RandParseResult();
}

final class RandParseSuccess extends RandParseResult {
  const RandParseSuccess(this.amount);

  final Cents amount;
}

final class RandParseFailure extends RandParseResult {
  const RandParseFailure(this.reason);

  final String reason;
}

/// Parses rand amounts using integer arithmetic only.
///
/// A comma or full stop may be used as the decimal separator.
RandParseResult parseRandsStrict(String input) {
  var text = input.trim().replaceAll('\u00A0', ' ');

  if (text.isEmpty) {
    return const RandParseFailure('Enter an amount.');
  }

  if (text.startsWith('R')) {
    text = text.substring(1).trimLeft();
  }

  final pattern = RegExp(
    r'^(?:[0-9]+|[0-9]{1,3}(?: [0-9]{3})+)(?:[,\.][0-9]{1,2})?$',
  );

  if (!pattern.hasMatch(text)) {
    return const RandParseFailure('Invalid rand amount.');
  }

  final normalized = text.replaceAll(' ', '').replaceAll(',', '.');
  final parts = normalized.split('.');

  final whole = int.tryParse(parts[0]);

  if (whole == null) {
    return const RandParseFailure('Amount is too large.');
  }

  var cents = 0;

  if (parts.length == 2) {
    cents = int.parse(parts[1].padRight(2, '0'));
  }

  final maximumWhole = (0x7FFFFFFFFFFFFFFF - cents) ~/ 100;

  if (whole > maximumWhole) {
    return const RandParseFailure('Amount is too large.');
  }

  return RandParseSuccess(Cents(whole * 100 + cents));
}
