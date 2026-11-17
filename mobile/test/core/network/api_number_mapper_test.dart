import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/core/network/api_number_mapper.dart';

void main() {
  group('parseApiInteger', () {
    test('accepts integer JSON values', () {
      expect(parseApiInteger(50000), 50000);
    });

    test('accepts integer strings', () {
      expect(parseApiInteger('50000'), 50000);
    });

    test('rejects fractional numbers', () {
      expect(() => parseApiInteger(500.5), throwsFormatException);
    });

    test('rejects invalid strings', () {
      expect(() => parseApiInteger('50.00'), throwsFormatException);
    });
  });

  group('parseApiCents', () {
    test('preserves integer cents', () {
      expect(parseApiCents('50000').value, 50000);
    });
  });

  group('parseApiRands', () {
    test('converts R500 to 50000 cents', () {
      expect(parseApiRands(500).value, 50000);
    });

    test('preserves decimal cents', () {
      expect(parseApiRands('500.25').value, 50025);
    });

    test('rounds half away from zero', () {
      expect(parseApiRands('1.005').value, 101);
      expect(parseApiRands('-1.005').value, -101);
    });

    test('rejects invalid amounts', () {
      expect(() => parseApiRands('not money'), throwsFormatException);
    });
  });
}
