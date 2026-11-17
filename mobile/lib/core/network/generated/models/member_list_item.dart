// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'member_list_item.g.dart';

@JsonSerializable()
class MemberListItem {
  const MemberListItem({
    required this.userId,
    required this.name,
    required this.role,
    required this.joinedAtUtc,
  });
  
  factory MemberListItem.fromJson(Map<String, Object?> json) => _$MemberListItemFromJson(json);
  
  final String userId;
  final String name;
  final String role;
  final DateTime joinedAtUtc;

  Map<String, Object?> toJson() => _$MemberListItemToJson(this);
}
