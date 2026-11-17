// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'home_cycle_response.dart';

part 'home_stokvel_response.g.dart';

@JsonSerializable()
class HomeStokvelResponse {
  const HomeStokvelResponse({
    required this.stokvelId,
    required this.name,
    required this.role,
    required this.contributionAmount,
    required this.currentCycle,
    this.contributionAmountCents,
    this.personalArrearsCents,
  });
  
  factory HomeStokvelResponse.fromJson(Map<String, Object?> json) => _$HomeStokvelResponseFromJson(json);
  
  final String stokvelId;
  final String name;
  final String role;
  final String contributionAmount;
  final HomeCycleResponse? currentCycle;
  final dynamic contributionAmountCents;
  final dynamic personalArrearsCents;

  Map<String, Object?> toJson() => _$HomeStokvelResponseToJson(this);
}
