import '../../../core/money/cents.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/stokvel_models.dart';
import '../domain/stokvel_repository.dart';
import 'demo_stokvels.dart';
import 'demo_cycles.dart';

class FakeStokvelRepository implements StokvelRepository {
  @override
  List<Stokvel> getStokvelsForUser(String userId) {
    final memberships = demoMemberships[userId] ?? [];

    return List.unmodifiable(
      demoStokvels.where(
        (stokvel) =>
            memberships.any((membership) => membership.stokvelId == stokvel.id),
      ),
    );
  }

  @override
  Cycle? getActiveCycle({required String userId, required String stokvelId}) {
    if (getDetails(userId: userId, stokvelId: stokvelId) == null) {
      return null;
    }

    return demoCycles
        .where(
          (cycle) =>
              cycle.stokvelId == stokvelId &&
              cycle.status == CycleStatus.active,
        )
        .firstOrNull;
  }

  @override
  Cycle? getCycle({
    required String userId,
    required String stokvelId,
    required String cycleId,
  }) {
    final details = getDetails(userId: userId, stokvelId: stokvelId);

    if (details == null) return null;

    return demoCycles
        .where((cycle) => cycle.id == cycleId && cycle.stokvelId == stokvelId)
        .firstOrNull;
  }

  @override
  StokvelDetails? getDetails({
    required String userId,
    required String stokvelId,
  }) {
    final membership = (demoMemberships[userId] ?? [])
        .where((item) => item.stokvelId == stokvelId)
        .firstOrNull;

    if (membership == null) return null;

    final stokvel = demoStokvels
        .where((item) => item.id == stokvelId)
        .firstOrNull;

    if (stokvel == null) return null;

    final canViewAll = switch (membership.role) {
      StokvelRole.treasurer => true,
      StokvelRole.chairperson => true,
      StokvelRole.member => false,
      StokvelRole.unknown => false,
    };

    final visibleContributions = demoContributions.where((item) {
      if (item.stokvelId != stokvelId) return false;
      return canViewAll || item.memberId == userId;
    }).toList();

    final paidTotal = visibleContributions
        .where((item) => item.status == ContributionStatus.paid)
        .fold<Cents>(const Cents(0), (total, item) => total + item.amountCents);

    return StokvelDetails(
      stokvel: stokvel,
      membership: membership,
      visibleContributions: List.unmodifiable(visibleContributions),
      visiblePaidTotalCents: paidTotal,
    );
  }
}

final stokvelRepositoryProvider = Provider<StokvelRepository>(
  (ref) => FakeStokvelRepository(),
);
