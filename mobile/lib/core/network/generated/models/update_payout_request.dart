// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'update_payout_request.g.dart';

@JsonSerializable()
class UpdatePayoutRequest {
  const UpdatePayoutRequest({required this.amount, required this.version});

  factory UpdatePayoutRequest.fromJson(Map<String, Object?> json) =>
      _$UpdatePayoutRequestFromJson(json);

  final double amount;
  final dynamic version;

  Map<String, Object?> toJson() => _$UpdatePayoutRequestToJson(this);
}
