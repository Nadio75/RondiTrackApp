import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/core/network/dio_failure_mapper.dart';
import 'package:ronditrack/core/network/failure.dart';

void main() {
  final request = RequestOptions(path: '/api/v1/me');

  DioException httpError(
    int status, {
    Map<String, dynamic>? body,
    Headers? headers,
  }) {
    return DioException(
      requestOptions: request,
      type: DioExceptionType.badResponse,
      response: Response<dynamic>(
        requestOptions: request,
        statusCode: status,
        data: body,
        headers: headers,
      ),
    );
  }

  test('401 maps to UnauthorizedFailure', () {
    expect(mapDioFailure(httpError(401)), isA<UnauthorizedFailure>());
  });

  test('403 maps to ForbiddenFailure', () {
    expect(mapDioFailure(httpError(403)), isA<ForbiddenFailure>());
  });

  test('404 maps to NotFoundFailure', () {
    expect(mapDioFailure(httpError(404)), isA<NotFoundFailure>());
  });

  test('409 and 412 map to ConflictFailure', () {
    expect(mapDioFailure(httpError(409)), isA<ConflictFailure>());
    expect(mapDioFailure(httpError(412)), isA<ConflictFailure>());
  });

  test('429 preserves Retry-After', () {
    final failure = mapDioFailure(
      httpError(
        429,
        headers: Headers.fromMap({
          'retry-after': ['12'],
        }),
      ),
    );

    expect(failure, isA<RateLimitedFailure>());
    expect(
      (failure as RateLimitedFailure).retryAfter,
      const Duration(seconds: 12),
    );
  });

  test('ProblemDetails correlationId is preserved', () {
    final failure = mapDioFailure(
      httpError(500, body: {'correlationId': 'trace-123'}),
    );

    expect(failure, isA<ServerFailure>());
    expect(failure.correlationId, 'trace-123');
  });

  test('connection timeout maps to TimeoutFailure', () {
    final failure = mapDioFailure(
      DioException(
        requestOptions: request,
        type: DioExceptionType.connectionTimeout,
      ),
    );

    expect(failure, isA<TimeoutFailure>());
  });

  test('connection error maps to OfflineFailure', () {
    final failure = mapDioFailure(
      DioException(
        requestOptions: request,
        type: DioExceptionType.connectionError,
      ),
    );

    expect(failure, isA<OfflineFailure>());
  });

  test('cancelled requests are not treated as offline', () {
    final failure = mapDioFailure(
      DioException(requestOptions: request, type: DioExceptionType.cancel),
    );

    expect(failure, isA<UnknownFailure>());
  });
}
