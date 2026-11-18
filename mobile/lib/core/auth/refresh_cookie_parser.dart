/// Extracts the value of a specifically named refresh cookie.
///
/// Returns null when the cookie is absent or its value is empty.
/// Never log or print the returned credential.
String? extractRefreshCookie({
  required List<String> setCookieHeaders,
  required String cookieName,
}) {
  if (cookieName.isEmpty) {
    throw ArgumentError.value(cookieName, 'cookieName');
  }

  for (final header in setCookieHeaders) {
    // Each Set-Cookie header begins with a cookie-name=value pair.
    // Attributes such as Path and HttpOnly follow the first semicolon.
    final firstPart = header.split(';').first.trim();
    final separator = firstPart.indexOf('=');

    if (separator <= 0) continue;

    final name = firstPart.substring(0, separator).trim();
    final value = firstPart.substring(separator + 1).trim();

    if (name == cookieName && value.isNotEmpty) {
      return value;
    }
  }

  return null;
}
