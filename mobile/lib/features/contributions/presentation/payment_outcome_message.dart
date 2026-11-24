import '../../../core/offline/payment_outbox_service.dart';
import '../../../l10n/generated/app_localizations.dart';

String paymentOutcomeMessage(AppLocalizations l10n, PaymentOutcome outcome) {
  return switch (outcome) {
    PaymentOutcome.recorded => l10n.contributionRecorded,
    PaymentOutcome.pending => l10n.contributionPending,
    PaymentOutcome.rateLimited => l10n.contributionRateLimited,
    PaymentOutcome.alreadyPaid => l10n.contributionAlreadyPaid,
    PaymentOutcome.cycleClosed => l10n.contributionCycleClosed,
    PaymentOutcome.conflict => l10n.contributionConflict,
    PaymentOutcome.rejected => l10n.contributionRejected,
    PaymentOutcome.authenticationRequired =>
      l10n.contributionAuthenticationRequired,
    PaymentOutcome.expired => l10n.contributionExpired,
    PaymentOutcome.reviewRequired => l10n.contributionReviewRequired,
  };
}
