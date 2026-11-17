// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'payout_rotation_entry_response.g.dart';

@JsonSerializable()
class PayoutRotationEntryResponse {
  const PayoutRotationEntryResponse({
    required this.memberId,
    required this.memberName,
    required this.position,
    required this.amountCents,
    required this.scheduledDate,
    required this.status,
    required this.isNext,
  });
  
  factory PayoutRotationEntryResponse.fromJson(Map<String, Object?> json) => _$PayoutRotationEntryResponseFromJson(json);
  
  final String memberId;
  final String memberName;
  final dynamic position;
  final dynamic amountCents;
  final DateTime? scheduledDate;
  final String status;
  final bool isNext;

  Map<String, Object?> toJson() => _$PayoutRotationEntryResponseToJson(this);
}
