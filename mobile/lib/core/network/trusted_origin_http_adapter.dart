import 'dart:typed_data';

import 'package:dio/dio.dart';

class TrustedOriginHttpAdapter implements HttpClientAdapter {
  TrustedOriginHttpAdapter({required this.inner, required this.apiBaseUrl});

  final HttpClientAdapter inner;
  final String apiBaseUrl;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    final requestUri = options.uri;
    final apiUri = Uri.parse(apiBaseUrl);

    final trusted =
        requestUri.scheme == apiUri.scheme &&
        requestUri.host == apiUri.host &&
        requestUri.port == apiUri.port;

    // The adapter receives a protected copy of the request options.
    // A previous interceptor cannot force browser cookies externally.
    final protectedOptions = options.copyWith(
      extra: {...options.extra, 'withCredentials': trusted},
    );

    return inner.fetch(protectedOptions, requestStream, cancelFuture);
  }

  @override
  void close({bool force = false}) {
    inner.close(force: force);
  }
}
