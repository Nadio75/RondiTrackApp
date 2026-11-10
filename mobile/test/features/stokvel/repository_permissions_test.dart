import 'package:ronditrack/core/money/cents.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/features/stokvel/data/fake_stokvel_repository.dart';

void main() {
  final repository = FakeStokvelRepository();

  test('Lerato can view both Bitcube contributions', () {
    final details = repository.getDetails(
      userId: 'user-1',
      stokvelId: 'bitcube-001',
    );

    expect(details, isNotNull);
    expect(details!.visibleContributions.length, 2);
    expect(details.visiblePaidTotalCents, const Cents(50000));
  });

  test('Thabo can only view his own contribution', () {
    final details = repository.getDetails(
      userId: 'user-2',
      stokvelId: 'bitcube-001',
    );

    expect(details, isNotNull);
    expect(details!.visibleContributions.length, 1);
    expect(details.visibleContributions.single.memberId, 'user-2');
    expect(details.visiblePaidTotalCents, const Cents(0));
  });

  test('Naledi cannot access Bitcube', () {
    final details = repository.getDetails(
      userId: 'user-3',
      stokvelId: 'bitcube-001',
    );

    expect(details, isNull);
    expect(repository.getStokvelsForUser('user-3'), isEmpty);
  });

  test('Unknown stokvel is not accessible', () {
    final details = repository.getDetails(
      userId: 'user-1',
      stokvelId: 'unknown-stokvel',
    );

    expect(details, isNull);
  });
}
