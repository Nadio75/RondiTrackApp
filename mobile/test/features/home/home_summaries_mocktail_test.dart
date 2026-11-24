import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ronditrack/features/home/domain/home_summaries_provider.dart';
import 'package:ronditrack/features/home/domain/stokvel_summary.dart';
import 'package:ronditrack/features/stokvel/data/fake_stokvel_repository.dart';
import 'package:ronditrack/features/stokvel/domain/stokvel_repository.dart';

class MockStokvelRepository extends Mock implements StokvelRepository {}

void main() {
  const userId = 'user-1';

  late MockStokvelRepository repository;
  late ProviderContainer container;

  final provider = homeSummariesProvider(userId);

  setUp(() {
    repository = MockStokvelRepository();

    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [stokvelRepositoryProvider.overrideWithValue(repository)],
    );

    addTearDown(container.dispose);
  });

  group('HomeSummariesNotifier with Mocktail', () {
    test('starts in loading state', () async {
      when(() => repository.getStokvelsForUser(userId)).thenReturn([]);

      final subscription = container.listen(provider, (_, _) {});

      addTearDown(subscription.close);

      expect(container.read(provider).isLoading, isTrue);

      await container.read(provider.future);

      verify(() => repository.getStokvelsForUser(userId)).called(1);
    });

    test('empty repository response becomes empty data', () async {
      when(() => repository.getStokvelsForUser(userId)).thenReturn([]);

      final subscription = container.listen(provider, (_, _) {});

      addTearDown(subscription.close);

      final result = await container.read(provider.future);

      expect(result, isEmpty);

      expect(container.read(provider), isA<AsyncData<List<StokvelSummary>>>());

      verify(() => repository.getStokvelsForUser(userId)).called(1);

      verifyNoMoreInteractions(repository);
    });

    test('repository exception becomes AsyncError', () async {
      when(() => repository.getStokvelsForUser(userId))
          .thenThrow(StateError('Synthetic repository failure'));

      final subscription = container.listen(provider, (_, _) {});

      addTearDown(subscription.close);

      await expectLater(container.read(provider.future), throwsStateError);

      expect(container.read(provider).hasError, isTrue);

      verify(() => repository.getStokvelsForUser(userId)).called(1);

      verifyNoMoreInteractions(repository);
    });

    test('failed request can be retried successfully', () async {
      when(() => repository.getStokvelsForUser(userId))
          .thenThrow(StateError('Temporary failure'));

      final subscription = container.listen(provider, (_, _) {});

      addTearDown(subscription.close);

      await expectLater(container.read(provider.future), throwsStateError);

      when(() => repository.getStokvelsForUser(userId)).thenReturn([]);

      container.invalidate(provider);

      expect(await container.read(provider.future), isEmpty);

      expect(container.read(provider).hasError, isFalse);

      verify(() => repository.getStokvelsForUser(userId)).called(2);
    });

    test('repository receives only the requested member ID', () async {
      when(() => repository.getStokvelsForUser(userId)).thenReturn([]);

      final subscription = container.listen(provider, (_, _) {});

      addTearDown(subscription.close);

      await container.read(provider.future);

      final captured = verify(() => repository.getStokvelsForUser(captureAny()))
          .captured;

      expect(captured, [userId]);

      verifyNoMoreInteractions(repository);
    });

    test('repeated reads share the same repository result', () async {
      when(() => repository.getStokvelsForUser(userId)).thenReturn([]);

      final subscription = container.listen(provider, (_, _) {});

      addTearDown(subscription.close);

      final first = container.read(provider.future);
      final second = container.read(provider.future);

      final results = await Future.wait([first, second]);

      expect(results[0], isEmpty);
      expect(results[1], isEmpty);

      verify(() => repository.getStokvelsForUser(userId)).called(1);
    });
  });
}
