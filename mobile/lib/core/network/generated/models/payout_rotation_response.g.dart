// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payout_rotation_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PayoutRotationResponse _$PayoutRotationResponseFromJson(
  Map<String, dynamic> json,
) => PayoutRotationResponse(
  stokvelId: json['stokvelId'] as String,
  cycleId: json['cycleId'] as String,
  entries: (json['entries'] as List<dynamic>)
      .map(
        (e) => PayoutRotationEntryResponse.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
);

Map<String, dynamic> _$PayoutRotationResponseToJson(
  PayoutRotationResponse instance,
) => <String, dynamic>{
  'stokvelId': instance.stokvelId,
  'cycleId': instance.cycleId,
  'entries': instance.entries,
};
