// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'me_profile_response.g.dart';

@JsonSerializable()
class MeProfileResponse {
  const MeProfileResponse({
    required this.id,
    required this.name,
    required this.email,
  });
  
  factory MeProfileResponse.fromJson(Map<String, Object?> json) => _$MeProfileResponseFromJson(json);
  
  final String id;
  final String name;
  final String email;

  Map<String, Object?> toJson() => _$MeProfileResponseToJson(this);
}
