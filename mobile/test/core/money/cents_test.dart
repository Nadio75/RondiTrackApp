import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/core/money/cents.dart';

void main() {
  group('Rand formatter', () {
    test('formats the required amounts', () {
      expect(formatRands(Cents(10)), 'R\u00A00,10');
      expect(formatRands(Cents(15050)), 'R\u00A0150,50');
      expect(formatRands(Cents(150000)), 'R\u00A01\u00A0500,00');
      expect(formatRands(Cents(100000000)), 'R\u00A01\u00A0000\u00A0000,00');
      expect(formatRands(Cents(-15050)), '-R\u00A0150,50');
    });
  });

  group('Rand parser', () {
    test('accepts valid input', () {
      final cases = <String, int>{
        '150': 15000,
        '150,50': 15050,
        'R150': 15000,
        'R 1 500': 150000,
        '1 500,50': 150050,
        '1\u00A0500,50': 150050,
      };

      for (final entry in cases.entries) {
        final result = parseRands(entry.key);
        expect(result, isA<ParseSuccess>());

        if (result is ParseSuccess) {
          expect(result.cents.value, entry.value);
        }
      }
    });

    test('rejects invalid input', () {
      final invalid = ['1,500.50', '150,505', '150.', '', 'hello', '12 34'];

      for (final input in invalid) {
        expect(parseRands(input), isA<ParseFailure>());
      }
    });
  });
}
