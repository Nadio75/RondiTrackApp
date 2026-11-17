// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_list_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MemberListItem _$MemberListItemFromJson(Map<String, dynamic> json) =>
    MemberListItem(
      userId: json['userId'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      joinedAtUtc: DateTime.parse(json['joinedAtUtc'] as String),
    );

Map<String, dynamic> _$MemberListItemToJson(MemberListItem instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'name': instance.name,
      'role': instance.role,
      'joinedAtUtc': instance.joinedAtUtc.toIso8601String(),
    };
