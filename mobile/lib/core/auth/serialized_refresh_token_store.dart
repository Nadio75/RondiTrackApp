import 'dart:async';

import 'refresh_token_store.dart';

/// Ensures refresh-credential storage operations complete in order.
class SerializedRefreshTokenStore implements RefreshTokenStore {
  SerializedRefreshTokenStore(this._inner);

  final RefreshTokenStore _inner;

  Future<void> _pending = Future<void>.value();

  Future<T> _enqueue<T>(Future<T> Function() operation) {
    final result = _pending.then((_) => operation());

    // Keep the queue usable even if an operation fails.
    _pending = result.then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {},
    );

    return result;
  }

  @override
  Future<String?> read() => _enqueue(_inner.read);

  @override
  Future<void> write(String token) => _enqueue(() => _inner.write(token));

  @override
  Future<void> clear() => _enqueue(_inner.clear);
}
