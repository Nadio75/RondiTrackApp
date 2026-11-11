import '../../../core/money/cents.dart';
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
  final Cents visiblePaidTotalCents;
}

abstract class StokvelRepository {
  List<Stokvel> getStokvelsForUser(String userId);

  StokvelDetails? getDetails({
    required String userId,
    required String stokvelId,
  });

  Cycle? getActiveCycle({required String userId, required String stokvelId});
  Cycle? getCycle({
    required String userId,
    required String stokvelId,
    required String cycleId,
  });
}
