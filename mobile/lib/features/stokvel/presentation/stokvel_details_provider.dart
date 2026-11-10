import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../session/presentation/session_provider.dart';
import '../data/fake_stokvel_repository.dart';
import '../domain/stokvel_repository.dart';

class StokvelDetailsNotifier extends AsyncNotifier<StokvelDetails?> {
  StokvelDetailsNotifier(this.stokvelId);

  final String stokvelId;

  @override
  Future<StokvelDetails?> build() async {
    final user = ref.watch(sessionProvider);
    if (user == null) {
      return null;
    }
    final repository = ref.watch(stokvelRepositoryProvider);
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return repository.getDetails(userId: user.id, stokvelId: stokvelId);
  }
}

final stokvelDetailsProvider = AsyncNotifierProvider.autoDispose
    .family<StokvelDetailsNotifier, StokvelDetails?, String>(
      StokvelDetailsNotifier.new,
    );
