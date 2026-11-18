import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Storage contract for the native refresh credential.
///
/// Access tokens must never be stored here.
abstract class RefreshTokenStore {
  Future<String?> read();

  Future<void> write(String token);

  Future<void> clear();
}

/// Native encrypted storage for a refresh token.
class SecureRefreshTokenStore implements RefreshTokenStore {
  SecureRefreshTokenStore(this._storage);

  final FlutterSecureStorage _storage;

  static const String _key = 'ronditrack_refresh';

  @override
  Future<String?> read() => _storage.read(key: _key);

  @override
  Future<void> write(String token) => _storage.write(key: _key, value: token);

  @override
  Future<void> clear() => _storage.delete(key: _key);
}

/// Test implementation that does not require platform plugins.
class MemoryRefreshTokenStore implements RefreshTokenStore {
  String? _token;

  @override
  Future<String?> read() async => _token;

  @override
  Future<void> write(String token) async {
    _token = token;
  }

  @override
  Future<void> clear() async {
    _token = null;
  }
}
