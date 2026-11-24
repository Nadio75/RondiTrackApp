import 'package:dio/dio.dart';

import 'payment_outbox_api.dart';
import 'payment_outbox_repository.dart';

enum PaymentOutcome {
  recorded,
  pending,
  rateLimited,
  alreadyPaid,
  cycleClosed,
  conflict,
  rejected,
  authenticationRequired,
  expired,
  reviewRequired,
}

class PaymentAttemptResult {
  const PaymentAttemptResult({
    required this.intentId,
    required this.outcome,
    this.retryAtUtc,
  });

  final String intentId;
  final PaymentOutcome outcome;
  final DateTime? retryAtUtc;
}

class PaymentOutboxService {
  factory PaymentOutboxService({
    required PaymentOutboxRepository repository,
    required PaymentOutboxApi api,
    DateTime Function()? clock,
  }) {
    return PaymentOutboxService._(repository, api, clock ?? DateTime.now);
  }

  PaymentOutboxService._(this._repository, this._api, this._clock);

  static const maximumAge = Duration(days: 7);
  static const temporaryRetryDelay = Duration(seconds: 30);
  static const defaultRateLimitDelay = Duration(seconds: 60);

  final PaymentOutboxRepository _repository;
  final PaymentOutboxApi _api;
  final DateTime Function() _clock;

  bool _processing = false;

  bool get isProcessing => _processing;

  Future<List<PaymentAttemptResult>> process({
    required String accountId,
    required bool Function() isSessionCurrent,
  }) async {
    if (_processing || !isSessionCurrent()) {
      return const [];
    }

    _processing = true;
    final results = <PaymentAttemptResult>[];

    try {
      final intents = await _repository.pendingForAccount(accountId);

      for (final intent in intents) {
        if (!isSessionCurrent()) {
          break;
        }

        final now = _clock().toUtc();
        final age = now.difference(intent.createdAtUtc.toUtc());

        Future<void> remove() =>
            _repository.remove(accountId: accountId, intentId: intent.intentId);

        void record(PaymentOutcome outcome, {DateTime? retryAtUtc}) {
          results.add(
            PaymentAttemptResult(
              intentId: intent.intentId,
              outcome: outcome,
              retryAtUtc: retryAtUtc,
            ),
          );
        }

        if (age >= maximumAge) {
          await remove();
          record(PaymentOutcome.expired);
          continue;
        }

        final accountRetryAt = await _repository.accountRetryAt(accountId);

        if (!isSessionCurrent()) {
          break;
        }

        if (accountRetryAt != null && accountRetryAt.isAfter(now)) {
          record(PaymentOutcome.pending, retryAtUtc: accountRetryAt);
          break;
        }

        final nextAttempt = intent.nextAttemptAtUtc;

        if (nextAttempt != null && nextAttempt.toUtc().isAfter(now)) {
          record(PaymentOutcome.pending, retryAtUtc: nextAttempt.toUtc());
          break;
        }

        try {
          await _api.send(intent, idempotencyKey: intent.idempotencyKey);

          if (!isSessionCurrent()) {
            break;
          }

          await remove();
          record(PaymentOutcome.recorded);
        } on DioException catch (error) {
          if (!isSessionCurrent()) {
            break;
          }

          final status = error.response?.statusCode;

          if (status == 401) {
            record(PaymentOutcome.authenticationRequired);
            break;
          }

          if (status == 409) {
            final outcome = _conflictOutcome(error);

            await remove();
            record(outcome);
            continue;
          }

          if (const {400, 403, 404, 422}.contains(status)) {
            await remove();
            record(PaymentOutcome.rejected);
            continue;
          }

          if (status == 429) {
            final retryAt = _clock().toUtc().add(_retryAfter(error));

            await _repository.deferAccount(
              accountId: accountId,
              retryAtUtc: retryAt,
              isSessionCurrent: isSessionCurrent,
            );

            if (!isSessionCurrent()) {
              break;
            }

            await _repository.defer(
              accountId: accountId,
              intentId: intent.intentId,
              nextAttemptAtUtc: retryAt,
            );

            record(PaymentOutcome.rateLimited, retryAtUtc: retryAt);

            break;
          }

          if (_isTemporary(error)) {
            final retryAt = _clock().toUtc().add(temporaryRetryDelay);

            await _repository.defer(
              accountId: accountId,
              intentId: intent.intentId,
              nextAttemptAtUtc: retryAt,
            );

            record(PaymentOutcome.pending, retryAtUtc: retryAt);

            break;
          }

          record(PaymentOutcome.reviewRequired);
          break;
        }
      }

      return List.unmodifiable(results);
    } finally {
      _processing = false;
    }
  }

  Duration _retryAfter(DioException error) {
    final raw = error.response?.headers.value('retry-after');
    final seconds = int.tryParse(raw?.trim() ?? '');

    if (seconds == null || seconds < 0) {
      return defaultRateLimitDelay;
    }

    return Duration(seconds: seconds);
  }

  bool _isTemporary(DioException error) {
    final status = error.response?.statusCode;

    if (status != null) {
      return status >= 500 && status <= 599;
    }

    return switch (error.type) {
      DioExceptionType.connectionError ||
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.transformTimeout => true,
      _ => false,
    };
  }

  PaymentOutcome _conflictOutcome(DioException error) {
    final body = error.response?.data;

    if (body is Map) {
      final title = body['title']?.toString().toLowerCase() ?? '';
      final detail = body['detail']?.toString().toLowerCase() ?? '';

      if (title.contains('idempotency')) {
        return PaymentOutcome.conflict;
      }

      if (detail.contains('already paid')) {
        return PaymentOutcome.alreadyPaid;
      }

      if (detail.contains('closed')) {
        return PaymentOutcome.cycleClosed;
      }
    }

    return PaymentOutcome.conflict;
  }
}
