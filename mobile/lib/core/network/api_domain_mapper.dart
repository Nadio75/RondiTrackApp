import '../../features/stokvel/domain/stokvel_models.dart';
import '../../features/stokvel/domain/payout_models.dart';
import 'api_number_mapper.dart';
import 'generated/models/stokvel_response.dart';
import 'generated/models/payout_rotation_response.dart';
import 'generated/models/payout_rotation_entry_response.dart';

Stokvel mapApiStokvel(StokvelResponse response) {
  return Stokvel(
    id: response.id,
    name: response.name,
    description: '',
    monthlyContributionCents: parseApiRands(response.contributionAmount),
  );
}

StokvelRole mapApiRole(String value) {
  switch (value) {
    case 'member':
    case 'Member':
      return StokvelRole.member;
    case 'treasurer':
    case 'Treasurer':
      return StokvelRole.treasurer;
    case 'chairperson':
    case 'Chairperson':
      return StokvelRole.chairperson;
    default:
      return StokvelRole.unknown;
  }
}

CycleStatus mapApiCycleStatus(String value) {
  switch (value) {
    case 'Open':
    case 'active':
      return CycleStatus.active;
    case 'Closed':
    case 'PaidOut':
    case 'closed':
      return CycleStatus.closed;
    case 'upcoming':
      return CycleStatus.upcoming;
    default:
      return CycleStatus.unknown;
  }
}

PayoutStatus mapApiPayoutStatus(String value) {
  switch (value) {
    case 'paid':
      return PayoutStatus.paid;
    case 'next':
      return PayoutStatus.next;
    case 'upcoming':
      return PayoutStatus.upcoming;
    default:
      return PayoutStatus.unknown;
  }
}

/// Retains the calendar date without applying UTC/local conversion.
DateTime? mapApiDateOnly(DateTime? date) {
  if (date == null) return null;
  return DateTime(date.year, date.month, date.day);
}

PayoutRotationEntry mapApiPayoutEntry(PayoutRotationEntryResponse response) {
  return PayoutRotationEntry(
    memberId: response.memberId,
    memberName: response.memberName,
    position: parseApiInteger(response.position),
    amountCents: parseApiCents(response.amountCents),
    scheduledDate: mapApiDateOnly(response.scheduledDate),
    status: mapApiPayoutStatus(response.status),
    isNext: response.isNext,
  );
}

PayoutRotation mapApiPayoutRotation(PayoutRotationResponse response) {
  return PayoutRotation(
    stokvelId: response.stokvelId,
    cycleId: response.cycleId,
    entries: response.entries.map(mapApiPayoutEntry).toList(),
  );
}
