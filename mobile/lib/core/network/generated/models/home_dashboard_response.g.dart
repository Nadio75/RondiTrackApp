// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_dashboard_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomeDashboardResponse _$HomeDashboardResponseFromJson(
  Map<String, dynamic> json,
) => HomeDashboardResponse(
  stokvels: (json['stokvels'] as List<dynamic>)
      .map((e) => HomeStokvelResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$HomeDashboardResponseToJson(
  HomeDashboardResponse instance,
) => <String, dynamic>{'stokvels': instance.stokvels};
