import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/features/stokvel/data/fake_payout_repository.dart';
import 'package:ronditrack/features/stokvel/domain/payout_models.dart';

void main() {
  final repository = FakePayoutRepository();

  group('Fake payout repository', () {
    test('treasurer can view the Bitcube payout rotation', () {
      final rotation = repository.getRotation(
        userId: 'user-1',
        stokvelId: 'bitcube-001',
        cycleId: 'cycle-001',
      );

      expect(rotation, isNotNull);
      expect(rotation!.entries.length, 2);
      expect(rotation.entries.first.memberName, 'Lerato');
      expect(rotation.entries.first.status, PayoutStatus.paid);
      expect(rotation.entries.last.status, PayoutStatus.next);
      expect(rotation.entries.last.isNext, isTrue);
    });

    test('ordinary member can view the same rotation', () {
      final rotation = repository.getRotation(
        userId: 'user-2',
        stokvelId: 'bitcube-001',
        cycleId: 'cycle-001',
      );

      expect(rotation, isNotNull);
      expect(rotation!.entries.first.position, 1);
      expect(rotation.entries.last.position, 2);
    });

    test('nonmember cannot view a payout rotation', () {
      final rotation = repository.getRotation(
        userId: 'user-3',
        stokvelId: 'bitcube-001',
        cycleId: 'cycle-001',
      );

      expect(rotation, isNull);
    });

    test('rejects a cycle belonging to another stokvel', () {
      final rotation = repository.getRotation(
        userId: 'user-1',
        stokvelId: 'bitcube-001',
        cycleId: 'cycle-002',
      );

      expect(rotation, isNull);
    });

    test('returns null for an unknown cycle', () {
      final rotation = repository.getRotation(
        userId: 'user-1',
        stokvelId: 'bitcube-001',
        cycleId: 'missing-cycle',
      );

      expect(rotation, isNull);
    });

    test('returns the separate Soweto Teachers rotation', () {
      final rotation = repository.getRotation(
        userId: 'user-2',
        stokvelId: 'soweto-teachers-001',
        cycleId: 'cycle-002',
      );

      expect(rotation, isNotNull);
      expect(rotation!.entries.first.memberName, 'Thabo');
      expect(rotation.entries.first.amountCents.value, 75000);
      expect(rotation.entries.last.status, PayoutStatus.upcoming);
    });
  });
}
