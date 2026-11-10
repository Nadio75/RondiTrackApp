import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/features/home/domain/home_summaries_provider.dart';
import 'package:ronditrack/features/stokvel/data/fake_stokvel_repository.dart';
import 'package:ronditrack/features/stokvel/domain/stokvel_models.dart';
import 'package:ronditrack/features/stokvel/domain/stokvel_repository.dart';

class FailingStokvelRepository implements StokvelRepository {
  @override
  List<Stokvel> getStokvelsForUser(String userId) {
    throw Exception('Simulated network failure');
  }

  @override
  StokvelDetails? getDetails({
    required String userId,
    required String stokvelId,
  }) {
    throw Exception('Simulated network failure');
  }
}

class RecoveringStokvelRepository implements StokvelRepository {
  bool shouldFail = true;

  final StokvelRepository delegate = FakeStokvelRepository();

  @override
  List<Stokvel> getStokvelsForUser(String userId) {
    if (shouldFail) {
      throw Exception('Temporary failure');
    }
    return delegate.getStokvelsForUser(userId);
  }

  @override
  StokvelDetails? getDetails({
    required String userId,
    required String stokvelId,
  }) {
    if (shouldFail) {
      throw Exception('Temporary failure');
    }
    return delegate.getDetails(userId: userId, stokvelId: stokvelId);
  }
}

void main() {
  test('Dashboard provider exposes repository failures', () async {
    final container = ProviderContainer.test(
      overrides: [
        stokvelRepositoryProvider.overrideWithValue(FailingStokvelRepository()),
      ],
    );

    await expectLater(
      container.read(homeSummariesProvider('user-1').future),
      throwsException,
    );
  });

  test('Dashboard provider recovers after invalidation', () async {
    final repository = RecoveringStokvelRepository();

    final container = ProviderContainer.test(
      overrides: [stokvelRepositoryProvider.overrideWithValue(repository)],
    );

    await expectLater(
      container.read(homeSummariesProvider('user-1').future),
      throwsException,
    );

    repository.shouldFail = false;

    container.invalidate(homeSummariesProvider('user-1'));

    final summaries = await container.read(
      homeSummariesProvider('user-1').future,
    );

    expect(summaries, hasLength(2));
    expect(
      summaries.map((summary) => summary.stokvel.name),
      containsAll(['Bitcube', 'Soweto Teachers']),
    );
  });
}
