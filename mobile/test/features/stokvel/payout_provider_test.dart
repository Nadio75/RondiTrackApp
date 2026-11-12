import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ronditrack/core/money/cents.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/features/session/data/demo_users.dart';
import 'package:ronditrack/features/session/presentation/session_provider.dart';
import 'package:ronditrack/features/stokvel/domain/payout_models.dart';
import 'package:ronditrack/features/stokvel/domain/payout_repository.dart';
import 'package:ronditrack/features/stokvel/presentation/payout_provider.dart';
import 'package:ronditrack/features/stokvel/presentation/payout_view_state.dart';

const bitcubeKey = (stokvelId: 'bitcube-001', cycleId: 'cycle-001');

const teachersKey = (stokvelId: 'soweto-teachers-001', cycleId: 'cycle-002');

class FailingPayoutRepository implements PayoutRepository {
  bool shouldFail = true;
  int calls = 0;

  @override
  PayoutRotation? getRotation({
    required String userId,
    required String stokvelId,
    required String cycleId,
  }) {
    calls++;

    if (shouldFail) {
      throw StateError('Simulated payout service failure');
    }

    return const PayoutRotation(
      stokvelId: 'bitcube-001',
      cycleId: 'cycle-001',
      entries: [
        PayoutRotationEntry(
          memberId: 'user-2',
          memberName: 'Thabo',
          position: 1,
          amountCents: Cents(50000),
          scheduledDate: null,
          status: PayoutStatus.next,
          isNext: true,
        ),
      ],
    );
  }
}

void main() {
  test('logged-out user receives no payout data', () async {
    final container = ProviderContainer.test();
    final provider = payoutRotationProvider(bitcubeKey);
    final subscription = container.listen(provider, (_, _) {});
    addTearDown(subscription.close);

    expect(await container.read(provider.future), isNull);
    expect(
      payoutViewStateFromAsync(container.read(provider)),
      isA<PayoutEmpty>(),
    );
  });

  test('signed-in member sees loading and then payout data', () async {
    final container = ProviderContainer.test();
    final session = container.read(sessionProvider.notifier);

    expect(session.login('lerato@example.com', demoPassword), isTrue);

    final provider = payoutRotationProvider(bitcubeKey);
    final subscription = container.listen(provider, (_, _) {});
    addTearDown(subscription.close);

    expect(
      payoutViewStateFromAsync(container.read(provider)),
      isA<PayoutLoading>(),
    );

    final rotation = await container.read(provider.future);

    expect(rotation, isNotNull);
    expect(rotation!.entries, hasLength(2));

    final state = payoutViewStateFromAsync(container.read(provider));

    expect(state, isA<PayoutData>());
    expect((state as PayoutData).rotation.entries.last.isNext, isTrue);
  });

  test('payout rotation preserves backend-defined ordering', () async {
    final container = ProviderContainer.test();
    final session = container.read(sessionProvider.notifier);

    expect(session.login('thabo@example.com', demoPassword), isTrue);

    final provider = payoutRotationProvider(teachersKey);
    final subscription = container.listen(provider, (_, _) {});
    addTearDown(subscription.close);

    final rotation = await container.read(provider.future);

    expect(rotation, isNotNull);
    expect(rotation!.entries.map((entry) => entry.memberId).toList(), [
      'user-2',
      'user-1',
    ]);
    expect(rotation.entries.first.position, 1);
    expect(rotation.entries.first.amountCents.value, 75000);
  });

  test('nonmember receives empty state', () async {
    final container = ProviderContainer.test();
    final session = container.read(sessionProvider.notifier);

    expect(session.login('naledi@example.com', demoPassword), isTrue);

    final provider = payoutRotationProvider(bitcubeKey);
    final subscription = container.listen(provider, (_, _) {});
    addTearDown(subscription.close);

    expect(await container.read(provider.future), isNull);
    expect(
      payoutViewStateFromAsync(container.read(provider)),
      isA<PayoutEmpty>(),
    );
  });

  test('session changes refresh payout access', () async {
    final container = ProviderContainer.test();
    final session = container.read(sessionProvider.notifier);
    final provider = payoutRotationProvider(bitcubeKey);

    final subscription = container.listen(provider, (_, _) {});
    addTearDown(subscription.close);

    expect(session.login('lerato@example.com', demoPassword), isTrue);
    expect(await container.read(provider.future), isNotNull);

    session.logout();
    expect(await container.read(provider.future), isNull);

    expect(session.login('naledi@example.com', demoPassword), isTrue);
    expect(await container.read(provider.future), isNull);

    session.logout();

    expect(session.login('thabo@example.com', demoPassword), isTrue);
    expect(await container.read(provider.future), isNotNull);
  });

  test('repository failure becomes an error view state', () async {
    final repository = FailingPayoutRepository();

    final container = ProviderContainer.test(
      overrides: [payoutRepositoryProvider.overrideWithValue(repository)],
    );

    final session = container.read(sessionProvider.notifier);
    expect(session.login('lerato@example.com', demoPassword), isTrue);

    final provider = payoutRotationProvider(bitcubeKey);
    final subscription = container.listen(provider, (_, _) {});
    addTearDown(subscription.close);

    await expectLater(container.read(provider.future), throwsStateError);

    expect(
      payoutViewStateFromAsync(container.read(provider)),
      isA<PayoutFailure>(),
    );
    expect(repository.calls, 1);
  });

  test('invalidating a failed provider retries successfully', () async {
    final repository = FailingPayoutRepository();

    final container = ProviderContainer.test(
      overrides: [payoutRepositoryProvider.overrideWithValue(repository)],
    );

    final session = container.read(sessionProvider.notifier);
    expect(session.login('lerato@example.com', demoPassword), isTrue);

    final provider = payoutRotationProvider(bitcubeKey);
    final subscription = container.listen(provider, (_, _) {});
    addTearDown(subscription.close);

    await expectLater(container.read(provider.future), throwsStateError);

    repository.shouldFail = false;

    container.invalidate(provider);

    final rotation = await container.read(provider.future);

    expect(rotation, isNotNull);
    expect(rotation!.entries.single.memberName, 'Thabo');
    expect(repository.calls, 2);
    expect(
      payoutViewStateFromAsync(container.read(provider)),
      isA<PayoutData>(),
    );
  });
}
