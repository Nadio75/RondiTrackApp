import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/features/home/presentation/home_provider.dart';
import 'package:ronditrack/features/session/data/demo_users.dart';
import 'package:ronditrack/features/session/presentation/session_provider.dart';
import 'package:ronditrack/features/stokvel/presentation/stokvel_details_provider.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer.test();
  });

  tearDown(() {
    container.dispose();
  });

  test('Lerato receives Bitcube from the Home provider', () async {
    final stokvels = await container.read(
      homeStokvelsProvider('user-1').future,
    );

    expect(stokvels.length, 1);
    expect(stokvels.single.name, 'Bitcube');
  });

  test('Naledi receives an empty stokvel list', () async {
    final stokvels = await container.read(
      homeStokvelsProvider('user-3').future,
    );

    expect(stokvels, isEmpty);
  });

  test('Thabo receives only his contribution details', () async {
    final loggedIn = container
        .read(sessionProvider.notifier)
        .login('thabo@example.com', demoPassword);

    expect(loggedIn, isTrue);

    final details = await container.read(
      stokvelDetailsProvider('bitcube-001').future,
    );

    expect(details, isNotNull);
    expect(details!.visibleContributions.length, 1);
    expect(details.visibleContributions.single.memberId, 'user-2');
  });

  test('Unknown stokvel returns no details', () async {
    container
        .read(sessionProvider.notifier)
        .login('lerato@example.com', demoPassword);

    final details = await container.read(
      stokvelDetailsProvider('does-not-exist').future,
    );

    expect(details, isNull);
  });

  test('Switching accounts updates visible contribution data', () async {
    final session = container.read(sessionProvider.notifier);

    expect(session.login('lerato@example.com', demoPassword), isTrue);

    final leratoDetails = await container.read(
      stokvelDetailsProvider('bitcube-001').future,
    );

    expect(leratoDetails!.visibleContributions.length, 2);

    session.logout();

    expect(session.login('thabo@example.com', demoPassword), isTrue);

    final thaboDetails = await container.read(
      stokvelDetailsProvider('bitcube-001').future,
    );

    expect(thaboDetails, isNotNull);
    expect(thaboDetails!.visibleContributions.length, 1);
    expect(thaboDetails.visibleContributions.single.memberId, 'user-2');
  });
}
