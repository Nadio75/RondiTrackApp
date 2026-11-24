import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ronditrack/core/money/cents.dart';
import 'package:ronditrack/features/session/presentation/session_provider.dart';
import 'package:ronditrack/features/stokvel/domain/payout_models.dart';
import 'package:ronditrack/features/stokvel/domain/payout_repository.dart';
import 'package:ronditrack/features/stokvel/presentation/payout_provider.dart';

class MockPayoutRepository extends Mock implements PayoutRepository {}

void main() {
  const key = (stokvelId: 'bitcube-001', cycleId: 'cycle-001');

  const rotation = PayoutRotation(
    stokvelId: 'bitcube-001',
    cycleId: 'cycle-001',
    entries: [
      PayoutRotationEntry(
        memberId: 'user-2',
        memberName: 'Synthetic Member',
        position: 1,
        amountCents: Cents(50000),
        scheduledDate: null,
        status: PayoutStatus.next,
        isNext: true,
      ),
    ],
  );

  late MockPayoutRepository repository;
  late ProviderContainer container;

  final provider = payoutRotationProvider(key);

  setUp(() {
    repository = MockPayoutRepository();

    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [payoutRepositoryProvider.overrideWithValue(repository)],
    );

    addTearDown(container.dispose);
  });

  void signIn() {
    expect(
      container
          .read(sessionProvider.notifier)
          .login('lerato@example.com', 'testpassword123'),
      isTrue,
    );
  }

  PayoutRotation? requestRotation() {
    return repository.getRotation(
      userId: 'user-1',
      stokvelId: key.stokvelId,
      cycleId: key.cycleId,
    );
  }

  group('PayoutRotationNotifier with Mocktail', () {
    test('signed-out user never calls repository', () async {
      final subscription = container.listen(provider, (_, _) {});

      addTearDown(subscription.close);

      expect(await container.read(provider.future), isNull);

      verifyZeroInteractions(repository);
    });

    test('loading transitions to successful payout data', () async {
      signIn();

      when(requestRotation).thenReturn(rotation);

      final subscription = container.listen(provider, (_, _) {});

      addTearDown(subscription.close);

      expect(container.read(provider).isLoading, isTrue);

      final result = await container.read(provider.future);

      expect(result, same(rotation));
      expect(result!.entries.single.amountCents.value, 50000);

      expect(container.read(provider), isA<AsyncData<PayoutRotation?>>());

      verify(requestRotation).called(1);
      verifyNoMoreInteractions(repository);
    });

    test('repository receives correct user and cycle identifiers', () async {
      signIn();

      when(requestRotation).thenReturn(rotation);

      final subscription = container.listen(provider, (_, _) {});

      addTearDown(subscription.close);

      await container.read(provider.future);

      final captured = verify(
        () => repository.getRotation(
          userId: captureAny(named: 'userId'),
          stokvelId: captureAny(named: 'stokvelId'),
          cycleId: captureAny(named: 'cycleId'),
        ),
      ).captured;

      expect(captured, ['user-1', 'bitcube-001', 'cycle-001']);

      verifyNoMoreInteractions(repository);
    });

    test('null response becomes empty data', () async {
      signIn();

      when(requestRotation).thenReturn(null);

      final subscription = container.listen(provider, (_, _) {});

      addTearDown(subscription.close);

      expect(await container.read(provider.future), isNull);

      expect(container.read(provider), isA<AsyncData<PayoutRotation?>>());

      verify(requestRotation).called(1);
    });

    test('repository failure becomes AsyncError', () async {
      signIn();

      when(requestRotation).thenThrow(StateError('Synthetic payout failure'));

      final subscription = container.listen(provider, (_, _) {});

      addTearDown(subscription.close);

      await expectLater(container.read(provider.future), throwsStateError);

      expect(container.read(provider).hasError, isTrue);

      verify(requestRotation).called(1);
      verifyNoMoreInteractions(repository);
    });

    test('retry after failure returns successful data', () async {
      signIn();

      when(requestRotation).thenThrow(StateError('Temporary failure'));

      final subscription = container.listen(provider, (_, _) {});

      addTearDown(subscription.close);

      await expectLater(container.read(provider.future), throwsStateError);

      when(requestRotation).thenReturn(rotation);

      container.invalidate(provider);

      expect(await container.read(provider.future), same(rotation));

      verify(requestRotation).called(2);
    });

    test('sign-out removes previously loaded payout data', () async {
      signIn();

      when(requestRotation).thenReturn(rotation);

      final subscription = container.listen(provider, (_, _) {});

      addTearDown(subscription.close);

      expect(await container.read(provider.future), same(rotation));

      container.read(sessionProvider.notifier).logout();

      expect(await container.read(provider.future), isNull);

      verify(requestRotation).called(1);
      verifyNoMoreInteractions(repository);
    });
  });
}
