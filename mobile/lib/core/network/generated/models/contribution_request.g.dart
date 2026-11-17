// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contribution_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContributionRequest _$ContributionRequestFromJson(Map<String, dynamic> json) =>
    ContributionRequest(
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toDouble(),
      contributionCycleId: json['contributionCycleId'] as String,
    );

Map<String, dynamic> _$ContributionRequestToJson(
  ContributionRequest instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'amount': instance.amount,
  'contributionCycleId': instance.contributionCycleId,
};
