// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'stokvel_contribution_history_client.g.dart';

@RestApi()
abstract class StokvelContributionHistoryClient {
  factory StokvelContributionHistoryClient(Dio dio, {String? baseUrl}) = _StokvelContributionHistoryClient;

  @GET('/api/v1/stokvels/{id}/contributions')
  Future<void> getApiV1StokvelsIdContributions({
    @Path('id') required String id,
    @Query('sort') String? sort = 'newest',
    @Query('pageSize') dynamic pageSize = 20,
    @Query('member') String? member,
    @Query('from') String? from,
    @Query('to') String? to,
    @Query('pageToken') String? pageToken,
  });
}
