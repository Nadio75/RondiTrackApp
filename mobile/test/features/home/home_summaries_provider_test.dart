import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/features/home/domain/home_summaries_provider.dart';
import 'package:ronditrack/features/stokvel/domain/stokvel_models.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer.test();
  });

  tearDown(() {
    container.dispose();
  });

  test('Lerato sees Bitcube as treasurer with paid status', () async {
    final summaries = await container.read(
      homeSummariesProvider('user-1').future,
    );

    expect(summaries, hasLength(1));
    expect(summaries.single.stokvel.name, 'Bitcube');
    expect(summaries.single.role, StokvelRole.treasurer);
    expect(summaries.single.contributionStatus, ContributionStatus.paid);
  });

  test('Thabo sees Bitcube as member with pending status', () async {
    final summaries = await container.read(
      homeSummariesProvider('user-2').future,
    );

    expect(summaries, hasLength(1));
    expect(summaries.single.role, StokvelRole.member);
    expect(summaries.single.contributionStatus, ContributionStatus.pending);
  });

  test('Naledi sees no stokvel summaries', () async {
    final summaries = await container.read(
      homeSummariesProvider('user-3').future,
    );

    expect(summaries, isEmpty);
  });

  test('Unknown user sees no stokvel summaries', () async {
    final summaries = await container.read(
      homeSummariesProvider('unknown-user').future,
    );

    expect(summaries, isEmpty);
  });
}
