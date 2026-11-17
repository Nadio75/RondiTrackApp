// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'contribution_cycle_response.g.dart';

@JsonSerializable()
class ContributionCycleResponse {
  const ContributionCycleResponse({
    required this.id,
    required this.stokvelId,
    required this.period,
    required this.targetAmount,
    required this.createdAt,
    this.status,
    this.isClosed,
    this.closedAtUtc,
    this.dueAtUtc,
    this.totalCollectedCents,
    this.amountDueCents,
  });

  factory ContributionCycleResponse.fromJson(Map<String, Object?> json) =>
      _$ContributionCycleResponseFromJson(json);

  final String id;
  final String stokvelId;
  final String period;
  final double targetAmount;
  final DateTime createdAt;
  final String? status;
  final bool? isClosed;
  final DateTime? closedAtUtc;
  final DateTime? dueAtUtc;
  final dynamic totalCollectedCents;
  final dynamic amountDueCents;

  Map<String, Object?> toJson() => _$ContributionCycleResponseToJson(this);
}
