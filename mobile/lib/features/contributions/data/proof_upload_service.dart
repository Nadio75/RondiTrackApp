import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/images/proof_image_processor.dart';
import '../../../core/network/dio_provider.dart';

final proofUploadServiceProvider = Provider<ProofUploadService>(
  (ref) => ProofUploadService(ref.watch(dioProvider)),
);

class ProofUploadService {
  ProofUploadService(this._dio);

  final Dio _dio;

  Future<void> upload({
    required String stokvelId,
    required String contributionId,
    required Uint8List jpeg,
    required int sessionGeneration,
    CancelToken? cancelToken,
    void Function(int sent, int total)? onProgress,
  }) async {
    final guid = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );

    if (!guid.hasMatch(stokvelId) || !guid.hasMatch(contributionId)) {
      throw const FormatException('Invalid contribution identifiers.');
    }

    if (jpeg.length < 3 ||
        jpeg.length > ProofImageProcessor.maxBytes ||
        jpeg[0] != 0xFF ||
        jpeg[1] != 0xD8 ||
        jpeg[2] != 0xFF) {
      throw const FormatException('Invalid proof image.');
    }

    final form = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        jpeg,
        filename: 'proof.jpg',
        contentType: DioMediaType('image', 'jpeg'),
      ),
    });

    await _dio.post<void>(
      '/api/v1/stokvels/$stokvelId/contributions/$contributionId/proof',
      data: form,
      cancelToken: cancelToken,
      onSendProgress: onProgress,
      options: Options(
        extra: {'requiredAuthSessionGeneration': sessionGeneration},
        sendTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
  }
}
