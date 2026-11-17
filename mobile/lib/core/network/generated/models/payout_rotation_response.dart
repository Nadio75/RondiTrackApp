// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'payout_rotation_entry_response.dart';

part 'payout_rotation_response.g.dart';

@JsonSerializable()
class PayoutRotationResponse {
  const PayoutRotationResponse({
    required this.stokvelId,
    required this.cycleId,
    required this.entries,
  });
  
  factory PayoutRotationResponse.fromJson(Map<String, Object?> json) => _$PayoutRotationResponseFromJson(json);
  
  final String stokvelId;
  final String cycleId;
  final List<PayoutRotationEntryResponse> entries;

  Map<String, Object?> toJson() => _$PayoutRotationResponseToJson(this);
}
