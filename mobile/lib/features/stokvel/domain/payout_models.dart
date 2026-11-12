import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/money/cents.dart';

part 'payout_models.freezed.dart';

enum PayoutStatus { paid, next, upcoming, unknown }

@freezed
abstract class PayoutRotationEntry with _$PayoutRotationEntry {
  const factory PayoutRotationEntry({
    required String memberId,
    required String memberName,
    required int position,
    required Cents amountCents,
    required DateTime? scheduledDate,
    required PayoutStatus status,
    required bool isNext,
  }) = _PayoutRotationEntry;
}

@freezed
abstract class PayoutRotation with _$PayoutRotation {
  const factory PayoutRotation({
    required String stokvelId,
    required String cycleId,
    required List<PayoutRotationEntry> entries,
  }) = _PayoutRotation;
}
