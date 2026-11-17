// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'add_member_request.g.dart';

@JsonSerializable()
class AddMemberRequest {
  const AddMemberRequest({
    required this.userId,
  });
  
  factory AddMemberRequest.fromJson(Map<String, Object?> json) => _$AddMemberRequestFromJson(json);
  
  final String userId;

  Map<String, Object?> toJson() => _$AddMemberRequestToJson(this);
}
