import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/dio_provider.dart';
import 'offline_home_providers.dart';
import 'payment_outbox_api.dart';
import 'payment_outbox_repository.dart';
import 'payment_outbox_service.dart';

final paymentOutboxRepositoryProvider = Provider<PaymentOutboxRepository>((
  ref,
) {
  return PaymentOutboxRepository(ref.watch(appDatabaseProvider));
});

final paymentOutboxApiProvider = Provider<PaymentOutboxApi>((ref) {
  return DioPaymentOutboxApi(ref.watch(dioProvider));
});

final paymentOutboxServiceProvider = Provider<PaymentOutboxService>((ref) {
  return PaymentOutboxService(
    repository: ref.watch(paymentOutboxRepositoryProvider),
    api: ref.watch(paymentOutboxApiProvider),
  );
});
