import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import 'api_session_service.dart';

final apiSessionServiceProvider = Provider<ApiSessionService>((ref) {
  return ApiSessionService(
    auth: ref.watch(apiAuthClientProvider),
    dio: ref.watch(dioProvider),
  );
});
