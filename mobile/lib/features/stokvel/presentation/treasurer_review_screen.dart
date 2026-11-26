import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../../session/presentation/session_provider.dart';
import '../../session/presentation/session_origin_provider.dart';

class TreasurerReviewScreen extends ConsumerStatefulWidget {
  const TreasurerReviewScreen({
    super.key,
    required this.stokvelId,
    required this.stokvelName,
    required this.accountId,
    required this.authGeneration,
    required this.isSessionCurrent,
  });

  final String stokvelId;
  final String stokvelName;
  final String accountId;
  final int authGeneration;
  final bool Function() isSessionCurrent;

  @override
  ConsumerState<TreasurerReviewScreen> createState() =>
      _TreasurerReviewScreenState();
}

class _TreasurerReviewScreenState extends ConsumerState<TreasurerReviewScreen> {
  List<Map<String, dynamic>> _items = [];
  Map<String, String> _periods = {};
  String? _nextPage;
  String? _error;
  bool _loading = true;
  bool _busy = false;
  CancelToken? _token;

  String get _path => '/api/v1/stokvels/${widget.stokvelId}';

  String tr(String en, String nso) =>
      Localizations.localeOf(context).languageCode == 'nso' ? nso : en;

  bool get _current =>
      mounted &&
      widget.isSessionCurrent() &&
      ref.read(sessionProvider)?.id == widget.accountId &&
      ref.read(sessionOriginProvider) == SessionOrigin.api &&
      ref.read(apiAuthClientProvider).isAuthenticated &&
      ref.read(apiAuthClientProvider).sessionGeneration ==
          widget.authGeneration;

  Options get _options =>
      Options(extra: {'requiredAuthSessionGeneration': widget.authGeneration});

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  @override
  void dispose() {
    _token?.cancel();
    super.dispose();
  }

  Future<void> _load({bool append = false}) async {
    if (_busy) return;
    if (!_current) return;
    if (append && (_loading || _nextPage == null)) return;

    final page = append ? _nextPage : null;

    _token?.cancel();
    final token = CancelToken();
    _token = token;

    setState(() {
      _loading = true;
      _error = null;

      if (!append) {
        _items = [];
        _nextPage = null;
      }
    });

    try {
      final dio = ref.read(dioProvider);

      final cycles = await dio.get<List<dynamic>>(
        '$_path/cycles',
        options: _options,
        cancelToken: token,
      );

      if (!_current || token.isCancelled) return;

      final periods = <String, String>{};

      for (final item in cycles.data ?? []) {
        if (item is Map && item['id'] is String && item['period'] is String) {
          periods[item['id'] as String] = item['period'] as String;
        }
      }

      final response = await dio.get<Map<String, dynamic>>(
        '$_path/contributions',
        queryParameters: {'pageSize': 20, 'sort': 'newest', 'pageToken': ?page},
        options: _options,
        cancelToken: token,
      );

      if (!_current || token.isCancelled) return;

      final raw = response.data?['items'];

      if (raw is! List) {
        throw const FormatException('Invalid contribution list');
      }

      final items = <Map<String, dynamic>>[];

      for (final value in raw) {
        if (value is! Map ||
            value['id'] is! String ||
            value['stokvelId'] != widget.stokvelId ||
            value['memberName'] is! String ||
            value['amount'] is! num ||
            value['contributionCycleId'] is! String ||
            value['isConfirmed'] is! bool) {
          throw const FormatException('Invalid contribution');
        }

        items.add(Map<String, dynamic>.from(value));
      }

      final next = response.data?['nextPageToken'];

      setState(() {
        _periods = periods;
        final combined = <String, Map<String, dynamic>>{
          for (final item in _items) item['id'] as String: item,
          for (final item in items) item['id'] as String: item,
        };
        _items = combined.values.toList();
        _nextPage = next is String && next.isNotEmpty ? next : null;
      });
    } on DioException catch (error) {
      if (!_current || token.isCancelled) return;

      setState(() {
        _error = switch (error.response?.statusCode) {
          401 || 403 => tr('Access denied.', 'Ga o na tumelelo.'),
          404 => tr('Stokvel not available.', 'Stokvel ga e hwetagale.'),
          _ => tr(
            'Unable to load contributions.',
            'Ga re kgone go laetsha meneelo.',
          ),
        };
      });
    } catch (_) {
      if (!_current || token.isCancelled) return;

      setState(() {
        _error = tr(
          'Unable to load contributions.',
          'Ga re kgone go laetsha meneelo.',
        );
      });
    } finally {
      if (_current && !token.isCancelled) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(sessionProvider);
    ref.watch(sessionOriginProvider);

    if (!_current) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(tr('Please sign in again.', 'Tsena gape.'))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('Review contributions', 'Lekola meneelo')),
        actions: [
          IconButton(
            onPressed: _loading ? null : () => _load(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _load(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              widget.stokvelName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            if (_loading || _busy) const LinearProgressIndicator(),
            if (_error != null)
              Card(
                child: ListTile(
                  title: Text(_error!),
                  trailing: IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => _load(),
                  ),
                ),
              ),
            if (!_loading && _error == null && _items.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  tr('No contributions recorded yet.', 'Ga go na meneelo.'),
                ),
              ),
            for (final item in _items) _contributionCard(item),
            if (_nextPage != null)
              OutlinedButton(
                onPressed: _loading ? null : () => _load(append: true),
                child: Text(tr('Load more', 'Bona tse dingwe')),
              ),
          ],
        ),
      ),
    );
  }

  void _notice(String message) {
    if (!_current) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _reviewProof(Map<String, dynamic> item) async {
    if (!_current || _busy || _loading) return;

    final id = item['id'] as String;
    final token = CancelToken();
    _token = token;

    setState(() => _busy = true);

    var shouldConfirm = false;

    try {
      final response = await ref
          .read(dioProvider)
          .get<List<int>>(
            '$_path/contributions/$id/proof',
            cancelToken: token,
            options: Options(
              responseType: ResponseType.bytes,
              extra: {'requiredAuthSessionGeneration': widget.authGeneration},
            ),
          );

      if (!mounted || !_current) return;

      final bytes = response.data;
      final contentType = response.headers
          .value('content-type')
          ?.split(';')
          .first
          .trim()
          .toLowerCase();

      if (bytes == null || bytes.isEmpty || bytes.length > 5 * 1024 * 1024) {
        throw const FormatException('Invalid receipt');
      }

      if (contentType != 'image/jpeg' && contentType != 'image/png') {
        _notice(
          tr(
            'This receipt format cannot be previewed.',
            'Seswantsho ga se kgone go bulwa.',
          ),
        );
        return;
      }

      final image = Uint8List.fromList(bytes);

      final approved = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(tr('Proof of payment', 'Bohlatse bja tefelo')),
          content: SizedBox(
            width: 600,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(item['memberName'] as String),
                  Text(
                    'R ${(item['amount'] as num).toStringAsFixed(2)}',
                    style: Theme.of(dialogContext).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 320,
                    child: InteractiveViewer(
                      minScale: 1,
                      maxScale: 5,
                      child: Image.memory(
                        image,
                        fit: BoxFit.contain,
                        errorBuilder: (_, error, stackTrace) => const Center(
                          child: Text('Unable to display receipt.'),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    tr(
                      'Verify the receipt against the actual payment.',
                      'Netefatsa bohlatse bja tefelo.',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(tr('Close', 'Tswalela')),
            ),
            if (item['isConfirmed'] != true)
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(tr('Continue to confirmation', 'Tswela pele')),
              ),
          ],
        ),
      );

      if (!mounted || !_current) return;

      shouldConfirm = approved == true;
    } on DioException catch (error) {
      if (!_current) return;

      _notice(switch (error.response?.statusCode) {
        404 => tr(
          'No accessible proof of payment found.',
          'Bohlatse ga bo hwetagale.',
        ),
        401 || 403 => tr(
          'You do not have permission to view this receipt.',
          'Ga o na tumelelo.',
        ),
        _ => tr('Unable to retrieve receipt. Try again.', 'Leka gape.'),
      });
    } catch (_) {
      if (!_current) return;

      _notice(
        tr('Unable to display the receipt.', 'Bohlatse ga bo kgone go bulwa.'),
      );
    } finally {
      if (_current) {
        setState(() => _busy = false);
      }
    }

    if (_current && shouldConfirm) {
      await _confirmContribution(item);
    }
  }

  Future<void> _confirmContribution(Map<String, dynamic> item) async {
    if (!_current || _busy || _loading || item['isConfirmed'] == true) {
      return;
    }

    final id = item['id'] as String;
    final amount = (item['amount'] as num).toStringAsFixed(2);
    final name = item['memberName'] as String;

    setState(() => _busy = true);

    var refresh = false;

    try {
      final approved = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(Icons.verified_outlined),
          title: Text(tr('Confirm contribution?', 'Netefatsa moneelo?')),
          content: Text(
            '$name\nR $amount\n\n'
            'Only confirm if you have verified '
            'that the payment was received. '
            'This records the confirmation and '
            'requests a notification to the contributor.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(tr('Cancel', 'Khansela')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(tr('Confirm contribution', 'Netefatsa moneelo')),
            ),
          ],
        ),
      );

      if (!mounted || !_current || approved != true) {
        return;
      }

      final token = CancelToken();
      _token = token;

      final response = await ref
          .read(dioProvider)
          .post<void>(
            '$_path/contributions/$id/confirm',
            options: _options,
            cancelToken: token,
          );

      if (!_current) return;

      if (response.statusCode != 204) {
        throw const FormatException('Unexpected confirmation response');
      }

      refresh = true;

      _notice(
        tr('Contribution confirmed successfully.', 'Moneelo o netefaditswe.'),
      );
    } on DioException catch (error) {
      if (!_current) return;

      refresh = true;

      _notice(switch (error.response?.statusCode) {
        401 || 403 => tr(
          'Only an authorized treasurer can confirm.',
          'Ke ramatlotlo fela.',
        ),
        404 => tr(
          'Contribution is no longer available.',
          'Moneelo ga o hwetagale.',
        ),
        409 => tr(
          'This contribution cannot be confirmed.',
          'Moneelo ga o kgone go netefatswa.',
        ),
        _ => tr(
          'Confirmation could not be verified. Refresh the list.',
          'Leka gape.',
        ),
      });
    } catch (_) {
      if (!_current) return;

      refresh = true;

      _notice(
        tr('Unable to verify confirmation. Refresh the list.', 'Leka gape.'),
      );
    } finally {
      if (_current) {
        setState(() => _busy = false);

        if (refresh) {
          await _load();
        }
      }
    }
  }

  Widget _contributionCard(Map<String, dynamic> item) {
    final confirmed = item['isConfirmed'] == true;
    final amount = (item['amount'] as num).toStringAsFixed(2);
    final period = _periods[item['contributionCycleId']] ?? '-';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(child: Icon(Icons.person_outline)),
              title: Text(item['memberName'] as String),
              subtitle: Text(period),
            ),
            Text('R $amount', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  confirmed ? Icons.check_circle_outline : Icons.schedule,
                  color: confirmed ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    confirmed
                        ? tr('Confirmed', 'Netefaditswe')
                        : tr('Awaiting confirmation', 'E emetse netefatso'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                key: Key('view_proof_${item['id']}'),
                onPressed: _busy || _loading ? null : () => _reviewProof(item),
                icon: const Icon(Icons.image_outlined),
                label: Text(
                  tr('View proof of payment', 'Bona bohlatse bja tefelo'),
                ),
              ),
            ),
            if (!confirmed) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: Key('confirm_${item['id']}'),
                  onPressed: _busy || _loading
                      ? null
                      : () => _reviewProof(item),
                  icon: const Icon(Icons.verified_outlined),
                  label: Text(tr('Review and confirm', 'Lekola o netefatse')),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
