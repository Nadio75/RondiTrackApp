import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/dio_provider.dart';
import '../network/generated/rest_client.dart';
import 'app_database.dart';
import 'home_cache_repository.dart';
import 'offline_home_service.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();

  ref.onDispose(database.close);

  return database;
});

final homeCacheRepositoryProvider = Provider<HomeCacheRepository>((ref) {
  return HomeCacheRepository(ref.watch(appDatabaseProvider));
});

final offlineHomeServiceProvider = Provider<OfflineHomeService>((ref) {
  final dio = ref.watch(dioProvider);
  final cache = ref.watch(homeCacheRepositoryProvider);

  return OfflineHomeService(client: RestClient(dio).me, cache: cache);
});
