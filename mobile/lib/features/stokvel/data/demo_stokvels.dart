import '../domain/stokvel_models.dart';

final demoStokvels = [
  const Stokvel(
    id: 'bitcube-001',
    name: 'Bitcube',
    description: 'Bitcube monthly savings stokvel',
    monthlyContributionCents: 50000,
  ),
];

final demoMemberships = <String, List<Membership>>{
  'user-1': [
    const Membership(stokvelId: 'bitcube-001', role: StokvelRole.treasurer),
  ],
  'user-2': [
    const Membership(stokvelId: 'bitcube-001', role: StokvelRole.member),
  ],
  'user-3': [],
};

final demoContributions = [
  const Contribution(
    id: 'contribution-001',
    stokvelId: 'bitcube-001',
    memberId: 'user-1',
    amountCents: 50000,
    status: ContributionStatus.paid,
  ),
  const Contribution(
    id: 'contribution-002',
    stokvelId: 'bitcube-001',
    memberId: 'user-2',
    amountCents: 50000,
    status: ContributionStatus.pending,
  ),
];
