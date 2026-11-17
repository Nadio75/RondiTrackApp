// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contribution_cycle_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContributionCycleResponse _$ContributionCycleResponseFromJson(
  Map<String, dynamic> json,
) => ContributionCycleResponse(
  id: json['id'] as String,
  stokvelId: json['stokvelId'] as String,
  period: json['period'] as String,
  targetAmount: (json['targetAmount'] as num).toDouble(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  status: json['status'] as String?,
  isClosed: json['isClosed'] as bool?,
  closedAtUtc: json['closedAtUtc'] == null
      ? null
      : DateTime.parse(json['closedAtUtc'] as String),
  dueAtUtc: json['dueAtUtc'] == null
      ? null
      : DateTime.parse(json['dueAtUtc'] as String),
  totalCollectedCents: json['totalCollectedCents'],
  amountDueCents: json['amountDueCents'],
);

Map<String, dynamic> _$ContributionCycleResponseToJson(
  ContributionCycleResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'stokvelId': instance.stokvelId,
  'period': instance.period,
  'targetAmount': instance.targetAmount,
  'createdAt': instance.createdAt.toIso8601String(),
  'status': instance.status,
  'isClosed': instance.isClosed,
  'closedAtUtc': instance.closedAtUtc?.toIso8601String(),
  'dueAtUtc': instance.dueAtUtc?.toIso8601String(),
  'totalCollectedCents': instance.totalCollectedCents,
  'amountDueCents': instance.amountDueCents,
};
