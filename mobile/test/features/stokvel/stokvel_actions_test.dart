import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/features/stokvel/domain/stokvel_actions.dart';
import 'package:ronditrack/features/stokvel/domain/stokvel_models.dart';

void main() {
  test('member can pay but cannot confirm', () {
    final actions = allowedStokvelActions(
      role: StokvelRole.member,
      cycle: CycleStatus.active,
      ownContribution: ContributionStatus.pending,
    );
    expect(actions, contains(StokvelAction.pay));
    expect(actions, isNot(contains(StokvelAction.confirmContributions)));
  });
  test('treasurer can confirm but cannot close', () {
    final actions = allowedStokvelActions(
      role: StokvelRole.treasurer,
      cycle: CycleStatus.active,
      ownContribution: ContributionStatus.paid,
    );
    expect(actions, contains(StokvelAction.confirmContributions));
    expect(actions, isNot(contains(StokvelAction.closeCycle)));
  });
  test('chairperson can close and record payout', () {
    final actions = allowedStokvelActions(
      role: StokvelRole.chairperson,
      cycle: CycleStatus.active,
      ownContribution: ContributionStatus.paid,
    );
    expect(
      actions,
      containsAll([StokvelAction.closeCycle, StokvelAction.recordPayout]),
    );
  });
  test('closed, upcoming, unknown cycle denies actions', () {
    for (final cycle in [
      CycleStatus.closed,
      CycleStatus.upcoming,
      CycleStatus.unknown,
    ]) {
      for (final role in StokvelRole.values) {
        for (final status in ContributionStatus.values) {
          expect(
            allowedStokvelActions(
              role: role,
              cycle: cycle,
              ownContribution: status,
            ),
            isEmpty,
          );
        }
      }
    }
  });
  test('unknown membership role denies all actions', () {
    for (final cycle in CycleStatus.values) {
      for (final status in ContributionStatus.values) {
        expect(
          allowedStokvelActions(
            role: StokvelRole.unknown,
            cycle: cycle,
            ownContribution: status,
          ),
          isEmpty,
        );
      }
    }
  });
}
