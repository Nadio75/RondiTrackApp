import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/core/notifications/push_config.dart';
import 'package:ronditrack/core/notifications/push_destination.dart';
import 'package:ronditrack/core/notifications/push_gateway.dart';

void main() {
  const stokvelId = '12345678-1234-1234-1234-123456789abc';
  const cycleId = '87654321-4321-4321-4321-cba987654321';

  Map<String, dynamic> payload() => {
    'type': 'contribution_confirmed',
    'stokvelId': stokvelId,
    'cycleId': cycleId,
  };

  group('Push configuration', () {
    test('missing configuration disables push', () {
      const config = PushConfig(
        apiKey: '',
        appId: '',
        messagingSenderId: '',
        projectId: '',
      );

      expect(config.enabled, isFalse);
    });

    test('partial configuration fails safely', () {
      const config = PushConfig(
        apiKey: 'example',
        appId: '',
        messagingSenderId: '',
        projectId: '',
      );

      expect(() => config.enabled, throwsStateError);
    });

    test('complete configuration enables push', () {
      const config = PushConfig(
        apiKey: 'example-key',
        appId: 'example-app',
        messagingSenderId: '123456',
        projectId: 'example-project',
      );

      expect(config.enabled, isTrue);
      expect(config.options.projectId, 'example-project');
    });
  });

  group('Notification destinations', () {
    test('valid confirmation opens the expected cycle', () {
      final destination = PushDestination.parse(payload());

      expect(destination?.location, '/stokvels/$stokvelId/cycles/$cycleId');
    });

    test('unknown event is rejected', () {
      expect(PushDestination.parse(payload()..['type'] = 'unknown'), isNull);
    });

    test('arbitrary route is rejected', () {
      expect(
        PushDestination.parse(payload()..['stokvelId'] = '../../profile'),
        isNull,
      );
    });

    test('missing cycle is rejected', () {
      expect(PushDestination.parse(payload()..remove('cycleId')), isNull);
    });

    test('empty identifier is rejected', () {
      expect(
        PushDestination.parse(
          payload()..['cycleId'] = '00000000-0000-0000-0000-000000000000',
        ),
        isNull,
      );
    });

    test('non-string identifier is rejected', () {
      expect(PushDestination.parse(payload()..['cycleId'] = 123), isNull);
    });
  });

  test('disabled gateway is safe without Firebase', () async {
    const gateway = DisabledPushGateway();

    expect(gateway.enabled, isFalse);
    expect(await gateway.initialMessage(), isNull);
    expect(await gateway.requestPermission(), isFalse);
    expect(await gateway.onRegistered.toList(), isEmpty);

    await gateway.register();
    await gateway.unregister();
  });
}
