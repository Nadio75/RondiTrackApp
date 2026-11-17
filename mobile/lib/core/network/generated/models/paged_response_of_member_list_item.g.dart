// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paged_response_of_member_list_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PagedResponseOfMemberListItem _$PagedResponseOfMemberListItemFromJson(
  Map<String, dynamic> json,
) => PagedResponseOfMemberListItem(
  items: (json['items'] as List<dynamic>)
      .map((e) => MemberListItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  nextPageToken: json['nextPageToken'] as String?,
);

Map<String, dynamic> _$PagedResponseOfMemberListItemToJson(
  PagedResponseOfMemberListItem instance,
) => <String, dynamic>{
  'items': instance.items,
  'nextPageToken': instance.nextPageToken,
};
