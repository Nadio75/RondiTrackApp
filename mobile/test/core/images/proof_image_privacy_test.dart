import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:ronditrack/core/images/proof_image_processor.dart';

bool containsBytes(List<int> bytes, List<int> pattern) {
  for (var i = 0; i <= bytes.length - pattern.length; i++) {
    var matches = true;

    for (var j = 0; j < pattern.length; j++) {
      if (bytes[i + j] != pattern[j]) {
        matches = false;
        break;
      }
    }

    if (matches) return true;
  }

  return false;
}

void main() {
  test('removes embedded GPS EXIF metadata', () {
    final source = File('test/fixtures/images/synthetic_gps.jpg')
        .readAsBytesSync();

    const exif = [0x45, 0x78, 0x69, 0x66, 0, 0];

    const gpsPointer = [0x88, 0x25, 0x00, 0x04, 0x00, 0x00, 0x00, 0x01];

    expect(containsBytes(source, exif), isTrue);
    expect(containsBytes(source, gpsPointer), isTrue);
    expect(img.decodeJpg(source), isNotNull);

    final result = ProofImageProcessor.process(source);

    expect(img.decodeJpg(result), isNotNull);
    expect(containsBytes(result, exif), isFalse);
    expect(containsBytes(result, gpsPointer), isFalse);

    expect(result.length, lessThanOrEqualTo(ProofImageProcessor.maxBytes));
  });
}
