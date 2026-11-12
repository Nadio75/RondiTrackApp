import 'payout_models.dart';

abstract class PayoutRepository {
  PayoutRotation? getRotation({
    required String userId,
    required String stokvelId,
    required String cycleId,
  });
}
