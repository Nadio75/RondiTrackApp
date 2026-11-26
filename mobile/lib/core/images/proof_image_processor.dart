import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

class ProofImageProcessor {
  static const maxBytes = 5 * 1024 * 1024;
  static const maxInputBytes = 25 * 1024 * 1024;
  static const maxDimension = 1600;

  static Future<Uint8List> prepare(Uint8List bytes) async {
    if (bytes.isEmpty || bytes.length > maxInputBytes) {
      throw const FormatException('Select an image smaller than 25 MiB.');
    }

    return compute(process, bytes);
  }

  static Uint8List process(Uint8List bytes) {
    if (bytes.isEmpty || bytes.length > maxInputBytes) {
      throw const FormatException('Invalid image size.');
    }

    final decoded = img.decodeImage(bytes);

    if (decoded == null) {
      throw const FormatException('Unable to read the selected image.');
    }

    var image = img.bakeOrientation(decoded);

    if (image.width > maxDimension || image.height > maxDimension) {
      image = img.copyResize(
        image,
        width: image.width >= image.height ? maxDimension : null,
        height: image.height > image.width ? maxDimension : null,
        interpolation: img.Interpolation.average,
      );
    }

    // Create a fresh image containing only pixel data.
    // Source EXIF, GPS, XMP and other metadata are not copied.
    final clean = img.Image(
      width: image.width,
      height: image.height,
      numChannels: 3,
    );

    for (final pixel in image) {
      clean.setPixelRgb(
        pixel.x,
        pixel.y,
        pixel.rNormalized * 255,
        pixel.gNormalized * 255,
        pixel.bNormalized * 255,
      );
    }

    for (final quality in [90, 80, 70, 60, 50, 40, 30]) {
      final encoded = img.encodeJpg(clean, quality: quality);

      if (encoded.length <= maxBytes) {
        return encoded;
      }
    }

    throw const FormatException(
      'The image is too large. Select a smaller photograph.',
    );
  }
}
