// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_payout_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdatePayoutRequest _$UpdatePayoutRequestFromJson(Map<String, dynamic> json) =>
    UpdatePayoutRequest(
      amount: (json['amount'] as num).toDouble(),
      version: json['version'],
    );

Map<String, dynamic> _$UpdatePayoutRequestToJson(
  UpdatePayoutRequest instance,
) => <String, dynamic>{'amount': instance.amount, 'version': instance.version};
