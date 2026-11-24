import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/core/money/parse_rands.dart';

void main() {
  test('normal rand amount preserves exact cents', () {
    final result = parseRandsStrict('500.25');

    expect(result, isA<RandParseSuccess>());
    expect((result as RandParseSuccess).amount.value, 50025);
  });

  test('maximum JavaScript safe amount is accepted', () {
    final result = parseRandsStrict('90071992547409.91');

    expect(result, isA<RandParseSuccess>());
    expect((result as RandParseSuccess).amount.value, 9007199254740991);
  });

  test('amount above safe integer limit is rejected', () {
    expect(parseRandsStrict('90071992547409.92'), isA<RandParseFailure>());
  });

  test('oversized whole rand amount is rejected', () {
    expect(parseRandsStrict('90071992547410'), isA<RandParseFailure>());
  });

  test('extremely large amount is rejected', () {
    expect(
      parseRandsStrict('999999999999999999999999999999'),
      isA<RandParseFailure>(),
    );
  });
}
