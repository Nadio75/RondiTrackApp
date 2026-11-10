import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/features/home/domain/home_summaries_provider.dart';
import 'package:ronditrack/features/home/presentation/home_provider.dart';
import 'package:ronditrack/features/session/data/demo_users.dart';
import 'package:ronditrack/features/session/presentation/session_provider.dart';
import 'package:ronditrack/features/stokvel/presentation/stokvel_details_provider.dart';

void main() {
  test('home providers isolate different user families', () async {
    final container = ProviderContainer.test();
    final lerato = await container.read(homeStokvelsProvider('user-1').future);
    final naledi = await container.read(homeStokvelsProvider('user-3').future);
    expect(lerato, hasLength(2));
    expect(naledi, isEmpty);
    final summaries = await container.read(
      homeSummariesProvider('user-1').future,
    );
    expect(summaries, hasLength(2));
    expect(
      await container.read(homeSummariesProvider('user-3').future),
      isEmpty,
    );
  });

  test('invalidating home notifier reloads its family', () async {
    final container = ProviderContainer.test();
    final provider = homeStokvelsProvider('user-1');
    final subscription = container.listen(provider, (_, _) {});
    addTearDown(subscription.close);
    final first = await container.read(provider.future);
    expect(first, hasLength(2));
    container.invalidate(provider);
    final second = await container.read(provider.future);
    expect(
      second.map((item) => item.id),
      containsAll(['bitcube-001', 'soweto-teachers-001']),
    );
  });

  test('details notifier recalculates on session change', () async {
    final container = ProviderContainer.test();
    final session = container.read(sessionProvider.notifier);
    final provider = stokvelDetailsProvider('bitcube-001');
    final subscription = container.listen(provider, (_, _) {});
    addTearDown(subscription.close);

    expect(session.login('lerato@example.com', demoPassword), isTrue);
    final lerato = await container.read(provider.future);
    expect(lerato!.visibleContributions, hasLength(2));

    session.logout();
    expect(await container.read(provider.future), isNull);

    expect(session.login('thabo@example.com', demoPassword), isTrue);
    final thabo = await container.read(provider.future);
    expect(thabo!.visibleContributions, hasLength(1));
    expect(thabo.visibleContributions.single.memberId, 'user-2');
  });
}
