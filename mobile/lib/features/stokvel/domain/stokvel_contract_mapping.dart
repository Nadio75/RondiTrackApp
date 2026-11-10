import 'stokvel_models.dart';

/// Local draft contract mapping. Confirm spellings with the backend in Week 11.
StokvelRole roleFromWire(String? value) => switch (value?.toLowerCase()) {
  'member' => StokvelRole.member,
  'treasurer' => StokvelRole.treasurer,
  'chairperson' => StokvelRole.chairperson,
  _ => StokvelRole.unknown,
};

CycleStatus cycleFromWire(String? value) => switch (value?.toLowerCase()) {
  'upcoming' => CycleStatus.upcoming,
  'active' => CycleStatus.active,
  'closed' => CycleStatus.closed,
  _ => CycleStatus.unknown,
};

ContributionStatus contributionFromWire(String? value) =>
    switch (value?.toLowerCase()) {
      'pending' => ContributionStatus.pending,
      'paid' => ContributionStatus.paid,
      'overdue' => ContributionStatus.overdue,
      _ => ContributionStatus.unknown,
    };
