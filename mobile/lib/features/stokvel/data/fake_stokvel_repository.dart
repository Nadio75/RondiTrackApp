import '../../../core/money/cents.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/stokvel_models.dart';
import '../domain/stokvel_repository.dart';
import 'demo_stokvels.dart';

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
