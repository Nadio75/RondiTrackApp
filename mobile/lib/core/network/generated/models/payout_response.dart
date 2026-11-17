// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'payout_response.g.dart';

@JsonSerializable()
class PayoutResponse {
  const PayoutResponse({
    required this.id,
    required this.stokvelId,
    required this.contributionCycleId,
    required this.recipientUserId,
    required this.amount,
    required this.processedAt,
    required this.version,
  });
  
  factory PayoutResponse.fromJson(Map<String, Object?> json) => _$PayoutResponseFromJson(json);
  
  final String id;
  final String stokvelId;
  final String contributionCycleId;
  final String recipientUserId;
  final double amount;
  final DateTime processedAt;
  final dynamic version;

  Map<String, Object?> toJson() => _$PayoutResponseToJson(this);
}
