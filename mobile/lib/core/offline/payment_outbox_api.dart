import 'package:dio/dio.dart';

import 'app_database.dart';

abstract interface class PaymentOutboxApi {
  Future<void> send(
    PendingPaymentIntent intent, {
    required String idempotencyKey,
  });
}

class DioPaymentOutboxApi implements PaymentOutboxApi {
  const DioPaymentOutboxApi(this._dio, {this.requiredAuthSessionGeneration});

  final Dio _dio;
  final int? requiredAuthSessionGeneration;

  @override
  Future<void> send(
    PendingPaymentIntent intent, {
    required String idempotencyKey,
  }) async {
    final stokvelId = Uri.encodeComponent(intent.stokvelId);
    final cycleId = Uri.encodeComponent(intent.cycleId);

    final response = await _dio.post<dynamic>(
      '/api/v1/stokvels/$stokvelId/cycles/$cycleId/contributions',
      data: {'userId': intent.memberId, 'amountInCents': intent.amountInCents},
      options: Options(
        headers: {'Idempotency-Key': idempotencyKey},
        extra: {
          'requiredAuthSessionGeneration': ?requiredAuthSessionGeneration,
        },
        validateStatus: (status) => status == 201,
        followRedirects: false,
      ),
    );

    if (response.statusCode != 201) {
      throw DioException.badResponse(
        statusCode: response.statusCode ?? 0,
        requestOptions: response.requestOptions,
        response: response,
      );
    }
  }
}
