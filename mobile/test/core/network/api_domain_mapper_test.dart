import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/core/network/api_domain_mapper.dart';
import 'package:ronditrack/core/network/generated/models/stokvel_response.dart';
import 'package:ronditrack/core/network/generated/models/payout_rotation_entry_response.dart';
import 'package:ronditrack/core/network/generated/models/payout_rotation_response.dart';
import 'package:ronditrack/features/stokvel/domain/stokvel_models.dart';
import 'package:ronditrack/features/stokvel/domain/payout_models.dart';

void main() {
  test('maps stokvel rand amount into integer cents', () {
    final response = StokvelResponse(
      id: 'stokvel-1',
      name: 'Savings Group',
      contributionAmount: 500.25,
      memberCount: 3,
    );

    final result = mapApiStokvel(response);

    expect(result.id, 'stokvel-1');
    expect(result.monthlyContributionCents.value, 50025);
  });

  test('maps known and unknown roles', () {
    expect(mapApiRole('Member'), StokvelRole.member);
    expect(mapApiRole('Treasurer'), StokvelRole.treasurer);
    expect(mapApiRole('unexpected'), StokvelRole.unknown);
  });

  test('maps backend cycle statuses', () {
    expect(mapApiCycleStatus('Open'), CycleStatus.active);
    expect(mapApiCycleStatus('PaidOut'), CycleStatus.closed);
    expect(mapApiCycleStatus('unexpected'), CycleStatus.unknown);
  });

  test('preserves unknown payout statuses', () {
    expect(mapApiPayoutStatus('future-value'), PayoutStatus.unknown);
  });

  test('maps payout cents without multiplying by 100', () {
    final entry = PayoutRotationEntryResponse(
      memberId: 'user-1',
      memberName: 'Lerato',
      position: '2',
      amountCents: '50025',
      scheduledDate: DateTime.utc(2026, 11, 17),
      status: 'next',
      isNext: true,
    );

    final result = mapApiPayoutEntry(entry);

    expect(result.position, 2);
    expect(result.amountCents.value, 50025);
    expect(result.status, PayoutStatus.next);
    expect(result.scheduledDate!.year, 2026);
    expect(result.scheduledDate!.month, 11);
    expect(result.scheduledDate!.day, 17);
  });

  test('maps a complete payout rotation', () {
    final response = PayoutRotationResponse(
      stokvelId: 'stokvel-1',
      cycleId: 'cycle-1',
      entries: [
        PayoutRotationEntryResponse(
          memberId: 'user-1',
          memberName: 'Lerato',
          position: 1,
          amountCents: 10000,
          scheduledDate: null,
          status: 'paid',
          isNext: false,
        ),
      ],
    );

    final result = mapApiPayoutRotation(response);

    expect(result.entries, hasLength(1));
    expect(result.entries.first.amountCents.value, 10000);
    expect(result.entries.first.scheduledDate, isNull);
  });
}
