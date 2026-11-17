// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payout_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PayoutResponse _$PayoutResponseFromJson(Map<String, dynamic> json) =>
    PayoutResponse(
      id: json['id'] as String,
      stokvelId: json['stokvelId'] as String,
      contributionCycleId: json['contributionCycleId'] as String,
      recipientUserId: json['recipientUserId'] as String,
      amount: (json['amount'] as num).toDouble(),
      processedAt: DateTime.parse(json['processedAt'] as String),
      version: json['version'],
    );

Map<String, dynamic> _$PayoutResponseToJson(PayoutResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'stokvelId': instance.stokvelId,
      'contributionCycleId': instance.contributionCycleId,
      'recipientUserId': instance.recipientUserId,
      'amount': instance.amount,
      'processedAt': instance.processedAt.toIso8601String(),
      'version': instance.version,
    };
