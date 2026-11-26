import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ronditrack/core/network/dio_failure_mapper.dart';
import 'package:ronditrack/core/network/failure.dart';

DioException httpError(int status, {Object? body, Headers? headers}) {
  final request = RequestOptions(path: '/api/v1/test');

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

DioException transportError(DioExceptionType type) {
  return DioException(
    requestOptions: RequestOptions(path: '/api/v1/test'),
    type: type,
  );
}

void main() {
  group('Client validation failures', () {
    for (final status in [400, 422]) {
      test('HTTP $status maps to validation failure', () {
        final failure = mapDioFailure(httpError(status));

        expect(failure, isA<ValidationFailure>());
        expect((failure as ValidationFailure).statusCode, status);
        expect(failure.correlationId, isNull);
      });

      test('HTTP $status preserves validation reference', () {
        final failure = mapDioFailure(
          httpError(
            status,
            body: {
              'title': 'Validation failed',
              'correlationId': 'validation-reference',
              'detail': 'Synthetic invalid request',
            },
          ),
        );

        expect(failure, isA<ValidationFailure>());
        expect((failure as ValidationFailure).statusCode, status);
        expect(failure.correlationId, 'validation-reference');
      });
    }
  });

  group('HTTP failure mapping table', () {
    final cases = <int, Matcher>{
      401: isA<UnauthorizedFailure>(),
      403: isA<ForbiddenFailure>(),
      404: isA<NotFoundFailure>(),
      409: isA<ConflictFailure>(),
      412: isA<ConflictFailure>(),
      429: isA<RateLimitedFailure>(),
      500: isA<ServerFailure>(),
      502: isA<ServerFailure>(),
      503: isA<ServerFailure>(),
      504: isA<ServerFailure>(),
    };

    for (final entry in cases.entries) {
      test('HTTP ${entry.key} maps to expected failure', () {
        final failure = mapDioFailure(httpError(entry.key));

        expect(failure, entry.value);
      });
    }
  });

  group('ProblemDetails and correlation IDs', () {
    test('complete ProblemDetails preserves reference', () {
      final failure = mapDioFailure(
        httpError(
          409,
          body: {
            'type': 'https://example.invalid/conflict',
            'title': 'Conflict',
            'status': 409,
            'detail': 'Synthetic conflict',
            'correlationId': 'reference-001',
          },
        ),
      );

      expect(failure, isA<ConflictFailure>());
      expect(failure.correlationId, 'reference-001');
    });

    test('missing correlation ID is handled safely', () {
      final failure = mapDioFailure(
        httpError(500, body: {'title': 'Server error'}),
      );

      expect(failure, isA<ServerFailure>());
      expect(failure.correlationId, isNull);
    });

    test('empty correlation ID is ignored', () {
      final failure = mapDioFailure(
        httpError(500, body: {'correlationId': ''}),
      );

      expect(failure.correlationId, isNull);
    });

    test('invalid correlation ID type is ignored', () {
      final failure = mapDioFailure(
        httpError(500, body: {'correlationId': 12345}),
      );

      expect(failure.correlationId, isNull);
    });

    test('HTML proxy response does not crash mapper', () {
      final failure = mapDioFailure(
        httpError(502, body: '<html><body>Bad Gateway</body></html>'),
      );

      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).statusCode, 502);
      expect(failure.correlationId, isNull);
    });

    test('unexpected JSON list is handled safely', () {
      final failure = mapDioFailure(
        httpError(503, body: ['unexpected', 'response']),
      );

      expect(failure, isA<ServerFailure>());
      expect(failure.correlationId, isNull);
    });

    test('empty response body is handled safely', () {
      final failure = mapDioFailure(httpError(500));

      expect(failure, isA<ServerFailure>());
      expect(failure.correlationId, isNull);
    });
  });

  group('Rate limiting', () {
    test('valid Retry-After seconds are preserved', () {
      final failure = mapDioFailure(
        httpError(
          429,
          headers: Headers.fromMap({
            'retry-after': ['120'],
          }),
          body: {'correlationId': 'rate-limit-reference'},
        ),
      ) as RateLimitedFailure;

      expect(failure.retryAfter, const Duration(seconds: 120));

      expect(failure.correlationId, 'rate-limit-reference');
    });

    test('zero Retry-After is accepted', () {
      final failure = mapDioFailure(
        httpError(
          429,
          headers: Headers.fromMap({
            'retry-after': ['0'],
          }),
        ),
      ) as RateLimitedFailure;

      expect(failure.retryAfter, Duration.zero);
    });

    for (final value in ['invalid', '-5', '']) {
      test('invalid Retry-After "$value" is ignored', () {
        final failure = mapDioFailure(
          httpError(
            429,
            headers: Headers.fromMap({
              'retry-after': [value],
            }),
          ),
        ) as RateLimitedFailure;

        expect(failure.retryAfter, isNull);
      });
    }

    test('missing Retry-After is handled safely', () {
      final failure = mapDioFailure(httpError(429)) as RateLimitedFailure;

      expect(failure.retryAfter, isNull);
    });
  });

  group('Transport failures without HTTP responses', () {
    final cases = <DioExceptionType, Matcher>{
      DioExceptionType.connectionTimeout: isA<TimeoutFailure>(),
      DioExceptionType.sendTimeout: isA<TimeoutFailure>(),
      DioExceptionType.receiveTimeout: isA<TimeoutFailure>(),
      DioExceptionType.transformTimeout: isA<TimeoutFailure>(),
      DioExceptionType.connectionError: isA<OfflineFailure>(),
      DioExceptionType.badCertificate: isA<UnknownFailure>(),
      DioExceptionType.cancel: isA<UnknownFailure>(),
      DioExceptionType.unknown: isA<UnknownFailure>(),
      DioExceptionType.badResponse: isA<UnknownFailure>(),
    };

    for (final entry in cases.entries) {
      test('${entry.key.name} maps safely', () {
        final failure = mapDioFailure(transportError(entry.key));

        expect(failure, entry.value);
        expect(failure.correlationId, isNull);
      });
    }
  });

  test('concurrent failures retain independent references', () async {
    final failures = await Future.wait([
      Future<Failure>(() {
        return mapDioFailure(
          httpError(409, body: {'correlationId': 'first-reference'}),
        );
      }),
      Future<Failure>(() {
        return mapDioFailure(
          httpError(503, body: {'correlationId': 'second-reference'}),
        );
      }),
    ]);

    expect(failures[0], isA<ConflictFailure>());
    expect(failures[0].correlationId, 'first-reference');

    expect(failures[1], isA<ServerFailure>());
    expect(failures[1].correlationId, 'second-reference');
  });
}
