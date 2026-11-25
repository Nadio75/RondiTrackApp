import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../../home/domain/offline_home_provider.dart';
import '../../session/presentation/session_provider.dart';
import '../../session/presentation/session_origin_provider.dart';

class JoinStokvelScreen extends ConsumerStatefulWidget {
  const JoinStokvelScreen({super.key});

  @override
  ConsumerState<JoinStokvelScreen> createState() => _JoinStokvelScreenState();
}

class _JoinStokvelScreenState extends ConsumerState<JoinStokvelScreen> {
  final _controller = TextEditingController();

  Map<String, dynamic>? _preview;
  String? _previewCode;
  String? _error;
  bool _busy = false;
  CancelToken? _token;

  String tr(String en, String nso) =>
      Localizations.localeOf(context).languageCode == 'nso' ? nso : en;

  bool _current(String account, int generation) =>
      mounted &&
      ref.read(sessionProvider)?.id == account &&
      ref.read(sessionOriginProvider) == SessionOrigin.api &&
      ref.read(apiAuthClientProvider).sessionGeneration == generation &&
      ref.read(apiAuthClientProvider).isAuthenticated;

  @override
  void dispose() {
    _token?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _request({required bool join}) async {
    if (_busy) return;

    final account = ref.read(sessionProvider)?.id;
    final auth = ref.read(apiAuthClientProvider);
    final generation = auth.sessionGeneration;

    if (account == null || !_current(account, generation)) {
      return;
    }

    final code = _controller.text.trim();

    if (!RegExp(r'^[A-Za-z0-9_-]{1,128}$').hasMatch(code)) {
      setState(() {
        _preview = null;
        _previewCode = null;
        _error = tr(
          'Enter a valid invitation code.',
          'Tsenya khoutu ya memo ya maleba.',
        );
      });
      return;
    }

    if (join && (_preview == null || _previewCode != code)) {
      return;
    }

    final token = CancelToken();
    _token = token;

    setState(() {
      _busy = true;
      _error = null;
      if (!join) {
        _preview = null;
        _previewCode = null;
      }
    });

    try {
      final dio = ref.read(dioProvider);
      final path = '/api/v1/invites/${Uri.encodeComponent(code)}';

      final options = Options(
        extra: {'requiredAuthSessionGeneration': generation},
      );

      if (join) {
        final response = await dio.post<Map<String, dynamic>>(
          '$path/join',
          cancelToken: token,
          options: options,
        );

        if (!mounted || !_current(account, generation)) return;

        final id = response.data?['stokvelId'];

        if (response.statusCode != 200 ||
            id is! String ||
            id != _preview?['stokvelId']) {
          throw const FormatException('Invalid join response');
        }

        ref.invalidate(authenticatedHomeProvider);
        Navigator.of(context).pop(id);
      } else {
        final response = await dio.get<Map<String, dynamic>>(
          path,
          cancelToken: token,
          options: options,
        );

        if (!_current(account, generation)) return;

        final data = response.data;
        final amount = data?['contributionAmount'];

        if (data == null ||
            data['stokvelId'] is! String ||
            data['name'] is! String ||
            amount is! num ||
            !amount.isFinite ||
            amount <= 0) {
          throw const FormatException('Invalid invitation preview');
        }

        setState(() {
          _preview = data;
          _previewCode = code;
        });
      }
    } on DioException catch (error) {
      if (!_current(account, generation)) return;

      setState(() {
        _error = switch (error.response?.statusCode) {
          404 => tr(
            'This invitation is invalid or has expired.',
            'Memo ye ga e sa soma.',
          ),
          409 => tr(
            'You already belong to this stokvel.',
            'O setse o le leloko la stokvel ye.',
          ),
          401 || 403 => tr('Please sign in again.', 'Tsena gape.'),
          _ => tr(
            'Unable to complete the request. Try again.',
            'Ga re kgone go fetisa kgopelo. Leka gape.',
          ),
        };

        if (error.response?.statusCode == 404) {
          _preview = null;
          _previewCode = null;
        }
      });

      if (join && error.response?.statusCode == 409) {
        ref.invalidate(authenticatedHomeProvider);
      }
    } catch (_) {
      if (!_current(account, generation)) return;

      setState(() {
        _error = tr('Unable to confirm the request. Try again.', 'Leka gape.');
      });
    } finally {
      if (_current(account, generation)) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(sessionProvider);
    final origin = ref.watch(sessionOriginProvider);

    if (user == null || origin != SessionOrigin.api) {
      return Scaffold(
        body: Center(child: Text(tr('Please sign in.', 'Tsena.'))),
      );
    }

    final preview = _preview;

    return PopScope(
      canPop: !_busy,
      child: Scaffold(
        appBar: AppBar(title: Text(tr('Join stokvel', 'Tsena stokvel'))),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  tr(
                    'Enter the invitation code shared with you.',
                    'Tsenya khoutu ya memo.',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  key: const Key('join_invitation_code'),
                  controller: _controller,
                  enabled: !_busy,
                  maxLength: 128,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    labelText: tr('Invitation code', 'Khoutu ya memo'),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.vpn_key_outlined),
                  ),
                  onChanged: (_) {
                    setState(() {
                      _preview = null;
                      _previewCode = null;
                      _error = null;
                    });
                  },
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  key: const Key('preview_invitation'),
                  onPressed: _busy ? null : () => _request(join: false),
                  icon: const Icon(Icons.search),
                  label: Text(tr('Find stokvel', 'Hwetša stokvel')),
                ),
                if (_busy) ...[
                  const SizedBox(height: 16),
                  const LinearProgressIndicator(),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
                if (preview != null) ...[
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            preview['name'] as String,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 16),
                          Text(tr('Monthly contribution', 'Moneelo wa kgwedi')),
                          Text(
                            'R ${(preview['contributionAmount'] as num).toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            tr(
                              'Members: ${preview['memberCount']}',
                              'Maloko: ${preview['memberCount']}',
                            ),
                          ),
                          Text(
                            tr(
                              'Monthly closing day: ${preview['closingDayOfMonth']}',
                              'Letsatsi la go tswalela: ${preview['closingDayOfMonth']}',
                            ),
                          ),
                          const Divider(),
                          Text(tr('Stokvel rules', 'Melao')),
                          Text(preview['rules']?.toString() ?? ''),
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            key: const Key('accept_invitation'),
                            onPressed: _busy
                                ? null
                                : () => _request(join: true),
                            icon: const Icon(Icons.group_add),
                            label: Text(
                              tr('Accept invitation and join', 'Amogela memo'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
