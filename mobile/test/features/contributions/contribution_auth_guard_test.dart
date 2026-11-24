import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ronditrack/core/offline/payment_outbox_service.dart';
import 'package:ronditrack/features/contributions/domain/contribution_controller.dart';
import 'package:ronditrack/features/session/presentation/session_origin_provider.dart';

void main() {
  test('controller starts without an active submission', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(contributionControllerProvider), isFalse);
  });

  test('unauthenticated contribution requires authentication', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final outcome = await container
        .read(contributionControllerProvider.notifier)
        .submit(
          stokvelId: 'stokvel-1',
          cycleId: 'cycle-1',
          memberId: 'member-1',
          amount: '100.00',
        );

    expect(outcome, PaymentOutcome.authenticationRequired);
    expect(container.read(contributionControllerProvider), isFalse);
  });

  test('API origin alone cannot authorize a contribution', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(sessionOriginProvider.notifier).markApi();

    final outcome = await container
        .read(contributionControllerProvider.notifier)
        .submit(
          stokvelId: 'stokvel-1',
          cycleId: 'cycle-1',
          memberId: 'member-1',
          amount: '100.00',
        );

    expect(outcome, PaymentOutcome.authenticationRequired);
    expect(container.read(contributionControllerProvider), isFalse);
  });
}
