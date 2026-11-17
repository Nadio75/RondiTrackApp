// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'member_list_item.dart';

part 'paged_response_of_member_list_item.g.dart';

@JsonSerializable()
class PagedResponseOfMemberListItem {
  const PagedResponseOfMemberListItem({
    required this.items,
    required this.nextPageToken,
  });
  
  factory PagedResponseOfMemberListItem.fromJson(Map<String, Object?> json) => _$PagedResponseOfMemberListItemFromJson(json);
  
  final List<MemberListItem> items;
  final String? nextPageToken;

  Map<String, Object?> toJson() => _$PagedResponseOfMemberListItemToJson(this);
}
