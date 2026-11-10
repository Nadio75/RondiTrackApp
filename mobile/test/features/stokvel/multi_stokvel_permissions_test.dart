import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/features/stokvel/data/fake_stokvel_repository.dart';
import 'package:ronditrack/features/stokvel/domain/stokvel_models.dart';

void main() {
  group('Multi-stokvel membership permissions', () {
    late FakeStokvelRepository repository;

    setUp(() {
      repository = FakeStokvelRepository();
    });

    test('Lerato belongs to two stokvels', () {
      final stokvels = repository.getStokvelsForUser('user-1');

      expect(stokvels, hasLength(2));
      expect(
        stokvels.map((stokvel) => stokvel.id),
        containsAll(['bitcube-001', 'soweto-teachers-001']),
      );
    });

    test('Lerato has separate roles in each stokvel', () {
      final bitcube = repository.getDetails(
        userId: 'user-1',
        stokvelId: 'bitcube-001',
      );

      final teachers = repository.getDetails(
        userId: 'user-1',
        stokvelId: 'soweto-teachers-001',
      );

      expect(bitcube, isNotNull);
      expect(teachers, isNotNull);

      expect(bitcube!.membership.role, StokvelRole.treasurer);
      expect(teachers!.membership.role, StokvelRole.member);
    });

    test('Lerato cannot view other members in second stokvel', () {
      final details = repository.getDetails(
        userId: 'user-1',
        stokvelId: 'soweto-teachers-001',
      );

      expect(details, isNotNull);
      expect(details!.visibleContributions, hasLength(1));
      expect(details.visibleContributions.single.memberId, 'user-1');
      expect(
        details.visibleContributions.single.stokvelId,
        'soweto-teachers-001',
      );
    });

    test('Naledi cannot access either stokvel', () {
      for (final id in ['bitcube-001', 'soweto-teachers-001']) {
        expect(repository.getDetails(userId: 'user-3', stokvelId: id), isNull);
      }
    });
  });
}
