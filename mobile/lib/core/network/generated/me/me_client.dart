// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/home_dashboard_response.dart';
import '../models/me_profile_response.dart';

part 'me_client.g.dart';

@RestApi()
abstract class MeClient {
  factory MeClient(Dio dio, {String? baseUrl}) = _MeClient;

  /// Get the authenticated user's profile
  @GET('/api/v1/me')
  Future<MeProfileResponse> getApiV1Me();

  /// Get the authenticated user's home dashboard
  @GET('/api/v1/me/home')
  Future<HomeDashboardResponse> getApiV1MeHome();
}
