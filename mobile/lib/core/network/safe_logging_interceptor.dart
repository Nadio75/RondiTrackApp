import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class SafeLoggingInterceptor extends Interceptor {
  static const _startedAt = 'safeLogStartedAt';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startedAt] = DateTime.now();
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _log(response.requestOptions, response.statusCode, response.data);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _log(err.requestOptions, err.response?.statusCode, err.response?.data);
    handler.next(err);
  }

  void _log(RequestOptions options, int? status, dynamic body) {
    if (!kDebugMode) return;

    final startedAt = options.extra[_startedAt];
    final elapsed = startedAt is DateTime
        ? DateTime.now().difference(startedAt).inMilliseconds
        : null;

    String? correlationId;

    if (body is Map && body['correlationId'] is String) {
      correlationId = body['correlationId'] as String;
    }

    // Never log query parameters, headers, cookies or bodies.
    debugPrint(
      '[HTTP] ${options.method} ${options.uri.path} '
      'status=${status ?? 'none'} '
      'durationMs=${elapsed ?? 'unknown'} '
      'correlationId=${correlationId ?? 'none'}',
    );
  }
}
