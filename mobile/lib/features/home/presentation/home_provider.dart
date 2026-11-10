import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../stokvel/data/fake_stokvel_repository.dart';
import '../../stokvel/domain/stokvel_models.dart';

final homeStokvelsProvider = FutureProvider.autoDispose
    .family<List<Stokvel>, String>((ref, userId) async {
      final repository = ref.watch(stokvelRepositoryProvider);

      // Simulates network latency while using dummy data.
      await Future<void>.delayed(const Duration(milliseconds: 400));

      return repository.getStokvelsForUser(userId);
    });
