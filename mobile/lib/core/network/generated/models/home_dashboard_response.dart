// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'home_stokvel_response.dart';

part 'home_dashboard_response.g.dart';

@JsonSerializable()
class HomeDashboardResponse {
  const HomeDashboardResponse({
    required this.stokvels,
  });
  
  factory HomeDashboardResponse.fromJson(Map<String, Object?> json) => _$HomeDashboardResponseFromJson(json);
  
  final List<HomeStokvelResponse> stokvels;

  Map<String, Object?> toJson() => _$HomeDashboardResponseToJson(this);
}
