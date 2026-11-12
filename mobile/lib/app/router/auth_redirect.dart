bool _isSafeDestination(String location) {
  if (!location.startsWith('/') || location.startsWith('//')) {
    return false;
  }

  final uri = Uri.tryParse(location);

  if (uri == null ||
      uri.hasScheme ||
      uri.hasAuthority ||
      uri.userInfo.isNotEmpty ||
      uri.host.isNotEmpty) {
    return false;
  }

  final segments = uri.pathSegments;

  if (segments.any((segment) => segment == '.' || segment == '..')) {
    return false;
  }

  if (uri.path == '/home' ||
      uri.path == '/stokvels' ||
      uri.path == '/activity' ||
      uri.path == '/profile') {
    return true;
  }

  if (segments.length == 2 && segments[0] == 'join' && segments[1].isNotEmpty) {
    return true;
  }

  if (segments.length == 2 &&
      segments[0] == 'stokvels' &&
      segments[1].isNotEmpty) {
    return true;
  }

  if (segments.length == 4 &&
      segments[0] == 'stokvels' &&
      segments[1].isNotEmpty &&
      segments[2] == 'cycles' &&
      segments[3].isNotEmpty) {
    return true;
  }

  if (segments.length == 5 &&
      segments[0] == 'stokvels' &&
      segments[1].isNotEmpty &&
      segments[2] == 'cycles' &&
      segments[3].isNotEmpty &&
      segments[4] == 'payout-rotation') {
    return true;
  }

  return false;
}

String? authRedirect({required bool signedIn, required String location}) {
  final uri = Uri.tryParse(location);

  if (uri == null) {
    return '/home';
  }

  final onSignInPage = uri.path == '/sign-in';

  if (!signedIn && !onSignInPage) {
    if (_isSafeDestination(location)) {
      return Uri(
        path: '/sign-in',
        queryParameters: {'from': location},
      ).toString();
    }

    return '/sign-in';
  }

  if (signedIn && onSignInPage) {
    final from = uri.queryParameters['from'];

    if (from != null && _isSafeDestination(from)) {
      return from;
    }

    return '/home';
  }

  return null;
}
