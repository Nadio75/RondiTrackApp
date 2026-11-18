import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/core/auth/refresh_token_store.dart';

void main() {
  group('MemoryRefreshTokenStore', () {
    late MemoryRefreshTokenStore store;

    setUp(() {
      store = MemoryRefreshTokenStore();
    });

    test('starts without a refresh token', () async {
      expect(await store.read(), isNull);
    });

    test('saves and reads a refresh token', () async {
      await store.write('first-refresh-token');

      expect(await store.read(), 'first-refresh-token');
    });

    test('replaces an existing refresh token', () async {
      await store.write('old-token');
      await store.write('rotated-token');

      expect(await store.read(), 'rotated-token');
    });

    test('clears the refresh token on logout', () async {
      await store.write('private-refresh-token');
      await store.clear();

      expect(await store.read(), isNull);
    });

    test('can be cleared more than once', () async {
      await store.clear();
      await store.clear();

      expect(await store.read(), isNull);
    });
  });
}
