import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../stokvel/data/fake_stokvel_repository.dart';
import '../../stokvel/domain/stokvel_models.dart';

class HomeStokvelsNotifier extends AsyncNotifier<List<Stokvel>> {
  HomeStokvelsNotifier(this.userId);

  final String userId;

  @override
  Future<List<Stokvel>> build() async {
    final repository = ref.watch(stokvelRepositoryProvider);
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return repository.getStokvelsForUser(userId);
  }
}

final homeStokvelsProvider = AsyncNotifierProvider.autoDispose
    .family<HomeStokvelsNotifier, List<Stokvel>, String>(
      HomeStokvelsNotifier.new,
    );
