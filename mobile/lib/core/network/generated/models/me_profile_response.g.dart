// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me_profile_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeProfileResponse _$MeProfileResponseFromJson(Map<String, dynamic> json) =>
    MeProfileResponse(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
    );

Map<String, dynamic> _$MeProfileResponseToJson(MeProfileResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
    };
