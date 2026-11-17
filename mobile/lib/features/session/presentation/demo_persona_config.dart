import 'package:flutter_riverpod/flutter_riverpod.dart';

final demoPersonasEnabledProvider = Provider<bool>((ref) {
  return const bool.fromEnvironment(
    'ENABLE_DEMO_PERSONAS',
    defaultValue: false,
  );
});
