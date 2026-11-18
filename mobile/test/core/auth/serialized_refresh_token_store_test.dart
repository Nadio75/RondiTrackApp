import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/core/auth/refresh_token_store.dart';
import 'package:ronditrack/core/auth/serialized_refresh_token_store.dart';

class DelayedStore implements RefreshTokenStore {
  String? token;

  final writeStarted = Completer<void>();
  final releaseWrite = Completer<void>();

  @override
  Future<String?> read() async => token;

  @override
  Future<void> write(String value) async {
    writeStarted.complete();
    await releaseWrite.future;
    token = value;
  }

  @override
  Future<void> clear() async {
    token = null;
  }
}

void main() {
  test('clear waits for a pending write and removes its token', () async {
    final inner = DelayedStore();
    final store = SerializedRefreshTokenStore(inner);

    final pendingWrite = store.write('late-refresh-token');

    await inner.writeStarted.future.timeout(const Duration(seconds: 5));

    final pendingClear = store.clear();

    inner.releaseWrite.complete();

    await pendingWrite.timeout(const Duration(seconds: 5));
    await pendingClear.timeout(const Duration(seconds: 5));

    expect(await store.read(), isNull);
  });
}
