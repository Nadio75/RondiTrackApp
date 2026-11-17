// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'contribution_request.g.dart';

@JsonSerializable()
class ContributionRequest {
  const ContributionRequest({
    required this.userId,
    required this.amount,
    required this.contributionCycleId,
  });

  factory ContributionRequest.fromJson(Map<String, Object?> json) =>
      _$ContributionRequestFromJson(json);

  final String userId;
  final double amount;
  final String contributionCycleId;

  Map<String, Object?> toJson() => _$ContributionRequestToJson(this);
}
