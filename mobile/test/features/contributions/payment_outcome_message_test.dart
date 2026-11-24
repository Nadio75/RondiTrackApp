import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/core/offline/payment_outbox_service.dart';
import 'package:ronditrack/features/contributions/presentation/payment_outcome_message.dart';
import 'package:ronditrack/l10n/generated/app_localizations_en.dart';
import 'package:ronditrack/l10n/generated/app_localizations_nso.dart';

void main() {
  final english = AppLocalizationsEn();
  final sepedi = AppLocalizationsNso();

  for (final outcome in PaymentOutcome.values) {
    test('${outcome.name} has localized feedback', () {
      final englishMessage = paymentOutcomeMessage(english, outcome);
      final sepediMessage = paymentOutcomeMessage(sepedi, outcome);

      expect(englishMessage.trim(), isNotEmpty);
      expect(sepediMessage.trim(), isNotEmpty);
      expect(sepediMessage, isNot(englishMessage));
    });
  }

  test('successful contribution uses correct English feedback', () {
    expect(
      paymentOutcomeMessage(english, PaymentOutcome.recorded),
      'Contribution recorded',
    );
  });

  test('successful contribution uses correct Sepedi feedback', () {
    expect(
      paymentOutcomeMessage(sepedi, PaymentOutcome.recorded),
      'Moneelo o rekhotilwe',
    );
  });

  test('pending contribution is not presented as recorded', () {
    for (final language in [english, sepedi]) {
      expect(
        paymentOutcomeMessage(language, PaymentOutcome.pending),
        isNot(paymentOutcomeMessage(language, PaymentOutcome.recorded)),
      );
    }
  });

  test('closed cycle and already paid have distinct messages', () {
    for (final language in [english, sepedi]) {
      expect(
        paymentOutcomeMessage(language, PaymentOutcome.cycleClosed),
        isNot(paymentOutcomeMessage(language, PaymentOutcome.alreadyPaid)),
      );
    }
  });
}
