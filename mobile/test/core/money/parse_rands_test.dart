import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/core/money/cents.dart';
import 'package:ronditrack/core/money/parse_rands.dart';

void main() {
  group('parseRands', () {
    final validCases = <String, int>{
      '150': 15000,
      '150,50': 15050,
      'R150': 15000,
      'R 1 500': 150000,
      '1 500,50': 150050,
      '1\u00A0500,50': 150050,
      '150.50': 15050,
      '0,10': 10,
      '150,5': 15050,
    };

    for (final entry in validCases.entries) {
      test('accepts ${entry.key}', () {
        final result = parseRandsStrict(entry.key);

        expect(result, isA<RandParseSuccess>());
        expect((result as RandParseSuccess).amount, Cents(entry.value));
      });
    }

    final invalidCases = [
      '1,500.50',
      '150,505',
      '150.',
      '',
      'hello',
      'Rabc',
      '12 34',
      '1 50,00',
      '999999999999999999999999999',
    ];

    for (final input in invalidCases) {
      test('rejects "$input"', () {
        final result = parseRandsStrict(input);

        expect(result, isA<RandParseFailure>());
        expect((result as RandParseFailure).reason, isNotEmpty);
      });
    }
  });
}
