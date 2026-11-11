import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/features/stokvel/data/fake_stokvel_repository.dart';

void main() {
  late FakeStokvelRepository repository;

  setUp(() {
    repository = FakeStokvelRepository();
  });

  group('Active cycle lookup', () {
    test('Lerato can see the active Bitcube cycle', () {
      final cycle = repository.getActiveCycle(
        userId: 'user-1',
        stokvelId: 'bitcube-001',
      );

      expect(cycle, isNotNull);
      expect(cycle!.id, 'cycle-001');
    });

    test('Thabo can see the active Soweto Teachers cycle', () {
      final cycle = repository.getActiveCycle(
        userId: 'user-2',
        stokvelId: 'soweto-teachers-001',
      );

      expect(cycle, isNotNull);
      expect(cycle!.id, 'cycle-002');
    });

    test('Naledi cannot see the active Bitcube cycle', () {
      final cycle = repository.getActiveCycle(
        userId: 'user-3',
        stokvelId: 'bitcube-001',
      );

      expect(cycle, isNull);
    });

    test('Unknown stokvel has no active cycle', () {
      final cycle = repository.getActiveCycle(
        userId: 'user-1',
        stokvelId: 'unknown-stokvel',
      );

      expect(cycle, isNull);
    });

    test('Unknown user cannot access active cycles', () {
      final cycle = repository.getActiveCycle(
        userId: 'unknown-user',
        stokvelId: 'bitcube-001',
      );

      expect(cycle, isNull);
    });
  });
}
