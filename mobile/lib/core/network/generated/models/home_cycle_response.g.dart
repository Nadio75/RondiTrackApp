// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_cycle_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomeCycleResponse _$HomeCycleResponseFromJson(Map<String, dynamic> json) =>
    HomeCycleResponse(
      cycleId: json['cycleId'] as String,
      period: json['period'] as String,
      status: json['status'] as String,
      hasPaid: json['hasPaid'] as bool,
      amountOwed: json['amountOwed'] as String,
      nextPayoutDate: json['nextPayoutDate'] == null
          ? null
          : DateTime.parse(json['nextPayoutDate'] as String),
      paidCents: json['paidCents'],
      owedCents: json['owedCents'],
      dueAtUtc: json['dueAtUtc'] == null
          ? null
          : DateTime.parse(json['dueAtUtc'] as String),
    );

Map<String, dynamic> _$HomeCycleResponseToJson(HomeCycleResponse instance) =>
    <String, dynamic>{
      'cycleId': instance.cycleId,
      'period': instance.period,
      'status': instance.status,
      'hasPaid': instance.hasPaid,
      'amountOwed': instance.amountOwed,
      'nextPayoutDate': instance.nextPayoutDate?.toIso8601String(),
      'paidCents': instance.paidCents,
      'owedCents': instance.owedCents,
      'dueAtUtc': instance.dueAtUtc?.toIso8601String(),
    };
