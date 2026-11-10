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

    expect(summaries, hasLength(2));

    final bitcube = summaries.firstWhere(
      (summary) => summary.stokvel.id == 'bitcube-001',
    );

    final teachers = summaries.firstWhere(
      (summary) => summary.stokvel.id == 'soweto-teachers-001',
    );

    expect(bitcube.stokvel.name, 'Bitcube');
    expect(bitcube.role, StokvelRole.treasurer);
    expect(bitcube.contributionStatus, ContributionStatus.paid);

    expect(teachers.stokvel.name, 'Soweto Teachers');
    expect(teachers.role, StokvelRole.member);
    expect(teachers.contributionStatus, ContributionStatus.pending);
  });

  test('Thabo sees Bitcube as member with pending status', () async {
    final summaries = await container.read(
      homeSummariesProvider('user-2').future,
    );

    expect(summaries, hasLength(2));

    final bitcube = summaries.firstWhere(
      (summary) => summary.stokvel.id == 'bitcube-001',
    );

    final teachers = summaries.firstWhere(
      (summary) => summary.stokvel.id == 'soweto-teachers-001',
    );

    expect(bitcube.role, StokvelRole.member);
    expect(bitcube.contributionStatus, ContributionStatus.pending);

    expect(teachers.role, StokvelRole.member);
    expect(teachers.contributionStatus, ContributionStatus.paid);
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
