import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../session/presentation/session_provider.dart';
import '../data/fake_payout_repository.dart';
import '../data/fake_stokvel_repository.dart';
import '../domain/payout_models.dart';
import '../domain/payout_repository.dart';

/// Identifies one payout rotation without accepting a user ID.
typedef PayoutKey = ({String stokvelId, String cycleId});

/// Can be overridden in tests or replaced by a real API repository.
final payoutRepositoryProvider = Provider<PayoutRepository>((ref) {
  final stokvelRepository = ref.watch(stokvelRepositoryProvider);

  return FakePayoutRepository(stokvelRepository: stokvelRepository);
});

class PayoutRotationNotifier extends AsyncNotifier<PayoutRotation?> {
  PayoutRotationNotifier(this.key);

  final PayoutKey key;

  @override
  Future<PayoutRotation?> build() async {
    final user = ref.watch(sessionProvider);

    // Never request protected payout data without a signed-in user.
    if (user == null) {
      return null;
    }

    final repository = ref.watch(payoutRepositoryProvider);

    // Matches the asynchronous loading pattern of existing screens.
    await Future<void>.delayed(const Duration(milliseconds: 400));

    return repository.getRotation(
      userId: user.id,
      stokvelId: key.stokvelId,
      cycleId: key.cycleId,
    );
  }
}

final payoutRotationProvider = AsyncNotifierProvider.autoDispose
    .family<PayoutRotationNotifier, PayoutRotation?, PayoutKey>(
      PayoutRotationNotifier.new,
    );
