import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'package:ronditrack/core/images/proof_image_processor.dart';

void main() {
  test('converts PNG to JPEG', () {
    final source = img.Image(width: 100, height: 100);

    final result = ProofImageProcessor.process(img.encodePng(source));

    expect(result[0], 0xFF);
    expect(result[1], 0xD8);
    expect(img.decodeJpg(result), isNotNull);
  });

  test('resizes landscape images', () {
    final source = img.Image(width: 2400, height: 1200);

    final result = img.decodeJpg(
      ProofImageProcessor.process(img.encodePng(source)),
    )!;

    expect(result.width, 1600);
    expect(result.height, 800);
  });

  test('resizes portrait images', () {
    final source = img.Image(width: 1200, height: 2400);

    final result = img.decodeJpg(
      ProofImageProcessor.process(img.encodePng(source)),
    )!;

    expect(result.width, 800);
    expect(result.height, 1600);
  });

  test('does not enlarge small images', () {
    final source = img.Image(width: 300, height: 200);

    final result = img.decodeJpg(
      ProofImageProcessor.process(img.encodePng(source)),
    )!;

    expect(result.width, 300);
    expect(result.height, 200);
  });

  test('output remains within upload limit', () {
    final source = img.Image(width: 2000, height: 2000);

    final result = ProofImageProcessor.process(img.encodePng(source));

    expect(result.length, lessThanOrEqualTo(ProofImageProcessor.maxBytes));
  });

  test('rejects empty images', () {
    expect(
      () => ProofImageProcessor.process(Uint8List(0)),
      throwsFormatException,
    );
  });

  test('rejects invalid image data', () {
    expect(
      () => ProofImageProcessor.process(Uint8List.fromList([1, 2, 3, 4])),
      throwsFormatException,
    );
  });
}
