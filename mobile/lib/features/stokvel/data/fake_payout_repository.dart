import '../../../core/money/cents.dart';
import '../domain/payout_models.dart';
import '../domain/payout_repository.dart';
import '../domain/stokvel_repository.dart';
import 'fake_stokvel_repository.dart';

class FakePayoutRepository implements PayoutRepository {
  FakePayoutRepository({StokvelRepository? stokvelRepository})
    : _stokvelRepository = stokvelRepository ?? FakeStokvelRepository();

  final StokvelRepository _stokvelRepository;

  static const _rotations = <PayoutRotation>[
    PayoutRotation(
      stokvelId: 'bitcube-001',
      cycleId: 'cycle-001',
      entries: [
        PayoutRotationEntry(
          memberId: 'user-1',
          memberName: 'Lerato',
          position: 1,
          amountCents: Cents(50000),
          scheduledDate: null,
          status: PayoutStatus.paid,
          isNext: false,
        ),
        PayoutRotationEntry(
          memberId: 'user-2',
          memberName: 'Thabo',
          position: 2,
          amountCents: Cents(50000),
          scheduledDate: null,
          status: PayoutStatus.next,
          isNext: true,
        ),
      ],
    ),
    PayoutRotation(
      stokvelId: 'soweto-teachers-001',
      cycleId: 'cycle-002',
      entries: [
        PayoutRotationEntry(
          memberId: 'user-2',
          memberName: 'Thabo',
          position: 1,
          amountCents: Cents(75000),
          scheduledDate: null,
          status: PayoutStatus.next,
          isNext: true,
        ),
        PayoutRotationEntry(
          memberId: 'user-1',
          memberName: 'Lerato',
          position: 2,
          amountCents: Cents(75000),
          scheduledDate: null,
          status: PayoutStatus.upcoming,
          isNext: false,
        ),
      ],
    ),
  ];

  @override
  PayoutRotation? getRotation({
    required String userId,
    required String stokvelId,
    required String cycleId,
  }) {
    final cycle = _stokvelRepository.getCycle(
      userId: userId,
      stokvelId: stokvelId,
      cycleId: cycleId,
    );

    if (cycle == null) return null;

    return _rotations
        .where(
          (rotation) =>
              rotation.stokvelId == stokvelId && rotation.cycleId == cycleId,
        )
        .firstOrNull;
  }
}
