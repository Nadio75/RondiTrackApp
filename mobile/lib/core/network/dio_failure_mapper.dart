import 'package:dio/dio.dart';

import 'failure.dart';

Failure mapDioFailure(DioException exception) {
  final response = exception.response;
  final status = response?.statusCode;
  final correlationId = _correlationId(response?.data);

  switch (status) {
    case 400:
    case 422:
      return ValidationFailure(
        statusCode: status!,
        correlationId: correlationId,
      );
    case 401:
      return UnauthorizedFailure(correlationId: correlationId);
    case 403:
      return ForbiddenFailure(correlationId: correlationId);
    case 404:
      return NotFoundFailure(correlationId: correlationId);
    case 409:
    case 412:
      return ConflictFailure(correlationId: correlationId);
    case 429:
      return RateLimitedFailure(
        correlationId: correlationId,
        retryAfter: _retryAfter(response?.headers),
      );
  }

  if (status != null) {
    return ServerFailure(statusCode: status, correlationId: correlationId);
  }

  switch (exception.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return const TimeoutFailure();

    case DioExceptionType.connectionError:
      return const OfflineFailure();

    case DioExceptionType.badCertificate:
    case DioExceptionType.cancel:
    case DioExceptionType.unknown:
    case DioExceptionType.badResponse:
      return const UnknownFailure();
  }
}

String? _correlationId(dynamic body) {
  if (body is! Map) return null;

  final value = body['correlationId'];
  if (value is! String || value.isEmpty) return null;

  return value;
}

Duration? _retryAfter(Headers? headers) {
  if (headers == null) return null;

  final raw = headers.value('retry-after');
  if (raw == null) return null;

  final seconds = int.tryParse(raw.trim());
  if (seconds == null || seconds < 0) return null;

  return Duration(seconds: seconds);
}
