import 'package:ronditrack/core/money/cents.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/features/session/presentation/session_provider.dart';
import 'package:ronditrack/features/stokvel/presentation/stokvel_details_provider.dart';

void main() {
  test('Switching accounts never exposes another member data', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final session = container.read(sessionProvider.notifier);

    // Lerato is the treasurer and can view all contributions.
    expect(session.login('lerato@example.com', 'testpassword123'), isTrue);

    final leratoDetails = await container.read(
      stokvelDetailsProvider('bitcube-001').future,
    );

    expect(leratoDetails, isNotNull);
    expect(leratoDetails!.visibleContributions.length, 2);
    expect(leratoDetails.visiblePaidTotalCents, const Cents(50000));

    // Logout clears the active session.
    session.logout();

    final loggedOutDetails = await container.read(
      stokvelDetailsProvider('bitcube-001').future,
    );

    expect(loggedOutDetails, isNull);

    // Thabo must only see his own contribution.
    expect(session.login('thabo@example.com', 'testpassword123'), isTrue);

    final thaboDetails = await container.read(
      stokvelDetailsProvider('bitcube-001').future,
    );

    expect(thaboDetails, isNotNull);
    expect(thaboDetails!.visibleContributions.length, 1);
    expect(thaboDetails.visibleContributions.single.memberId, 'user-2');
    expect(thaboDetails.visiblePaidTotalCents, const Cents(0));

    // Naledi is not a member of Bitcube.
    session.logout();
    expect(session.login('naledi@example.com', 'testpassword123'), isTrue);

    final nalediDetails = await container.read(
      stokvelDetailsProvider('bitcube-001').future,
    );

    expect(nalediDetails, isNull);
  });
}
