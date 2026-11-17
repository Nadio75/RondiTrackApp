import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ronditrack/core/network/auth_interceptor.dart';
import 'package:ronditrack/core/network/dio_provider.dart';

void main() {
  test('Dio and auth providers share one network session', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final session = container.read(apiNetworkSessionProvider);
    final dio = container.read(dioProvider);
    final auth = container.read(apiAuthClientProvider);

    expect(identical(session.dio, dio), isTrue);
    expect(identical(session.auth, auth), isTrue);
    expect(auth.isAuthenticated, isFalse);
  });

  test('shared Dio has one authentication interceptor', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final dio = container.read(dioProvider);

    final authInterceptors = dio.interceptors
        .whereType<AuthInterceptor>()
        .toList();

    expect(authInterceptors, hasLength(1));
  });
}
