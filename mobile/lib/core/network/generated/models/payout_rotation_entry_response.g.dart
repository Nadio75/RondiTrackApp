// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payout_rotation_entry_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PayoutRotationEntryResponse _$PayoutRotationEntryResponseFromJson(
  Map<String, dynamic> json,
) => PayoutRotationEntryResponse(
  memberId: json['memberId'] as String,
  memberName: json['memberName'] as String,
  position: json['position'],
  amountCents: json['amountCents'],
  scheduledDate: json['scheduledDate'] == null
      ? null
      : DateTime.parse(json['scheduledDate'] as String),
  status: json['status'] as String,
  isNext: json['isNext'] as bool,
);

Map<String, dynamic> _$PayoutRotationEntryResponseToJson(
  PayoutRotationEntryResponse instance,
) => <String, dynamic>{
  'memberId': instance.memberId,
  'memberName': instance.memberName,
  'position': instance.position,
  'amountCents': instance.amountCents,
  'scheduledDate': instance.scheduledDate?.toIso8601String(),
  'status': instance.status,
  'isNext': instance.isNext,
};
