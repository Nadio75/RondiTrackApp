void validateAppConfig({
  required String flavor,
  required String apiUrl,
  required String? nativeFlavor,
  required bool runningOnWeb,
}) {
  if (flavor.isEmpty || apiUrl.isEmpty) {
    throw StateError('Missing RondiTrack configuration');
  }

  if (!const {'dev', 'staging', 'prod'}.contains(flavor)) {
    throw StateError('Unknown configuration flavour: $flavor');
  }

  if (!runningOnWeb && nativeFlavor != flavor) {
    throw StateError('Native flavour does not match configuration');
  }
}
