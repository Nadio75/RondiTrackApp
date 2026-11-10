import 'stokvel_models.dart';

class StokvelDetails {
  const StokvelDetails({
    required this.stokvel,
    required this.membership,
    required this.visibleContributions,
    required this.visiblePaidTotalCents,
  });

  final Stokvel stokvel;
  final Membership membership;
  final List<Contribution> visibleContributions;
  final int visiblePaidTotalCents;
}

abstract class StokvelRepository {
  List<Stokvel> getStokvelsForUser(String userId);

  StokvelDetails? getDetails({
    required String userId,
    required String stokvelId,
  });
}
