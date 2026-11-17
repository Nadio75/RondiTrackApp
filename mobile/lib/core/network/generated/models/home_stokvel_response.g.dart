// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_stokvel_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomeStokvelResponse _$HomeStokvelResponseFromJson(Map<String, dynamic> json) =>
    HomeStokvelResponse(
      stokvelId: json['stokvelId'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      contributionAmount: json['contributionAmount'] as String,
      currentCycle: json['currentCycle'] == null
          ? null
          : HomeCycleResponse.fromJson(
              json['currentCycle'] as Map<String, dynamic>,
            ),
      contributionAmountCents: json['contributionAmountCents'],
      personalArrearsCents: json['personalArrearsCents'],
    );

Map<String, dynamic> _$HomeStokvelResponseToJson(
  HomeStokvelResponse instance,
) => <String, dynamic>{
  'stokvelId': instance.stokvelId,
  'name': instance.name,
  'role': instance.role,
  'contributionAmount': instance.contributionAmount,
  'currentCycle': instance.currentCycle,
  'contributionAmountCents': instance.contributionAmountCents,
  'personalArrearsCents': instance.personalArrearsCents,
};
