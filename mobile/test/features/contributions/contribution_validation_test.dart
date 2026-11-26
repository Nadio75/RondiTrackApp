import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/core/offline/payment_outbox_service.dart';
import 'package:ronditrack/features/contributions/domain/contribution_controller.dart';
import 'package:ronditrack/features/session/data/demo_users.dart';
import 'package:ronditrack/features/session/presentation/session_provider.dart';
import 'package:ronditrack/features/session/presentation/session_origin_provider.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();

    final user = demoUsers.first;

    expect(
      container.read(sessionProvider.notifier).login(user.email, demoPassword),
      isTrue,
    );
  });

  tearDown(() {
    container.dispose();
  });

  Future<PaymentOutcome> submit({
    String amount = '100.00',
    String stokvelId = 'stokvel-1',
    String cycleId = 'cycle-1',
    String memberId = 'user-1',
  }) {
    return container
        .read(contributionControllerProvider.notifier)
        .submit(
          stokvelId: stokvelId,
          cycleId: cycleId,
          memberId: memberId,
          amount: amount,
        );
  }

  test('demo users cannot submit real contributions', () async {
    expect(await submit(), PaymentOutcome.authenticationRequired);

    expect(container.read(contributionControllerProvider), isFalse);
  });

  for (final amount in [
    '',
    ' ',
    'abc',
    '0',
    '0.00',
    '-100',
    '12.345',
    'NaN',
    'Infinity',
    '1e3',
  ]) {
    test('rejects invalid amount "$amount"', () async {
      container.read(sessionOriginProvider.notifier).markApi();

      expect(await submit(amount: amount), PaymentOutcome.rejected);

      expect(container.read(contributionControllerProvider), isFalse);
    });
  }

  test('rejects missing stokvel ID', () async {
    container.read(sessionOriginProvider.notifier).markApi();

    expect(await submit(stokvelId: ''), PaymentOutcome.rejected);
  });

  test('rejects missing cycle ID', () async {
    container.read(sessionOriginProvider.notifier).markApi();

    expect(await submit(cycleId: ''), PaymentOutcome.rejected);
  });

  test('rejects missing member ID', () async {
    container.read(sessionOriginProvider.notifier).markApi();

    expect(await submit(memberId: ''), PaymentOutcome.rejected);
  });

  test('logout prevents subsequent contribution', () async {
    container.read(sessionOriginProvider.notifier).markApi();

    container.read(sessionProvider.notifier).logout();

    expect(await submit(), PaymentOutcome.authenticationRequired);
  });
}
