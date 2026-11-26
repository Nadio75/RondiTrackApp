import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ronditrack/core/money/cents.dart';
import 'package:ronditrack/features/home/domain/home_summaries_provider.dart';
import 'package:ronditrack/features/stokvel/data/fake_stokvel_repository.dart';
import 'package:ronditrack/features/stokvel/domain/stokvel_models.dart';
import 'package:ronditrack/features/stokvel/domain/stokvel_repository.dart';

class MockStokvelRepository extends Mock implements StokvelRepository {}

void main() {
  const userId = 'user-1';

  const stokvel = Stokvel(
    id: 'test-stokvel',
    name: 'Synthetic Savings Club',
    description: 'Automated test data',
    monthlyContributionCents: Cents(50000),
  );

  const membership = Membership(
    stokvelId: 'test-stokvel',
    role: StokvelRole.treasurer,
  );

  const ownContribution = Contribution(
    id: 'contribution-1',
    stokvelId: 'test-stokvel',
    memberId: userId,
    amountCents: Cents(50000),
    status: ContributionStatus.pending,
  );

  const otherContribution = Contribution(
    id: 'contribution-2',
    stokvelId: 'test-stokvel',
    memberId: 'user-2',
    amountCents: Cents(50000),
    status: ContributionStatus.paid,
  );

  late MockStokvelRepository repository;
  late ProviderContainer container;

  final provider = homeSummariesProvider(userId);

  setUp(() {
    repository = MockStokvelRepository();

    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [stokvelRepositoryProvider.overrideWithValue(repository)],
    );

    addTearDown(container.dispose);

    when(() => repository.getStokvelsForUser(userId)).thenReturn([stokvel]);
  });

  void stubDetails(List<Contribution> contributions) {
    when(() => repository.getDetails(userId: userId, stokvelId: stokvel.id))
        .thenReturn(
          StokvelDetails(
            stokvel: stokvel,
            membership: membership,
            visibleContributions: contributions,
            visiblePaidTotalCents: const Cents(50000),
          ),
        );
  }

  void keepAlive() {
    final subscription = container.listen(provider, (_, _) {});

    addTearDown(subscription.close);
  }

  test('populated Home preserves role and money in cents', () async {
    stubDetails([ownContribution]);
    keepAlive();

    final result = await container.read(provider.future);

    expect(result, hasLength(1));
    expect(result.single.stokvel.name, stokvel.name);
    expect(result.single.role, StokvelRole.treasurer);
    expect(result.single.stokvel.monthlyContributionCents.value, 50000);

    verify(() => repository.getStokvelsForUser(userId)).called(1);

    verify(() => repository.getDetails(userId: userId, stokvelId: stokvel.id))
        .called(1);

    verifyNoMoreInteractions(repository);
  });

  test('Home uses own contribution status not another member status', () async {
    stubDetails([otherContribution, ownContribution]);

    keepAlive();

    final result = await container.read(provider.future);

    expect(result.single.contributionStatus, ContributionStatus.pending);
  });

  test('inaccessible stokvel details are excluded from Home', () async {
    when(() => repository.getDetails(userId: userId, stokvelId: stokvel.id))
        .thenReturn(null);

    keepAlive();

    expect(await container.read(provider.future), isEmpty);

    verify(() => repository.getDetails(userId: userId, stokvelId: stokvel.id))
        .called(1);
  });

  test(
    'missing own contribution does not expose another member status',
    () async {
      stubDetails([otherContribution]);

      keepAlive();

      final result = await container.read(provider.future);

      expect(result, hasLength(1));
      expect(result.single.contributionStatus, isNull);
    },
  );
}
