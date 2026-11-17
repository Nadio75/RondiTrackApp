// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'activity_client.g.dart';

@RestApi()
abstract class ActivityClient {
  factory ActivityClient(Dio dio, {String? baseUrl}) = _ActivityClient;

  @GET('/api/v1/activity')
  Future<void> getApiV1Activity({
    @Query('pageToken') String? pageToken,
    @Query('pageSize') dynamic pageSize = 20,
  });
}
