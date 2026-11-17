// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'home_cycle_response.g.dart';

@JsonSerializable()
class HomeCycleResponse {
  const HomeCycleResponse({
    required this.cycleId,
    required this.period,
    required this.status,
    required this.hasPaid,
    required this.amountOwed,
    required this.nextPayoutDate,
    this.paidCents,
    this.owedCents,
    this.dueAtUtc,
  });

  factory HomeCycleResponse.fromJson(Map<String, Object?> json) =>
      _$HomeCycleResponseFromJson(json);

  final String cycleId;
  final String period;
  final String status;
  final bool hasPaid;
  final String amountOwed;
  final DateTime? nextPayoutDate;
  final dynamic paidCents;
  final dynamic owedCents;
  final DateTime? dueAtUtc;

  Map<String, Object?> toJson() => _$HomeCycleResponseToJson(this);
}
