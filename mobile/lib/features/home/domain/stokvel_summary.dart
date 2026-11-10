import '../../stokvel/domain/stokvel_models.dart';

class StokvelSummary {
  const StokvelSummary({
    required this.stokvel,
    required this.role,
    required this.contributionStatus,
  });

  final Stokvel stokvel;
  final StokvelRole role;
  final ContributionStatus? contributionStatus;
}
