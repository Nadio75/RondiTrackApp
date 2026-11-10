import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/features/stokvel/domain/stokvel_contract_mapping.dart';
import 'package:ronditrack/features/stokvel/domain/stokvel_models.dart';

void main() {
  test('known and unknown role values', () {
    expect(roleFromWire('TREASURER'), StokvelRole.treasurer);
    expect(roleFromWire('member'), StokvelRole.member);
    expect(roleFromWire('chairperson'), StokvelRole.chairperson);
    expect(roleFromWire('unexpected'), StokvelRole.unknown);
    expect(roleFromWire(null), StokvelRole.unknown);
  });
  test('known and unknown cycle values', () {
    expect(cycleFromWire('active'), CycleStatus.active);
    expect(cycleFromWire('upcoming'), CycleStatus.upcoming);
    expect(cycleFromWire('closed'), CycleStatus.closed);
    expect(cycleFromWire('unexpected'), CycleStatus.unknown);
  });
  test('known and unknown contribution values', () {
    expect(contributionFromWire('paid'), ContributionStatus.paid);
    expect(contributionFromWire('pending'), ContributionStatus.pending);
    expect(contributionFromWire('overdue'), ContributionStatus.overdue);
    expect(contributionFromWire(null), ContributionStatus.unknown);
  });
}
