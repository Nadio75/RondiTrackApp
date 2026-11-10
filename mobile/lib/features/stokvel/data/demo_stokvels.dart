import '../../../core/money/cents.dart';
import '../domain/stokvel_models.dart';

final demoStokvels = [
  const Stokvel(
    id: 'bitcube-001',
    name: 'Bitcube',
    description: 'Bitcube monthly savings stokvel',
    monthlyContributionCents: Cents(50000),
  ),
  const Stokvel(
    id: 'soweto-teachers-001',
    name: 'Soweto Teachers',
    description: 'Soweto Teachers monthly savings stokvel',
    monthlyContributionCents: Cents(75000),
  ),
];

final demoMemberships = <String, List<Membership>>{
  'user-1': [
    const Membership(stokvelId: 'bitcube-001', role: StokvelRole.treasurer),
    const Membership(
      stokvelId: 'soweto-teachers-001',
      role: StokvelRole.member,
    ),
  ],
  'user-2': [
    const Membership(stokvelId: 'bitcube-001', role: StokvelRole.member),
    const Membership(
      stokvelId: 'soweto-teachers-001',
      role: StokvelRole.member,
    ),
  ],
  'user-3': [],
};

final demoContributions = [
  const Contribution(
    id: 'contribution-001',
    stokvelId: 'bitcube-001',
    memberId: 'user-1',
    amountCents: Cents(50000),
    status: ContributionStatus.paid,
  ),
  const Contribution(
    id: 'contribution-002',
    stokvelId: 'bitcube-001',
    memberId: 'user-2',
    amountCents: Cents(50000),
    status: ContributionStatus.pending,
  ),
  const Contribution(
    id: 'contribution-003',
    stokvelId: 'soweto-teachers-001',
    memberId: 'user-1',
    amountCents: Cents(75000),
    status: ContributionStatus.pending,
  ),
  const Contribution(
    id: 'contribution-004',
    stokvelId: 'soweto-teachers-001',
    memberId: 'user-2',
    amountCents: Cents(75000),
    status: ContributionStatus.paid,
  ),
];
