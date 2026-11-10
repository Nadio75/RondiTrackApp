import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/core/config/app_config.dart';

void main() {
  test('rejects missing configuration', () {
    expect(
      () => validateAppConfig(
        flavor: '',
        apiUrl: '',
        nativeFlavor: null,
        runningOnWeb: false,
      ),
      throwsStateError,
    );
  });

  test('rejects mismatched Android flavour', () {
    expect(
      () => validateAppConfig(
        flavor: 'dev',
        apiUrl: 'https://example.invalid',
        nativeFlavor: 'prod',
        runningOnWeb: false,
      ),
      throwsStateError,
    );
  });

  test('accepts matching Android configuration', () {
    expect(
      () => validateAppConfig(
        flavor: 'dev',
        apiUrl: 'https://example.invalid',
        nativeFlavor: 'dev',
        runningOnWeb: false,
      ),
      returnsNormally,
    );
  });

  test('allows web configuration without native flavour', () {
    expect(
      () => validateAppConfig(
        flavor: 'dev',
        apiUrl: 'https://example.invalid',
        nativeFlavor: null,
        runningOnWeb: true,
      ),
      returnsNormally,
    );
  });
}
