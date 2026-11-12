import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/core/money/cents.dart';
import 'package:ronditrack/features/stokvel/domain/payout_contract_mapping.dart';
import 'package:ronditrack/features/stokvel/domain/payout_models.dart';

void main() {
  group('Payout status mapping', () {
    test('maps known backend statuses', () {
      expect(payoutStatusFromWire('paid'), PayoutStatus.paid);
      expect(payoutStatusFromWire('next'), PayoutStatus.next);
      expect(payoutStatusFromWire('upcoming'), PayoutStatus.upcoming);
    });

    test('unknown values do not crash the app', () {
      expect(payoutStatusFromWire(null), PayoutStatus.unknown);
      expect(payoutStatusFromWire('unexpected'), PayoutStatus.unknown);
    });
  });

  group('Payout rotation models', () {
    test('preserves backend order and amounts', () {
      final rotation = PayoutRotation(
        stokvelId: 'bitcube-001',
        cycleId: 'cycle-001',
        entries: [
          const PayoutRotationEntry(
            memberId: 'user-2',
            memberName: 'Thabo',
            position: 1,
            amountCents: Cents(50000),
            scheduledDate: null,
            status: PayoutStatus.next,
            isNext: true,
          ),
          const PayoutRotationEntry(
            memberId: 'user-1',
            memberName: 'Lerato',
            position: 2,
            amountCents: Cents(50000),
            scheduledDate: null,
            status: PayoutStatus.upcoming,
            isNext: false,
          ),
        ],
      );

      expect(rotation.entries.map((entry) => entry.memberId).toList(), [
        'user-2',
        'user-1',
      ]);
      expect(rotation.entries.first.position, 1);
      expect(rotation.entries.first.amountCents.value, 50000);
      expect(rotation.entries.first.isNext, isTrue);
      expect(rotation.entries.first.scheduledDate, isNull);
    });

    test('supports an empty rotation', () {
      const rotation = PayoutRotation(
        stokvelId: 'bitcube-001',
        cycleId: 'cycle-001',
        entries: [],
      );

      expect(rotation.entries, isEmpty);
    });
  });
}
