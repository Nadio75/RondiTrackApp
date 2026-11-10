import 'stokvel_models.dart';

enum StokvelAction {
  pay,
  uploadProof,
  confirmContributions,
  closeCycle,
  recordPayout,
}

/// The membership role is scoped to the requested stokvel, never the user.
/// No default arm: every combination must be considered when enums change.
Set<StokvelAction> allowedStokvelActions({
  required StokvelRole role,
  required CycleStatus cycle,
  required ContributionStatus ownContribution,
}) => switch ((role, cycle, ownContribution)) {
  (StokvelRole.member, CycleStatus.active, ContributionStatus.pending) => {
    StokvelAction.pay,
    StokvelAction.uploadProof,
  },
  (StokvelRole.member, CycleStatus.active, ContributionStatus.overdue) => {
    StokvelAction.pay,
    StokvelAction.uploadProof,
  },
  (StokvelRole.member, CycleStatus.active, ContributionStatus.paid) =>
    <StokvelAction>{},
  (StokvelRole.member, CycleStatus.active, ContributionStatus.unknown) =>
    <StokvelAction>{},
  (StokvelRole.treasurer, CycleStatus.active, ContributionStatus.pending) => {
    StokvelAction.pay,
    StokvelAction.uploadProof,
    StokvelAction.confirmContributions,
  },
  (StokvelRole.treasurer, CycleStatus.active, ContributionStatus.overdue) => {
    StokvelAction.pay,
    StokvelAction.uploadProof,
    StokvelAction.confirmContributions,
  },
  (StokvelRole.treasurer, CycleStatus.active, ContributionStatus.paid) => {
    StokvelAction.confirmContributions,
  },
  (StokvelRole.treasurer, CycleStatus.active, ContributionStatus.unknown) => {
    StokvelAction.confirmContributions,
  },
  (StokvelRole.chairperson, CycleStatus.active, ContributionStatus.pending) => {
    StokvelAction.pay,
    StokvelAction.uploadProof,
    StokvelAction.closeCycle,
    StokvelAction.recordPayout,
  },
  (StokvelRole.chairperson, CycleStatus.active, ContributionStatus.overdue) => {
    StokvelAction.pay,
    StokvelAction.uploadProof,
    StokvelAction.closeCycle,
    StokvelAction.recordPayout,
  },
  (StokvelRole.chairperson, CycleStatus.active, ContributionStatus.paid) => {
    StokvelAction.closeCycle,
    StokvelAction.recordPayout,
  },
  (StokvelRole.chairperson, CycleStatus.active, ContributionStatus.unknown) => {
    StokvelAction.closeCycle,
    StokvelAction.recordPayout,
  },
  (StokvelRole.unknown, CycleStatus.active, ContributionStatus.pending) =>
    <StokvelAction>{},
  (StokvelRole.unknown, CycleStatus.active, ContributionStatus.overdue) =>
    <StokvelAction>{},
  (StokvelRole.unknown, CycleStatus.active, ContributionStatus.paid) =>
    <StokvelAction>{},
  (StokvelRole.unknown, CycleStatus.active, ContributionStatus.unknown) =>
    <StokvelAction>{},
  (StokvelRole.member, CycleStatus.upcoming, ContributionStatus.pending) =>
    <StokvelAction>{},
  (StokvelRole.member, CycleStatus.upcoming, ContributionStatus.overdue) =>
    <StokvelAction>{},
  (StokvelRole.member, CycleStatus.upcoming, ContributionStatus.paid) =>
    <StokvelAction>{},
  (StokvelRole.member, CycleStatus.upcoming, ContributionStatus.unknown) =>
    <StokvelAction>{},
  (StokvelRole.treasurer, CycleStatus.upcoming, ContributionStatus.pending) =>
    <StokvelAction>{},
  (StokvelRole.treasurer, CycleStatus.upcoming, ContributionStatus.overdue) =>
    <StokvelAction>{},
  (StokvelRole.treasurer, CycleStatus.upcoming, ContributionStatus.paid) =>
    <StokvelAction>{},
  (StokvelRole.treasurer, CycleStatus.upcoming, ContributionStatus.unknown) =>
    <StokvelAction>{},
  (StokvelRole.chairperson, CycleStatus.upcoming, ContributionStatus.pending) =>
    <StokvelAction>{},
  (StokvelRole.chairperson, CycleStatus.upcoming, ContributionStatus.overdue) =>
    <StokvelAction>{},
  (StokvelRole.chairperson, CycleStatus.upcoming, ContributionStatus.paid) =>
    <StokvelAction>{},
  (StokvelRole.chairperson, CycleStatus.upcoming, ContributionStatus.unknown) =>
    <StokvelAction>{},
  (StokvelRole.unknown, CycleStatus.upcoming, ContributionStatus.pending) =>
    <StokvelAction>{},
  (StokvelRole.unknown, CycleStatus.upcoming, ContributionStatus.overdue) =>
    <StokvelAction>{},
  (StokvelRole.unknown, CycleStatus.upcoming, ContributionStatus.paid) =>
    <StokvelAction>{},
  (StokvelRole.unknown, CycleStatus.upcoming, ContributionStatus.unknown) =>
    <StokvelAction>{},
  (StokvelRole.member, CycleStatus.closed, ContributionStatus.pending) =>
    <StokvelAction>{},
  (StokvelRole.member, CycleStatus.closed, ContributionStatus.overdue) =>
    <StokvelAction>{},
  (StokvelRole.member, CycleStatus.closed, ContributionStatus.paid) =>
    <StokvelAction>{},
  (StokvelRole.member, CycleStatus.closed, ContributionStatus.unknown) =>
    <StokvelAction>{},
  (StokvelRole.treasurer, CycleStatus.closed, ContributionStatus.pending) =>
    <StokvelAction>{},
  (StokvelRole.treasurer, CycleStatus.closed, ContributionStatus.overdue) =>
    <StokvelAction>{},
  (StokvelRole.treasurer, CycleStatus.closed, ContributionStatus.paid) =>
    <StokvelAction>{},
  (StokvelRole.treasurer, CycleStatus.closed, ContributionStatus.unknown) =>
    <StokvelAction>{},
  (StokvelRole.chairperson, CycleStatus.closed, ContributionStatus.pending) =>
    <StokvelAction>{},
  (StokvelRole.chairperson, CycleStatus.closed, ContributionStatus.overdue) =>
    <StokvelAction>{},
  (StokvelRole.chairperson, CycleStatus.closed, ContributionStatus.paid) =>
    <StokvelAction>{},
  (StokvelRole.chairperson, CycleStatus.closed, ContributionStatus.unknown) =>
    <StokvelAction>{},
  (StokvelRole.unknown, CycleStatus.closed, ContributionStatus.pending) =>
    <StokvelAction>{},
  (StokvelRole.unknown, CycleStatus.closed, ContributionStatus.overdue) =>
    <StokvelAction>{},
  (StokvelRole.unknown, CycleStatus.closed, ContributionStatus.paid) =>
    <StokvelAction>{},
  (StokvelRole.unknown, CycleStatus.closed, ContributionStatus.unknown) =>
    <StokvelAction>{},
  (StokvelRole.member, CycleStatus.unknown, ContributionStatus.pending) =>
    <StokvelAction>{},
  (StokvelRole.member, CycleStatus.unknown, ContributionStatus.overdue) =>
    <StokvelAction>{},
  (StokvelRole.member, CycleStatus.unknown, ContributionStatus.paid) =>
    <StokvelAction>{},
  (StokvelRole.member, CycleStatus.unknown, ContributionStatus.unknown) =>
    <StokvelAction>{},
  (StokvelRole.treasurer, CycleStatus.unknown, ContributionStatus.pending) =>
    <StokvelAction>{},
  (StokvelRole.treasurer, CycleStatus.unknown, ContributionStatus.overdue) =>
    <StokvelAction>{},
  (StokvelRole.treasurer, CycleStatus.unknown, ContributionStatus.paid) =>
    <StokvelAction>{},
  (StokvelRole.treasurer, CycleStatus.unknown, ContributionStatus.unknown) =>
    <StokvelAction>{},
  (StokvelRole.chairperson, CycleStatus.unknown, ContributionStatus.pending) =>
    <StokvelAction>{},
  (StokvelRole.chairperson, CycleStatus.unknown, ContributionStatus.overdue) =>
    <StokvelAction>{},
  (StokvelRole.chairperson, CycleStatus.unknown, ContributionStatus.paid) =>
    <StokvelAction>{},
  (StokvelRole.chairperson, CycleStatus.unknown, ContributionStatus.unknown) =>
    <StokvelAction>{},
  (StokvelRole.unknown, CycleStatus.unknown, ContributionStatus.pending) =>
    <StokvelAction>{},
  (StokvelRole.unknown, CycleStatus.unknown, ContributionStatus.overdue) =>
    <StokvelAction>{},
  (StokvelRole.unknown, CycleStatus.unknown, ContributionStatus.paid) =>
    <StokvelAction>{},
  (StokvelRole.unknown, CycleStatus.unknown, ContributionStatus.unknown) =>
    <StokvelAction>{},
};
