sealed class Failure {
  const Failure({this.correlationId});

  final String? correlationId;
}

final class OfflineFailure extends Failure {
  const OfflineFailure({super.correlationId});
}

final class TimeoutFailure extends Failure {
  const TimeoutFailure({super.correlationId});
}

final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({super.correlationId});
}

final class ForbiddenFailure extends Failure {
  const ForbiddenFailure({super.correlationId});
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure({super.correlationId});
}

final class ConflictFailure extends Failure {
  const ConflictFailure({super.correlationId});
}

final class RateLimitedFailure extends Failure {
  const RateLimitedFailure({this.retryAfter, super.correlationId});

  final Duration? retryAfter;
}

final class ValidationFailure extends Failure {
  const ValidationFailure({required this.statusCode, super.correlationId});

  final int statusCode;
}

final class ServerFailure extends Failure {
  const ServerFailure({this.statusCode, super.correlationId});

  final int? statusCode;
}

final class UnknownFailure extends Failure {
  const UnknownFailure({super.correlationId});
}
