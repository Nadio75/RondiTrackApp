import '../../../core/money/cents.dart';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'stokvel_models.freezed.dart';

enum StokvelRole { member, treasurer, chairperson, unknown }

enum CycleStatus { upcoming, active, closed, unknown }

enum ContributionStatus { pending, paid, overdue, unknown }

@freezed
abstract class Membership with _$Membership {
  const factory Membership({
    required String stokvelId,
    required StokvelRole role,
  }) = _Membership;
}

@freezed
abstract class Stokvel with _$Stokvel {
  const factory Stokvel({
    required String id,
    required String name,
    required String description,
    required Cents monthlyContributionCents,
  }) = _Stokvel;
}

@freezed
abstract class Contribution with _$Contribution {
  const factory Contribution({
    required String id,
    required String stokvelId,
    required String memberId,
    required Cents amountCents,
    required ContributionStatus status,
  }) = _Contribution;
}

@freezed
abstract class Cycle with _$Cycle {
  const factory Cycle({
    required String id,
    required String stokvelId,
    required CycleStatus status,
    required DateTime startDate,
    required DateTime endDate,
  }) = _Cycle;
}
