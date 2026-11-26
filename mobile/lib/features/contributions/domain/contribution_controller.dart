import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/money/parse_rands.dart';
import '../../../core/offline/payment_outbox_providers.dart';
import '../../../core/offline/payment_outbox_service.dart';
import '../../session/presentation/session_provider.dart';
import '../../session/presentation/session_origin_provider.dart';

class ContributionController extends Notifier<bool> {
  @override
  bool build() => false;

  Future<PaymentOutcome?> retryPending({
    required String stokvelId,
    required String cycleId,
    required String memberId,
  }) async {
    if (state) {
      return PaymentOutcome.pending;
    }

    final user = ref.read(sessionProvider);

    if (user == null ||
        user.id != memberId ||
        ref.read(sessionOriginProvider).name != 'api') {
      return PaymentOutcome.authenticationRequired;
    }

    final accountId = user.id;
    final generation = ref.read(sessionProvider.notifier).sessionGeneration;

    bool isSessionCurrent() {
      return ref.read(sessionProvider)?.id == accountId &&
          ref.read(sessionOriginProvider).name == 'api' &&
          ref.read(sessionProvider.notifier).sessionGeneration == generation;
    }

    state = true;

    try {
      final repository = ref.read(paymentOutboxRepositoryProvider);
      final service = ref.read(paymentOutboxServiceProvider);

      final pending = await repository.pendingForAccount(accountId);

      if (!isSessionCurrent()) {
        return PaymentOutcome.authenticationRequired;
      }

      final matching = pending
          .where(
            (intent) =>
                intent.stokvelId == stokvelId &&
                intent.cycleId == cycleId &&
                intent.memberId == memberId,
          )
          .firstOrNull;

      if (matching == null) {
        return null;
      }

      final results = await service.process(
        accountId: accountId,
        isSessionCurrent: isSessionCurrent,
      );

      if (!isSessionCurrent()) {
        return PaymentOutcome.authenticationRequired;
      }

      return results
              .where((result) => result.intentId == matching.intentId)
              .firstOrNull
              ?.outcome ??
          PaymentOutcome.pending;
    } finally {
      state = false;
    }
  }

  Future<PaymentOutcome> submit({
    required String stokvelId,
    required String cycleId,
    required String memberId,
    required String amount,
  }) async {
    if (state) {
      return PaymentOutcome.pending;
    }

    final user = ref.read(sessionProvider);

    if (user == null || ref.read(sessionOriginProvider).name != 'api') {
      return PaymentOutcome.authenticationRequired;
    }

    final parsed = parseRandsStrict(amount);

    if (parsed is! RandParseSuccess ||
        parsed.amount.value <= 0 ||
        parsed.amount.value > 2147483647 ||
        stokvelId.trim().isEmpty ||
        cycleId.trim().isEmpty ||
        memberId.trim().isEmpty ||
        memberId != user.id) {
      return PaymentOutcome.rejected;
    }

    final accountId = user.id;

    final generation = ref.read(sessionProvider.notifier).sessionGeneration;

    bool isSessionCurrent() {
      return ref.read(sessionProvider)?.id == accountId &&
          ref.read(sessionOriginProvider).name == 'api' &&
          ref.read(sessionProvider.notifier).sessionGeneration == generation;
    }

    state = true;

    try {
      final repository = ref.read(paymentOutboxRepositoryProvider);
      final service = ref.read(paymentOutboxServiceProvider);

      final existing = await repository.pendingForAccount(accountId);

      if (!isSessionCurrent()) {
        return PaymentOutcome.authenticationRequired;
      }

      final matching = existing
          .where(
            (intent) =>
                intent.stokvelId == stokvelId &&
                intent.cycleId == cycleId &&
                intent.memberId == memberId,
          )
          .firstOrNull;

      if (matching != null && matching.amountInCents != parsed.amount.value) {
        return PaymentOutcome.reviewRequired;
      }

      final intent =
          matching ??
          await repository.enqueue(
            accountId: accountId,
            stokvelId: stokvelId,
            cycleId: cycleId,
            memberId: memberId,
            amountInCents: parsed.amount.value,
            isSessionCurrent: isSessionCurrent,
          );

      if (!isSessionCurrent()) {
        return PaymentOutcome.authenticationRequired;
      }

      final results = await service.process(
        accountId: accountId,
        isSessionCurrent: isSessionCurrent,
      );

      if (!isSessionCurrent()) {
        return PaymentOutcome.authenticationRequired;
      }

      return results
              .where((result) => result.intentId == intent.intentId)
              .firstOrNull
              ?.outcome ??
          PaymentOutcome.pending;
    } finally {
      state = false;
    }
  }
}

final contributionControllerProvider =
    NotifierProvider<ContributionController, bool>(ContributionController.new);
