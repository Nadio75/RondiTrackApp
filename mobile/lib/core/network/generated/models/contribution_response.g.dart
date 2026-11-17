// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contribution_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContributionResponse _$ContributionResponseFromJson(
  Map<String, dynamic> json,
) => ContributionResponse(
  id: json['id'] as String,
  stokvelId: json['stokvelId'] as String,
  userId: json['userId'] as String,
  amount: (json['amount'] as num).toDouble(),
  contributionCycleId: json['contributionCycleId'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$ContributionResponseToJson(
  ContributionResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'stokvelId': instance.stokvelId,
  'userId': instance.userId,
  'amount': instance.amount,
  'contributionCycleId': instance.contributionCycleId,
  'createdAt': instance.createdAt.toIso8601String(),
};
