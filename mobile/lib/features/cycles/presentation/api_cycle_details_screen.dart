import '../../contributions/presentation/proof_upload_panel.dart';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../../../core/notifications/local_notification_provider.dart';
import '../../session/presentation/session_provider.dart';
import '../../session/presentation/session_origin_provider.dart';

typedef CycleDetailsKey = ({String stokvelId, String cycleId});

final apiCycleDetailsProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, CycleDetailsKey>((ref, key) async {
      final user = ref.watch(sessionProvider);
      final origin = ref.watch(sessionOriginProvider);

      ref.watch(notificationRefreshProvider);

      if (user == null || origin != SessionOrigin.api) {
        throw StateError('Authentication required.');
      }

      final guid = RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
      );

      if (!guid.hasMatch(key.stokvelId) || !guid.hasMatch(key.cycleId)) {
        throw StateError('Invalid cycle identifiers.');
      }

      final auth = ref.watch(apiAuthClientProvider);
      final dio = ref.watch(dioProvider);
      final generation = auth.sessionGeneration;

      final cancelToken = CancelToken();

      ref.onDispose(() {
        cancelToken.cancel();
      });

      final options = Options(
        extra: {'requiredAuthSessionGeneration': generation},
      );

      final path = '/api/v1/stokvels/${key.stokvelId}/cycles/${key.cycleId}';

      final cycle = await dio.get<Map<String, dynamic>>(
        path,
        options: options,
        cancelToken: cancelToken,
      );

      final contribution = await dio.get<Map<String, dynamic>>(
        '$path/my-contribution',
        options: options,
        cancelToken: cancelToken,
      );

      if (cancelToken.isCancelled ||
          !auth.isAuthenticated ||
          auth.sessionGeneration != generation) {
        throw StateError('Session changed.');
      }

      final cycleData = cycle.data;

      if (cycleData == null ||
          cycleData['id'] != key.cycleId ||
          cycleData['stokvelId'] != key.stokvelId) {
        throw StateError('Invalid cycle response.');
      }

      return {
        'cycle': cycleData,
        'contribution': contribution.data?['contribution'],
      };
    });

class ApiCycleDetailsScreen extends ConsumerWidget {
  const ApiCycleDetailsScreen({
    super.key,
    required this.stokvelId,
    required this.cycleId,
  });

  final String stokvelId;
  final String cycleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = (stokvelId: stokvelId, cycleId: cycleId);

    final provider = apiCycleDetailsProvider(key);
    final details = ref.watch(provider);

    final nso = Localizations.localeOf(context).languageCode == 'nso';

    return Scaffold(
      appBar: AppBar(
        title: Text(nso ? 'Dintlha tsa modikologo' : 'Cycle details'),
        actions: [
          IconButton(
            tooltip: nso ? 'Mpshafatsa' : 'Refresh',
            onPressed: () => ref.invalidate(provider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: details.when(
        skipLoadingOnRefresh: false,
        skipLoadingOnReload: false,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          final status = error is DioException
              ? error.response?.statusCode
              : null;

          final unavailable = status == 403 || status == 404;

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.info_outline, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    unavailable
                        ? (nso
                              ? 'Modikologo ga o hwetagale.'
                              : 'This cycle is unavailable.')
                        : (nso
                              ? 'Dintlha ga di hwetagale.'
                              : 'Unable to load cycle details.'),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => ref.invalidate(provider),
                    child: Text(nso ? 'Leka gape' : 'Try again'),
                  ),
                ],
              ),
            ),
          );
        },
        data: (data) {
          final cycle = data['cycle'] as Map<String, dynamic>;

          final contribution = data['contribution'] as Map<String, dynamic>?;

          final confirmed = contribution?['isConfirmed'] == true;

          final amount = contribution?['amount'];

          final status = contribution == null
              ? (nso ? 'Ga go na moneelo' : 'No contribution recorded')
              : confirmed
              ? (nso ? 'E netefaditswe' : 'Confirmed')
              : (nso ? 'E emetse netefatso' : 'Awaiting confirmation');

          return RefreshIndicator(
            onRefresh: () async {
              try {
                ref.invalidate(provider);
                await ref.read(provider.future);
              } catch (_) {
                // The provider displays the error state.
              }
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${cycle['period']}',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          cycle['isClosed'] == true
                              ? (nso ? 'E tswaletswe' : 'Closed')
                              : (nso ? 'E bulegile' : 'Open'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          confirmed
                              ? Icons.check_circle_outline
                              : Icons.schedule,
                          size: 40,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          nso ? 'Moneelo wa gago' : 'Your contribution',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        if (amount is num)
                          Text(
                            'R ${amount.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        const SizedBox(height: 8),
                        Text(status),
                      ],
                    ),
                  ),
                ),
                if (contribution?['id'] is String) ...[
                  const SizedBox(height: 16),
                  ProofUploadPanel(
                    key: ValueKey(
                      '${ref.watch(sessionProvider)?.id}:'
                      '${ref.watch(apiAuthClientProvider).sessionGeneration}:'
                      '${contribution!['id']}',
                    ),
                    stokvelId: stokvelId,
                    contributionId: contribution['id'] as String,
                    isClosed: cycle['isClosed'] == true,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
