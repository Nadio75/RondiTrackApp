import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';

class ManageMembersScreen extends ConsumerStatefulWidget {
  const ManageMembersScreen({
    super.key,
    required this.stokvelId,
    required this.stokvelName,
    required this.accountId,
    required this.canManage,
    required this.isSessionCurrent,
    required this.authGeneration,
  });

  final String stokvelId;
  final String stokvelName;
  final String accountId;
  final bool canManage;
  final bool Function() isSessionCurrent;
  final int authGeneration;

  @override
  ConsumerState<ManageMembersScreen> createState() =>
      _ManageMembersScreenState();
}

class _ManageMembersScreenState extends ConsumerState<ManageMembersScreen> {
  List<Map<String, dynamic>> _members = [];
  bool _loading = true;
  bool _busy = false;
  String? _error;
  CancelToken? _token;

  String get _path => '/api/v1/stokvels/${widget.stokvelId}/members';

  bool get _current => mounted && widget.isSessionCurrent();

  Options get _options =>
      Options(extra: {'requiredAuthSessionGeneration': widget.authGeneration});

  String tr(String en, String nso) =>
      Localizations.localeOf(context).languageCode == 'nso' ? nso : en;

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

  Future<void> _load() async {
    if (!_current || _busy) return;

    _token?.cancel();
    final token = CancelToken();
    _token = token;

    setState(() {
      _loading = true;
      _error = null;
      _members = [];
    });

    try {
      final members = <Map<String, dynamic>>[];
      final seenTokens = <String>{};
      String? next;

      do {
        final response = await ref
            .read(dioProvider)
            .get<Map<String, dynamic>>(
              _path,
              queryParameters: {'page_size': 100, 'page_token': ?next},
              options: _options,
              cancelToken: token,
            );

        if (!_current || token.isCancelled) return;

        final data = response.data;
        final items = data?['items'];

        if (items is! List) {
          throw const FormatException('Invalid member list');
        }

        for (final item in items) {
          if (item is! Map<String, dynamic> ||
              item['userId'] is! String ||
              item['name'] is! String ||
              item['role'] is! String) {
            throw const FormatException('Invalid member');
          }

          members.add(item);
        }

        final rawToken = data?['nextPageToken'];

        if (rawToken != null && rawToken is! String) {
          throw const FormatException('Invalid page token');
        }

        next = rawToken as String?;

        if (next != null && next.isNotEmpty && !seenTokens.add(next)) {
          throw const FormatException('Repeated page token');
        }
      } while (next != null && next.isNotEmpty);

      if (!_current || token.isCancelled) return;

      setState(() => _members = members);
    } catch (_) {
      if (!_current || token.isCancelled) return;

      setState(() {
        _error = tr(
          'Unable to load members. Try again.',
          'Ga re kgone go hwetÃ…Â¡a maloko.',
        );
      });
    } finally {
      if (_current && !token.isCancelled) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _changeRole(Map<String, dynamic> member) async {
    if (!_current || _busy || _loading || !widget.canManage) return;

    final id = member['userId'] as String;
    final name = member['name'] as String;
    final role = member['role'] as String;

    if (id == widget.accountId || (role != 'Member' && role != 'Treasurer')) {
      return;
    }

    final nextRole = role == 'Treasurer' ? 'Member' : 'Treasurer';

    setState(() => _busy = true);

    var changed = false;

    try {
      final approved = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(tr('Change membership role?', 'Fetola maemo?')),
          content: Text('$name: $role to $nextRole'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(tr('Cancel', 'Khansela')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(tr('Confirm', 'NetefatÃ…Â¡a')),
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
          .put<void>(
            '$_path/$id/role',
            data: {'role': nextRole},
            options: _options,
            cancelToken: token,
          );

      if (!mounted || !_current) return;

      if (response.statusCode != 204) {
        throw const FormatException('Unexpected response');
      }

      changed = true;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('Membership role updated.', 'Maemo a fetotÃ…Â¡we.')),
        ),
      );
    } on DioException catch (error) {
      if (!_current) return;

      setState(() {
        _error = switch (error.response?.statusCode) {
          401 || 403 => tr(
            'You do not have permission to change roles.',
            'Ga o na tumelelo.',
          ),
          404 => tr(
            'Membership no longer exists.',
            'Leloko ga le sa hwetÃ…Â¡agala.',
          ),
          409 => tr(
            'This membership role is protected.',
            'Maemo a Ã…Â¡ireleditÃ…Â¡we.',
          ),
          _ => tr(
            'Unable to update the role. Refresh and try again.',
            'Leka gape.',
          ),
        };
      });
    } catch (_) {
      if (!_current) return;

      setState(() {
        _error = tr(
          'Unable to update the role.',
          'Ga re kgone go fetola maemo.',
        );
      });
    } finally {
      if (_current) {
        setState(() => _busy = false);

        if (changed) {
          await _load();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_current) {
      return Scaffold(
        body: Center(child: Text(tr('Please sign in again.', 'Tsena gape.'))),
      );
    }

    return PopScope(
      canPop: !_busy,
      child: Scaffold(
        appBar: AppBar(
          title: Text(tr('Manage members', 'Laola maloko')),
          actions: [
            IconButton(
              onPressed: _busy || _loading ? null : _load,
              icon: const Icon(Icons.refresh),
              tooltip: tr('Refresh', 'MpshafatÃ…Â¡a'),
            ),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    widget.stokvelName,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tr(
                      '${_members.length} members',
                      '${_members.length} maloko',
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_loading || _busy) const LinearProgressIndicator(),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        _error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  for (final member in _members)
                    Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Icon(
                            member['role'] == 'Chairperson'
                                ? Icons.admin_panel_settings
                                : member['role'] == 'Treasurer'
                                ? Icons.account_balance_wallet
                                : Icons.person_outline,
                          ),
                        ),
                        title: Text(member['name'] as String),
                        subtitle: Text(member['role'] as String),
                        trailing:
                            widget.canManage &&
                                member['userId'] != widget.accountId &&
                                (member['role'] == 'Member' ||
                                    member['role'] == 'Treasurer')
                            ? IconButton(
                                key: Key('change_role_${member['userId']}'),
                                tooltip: member['role'] == 'Member'
                                    ? tr(
                                        'Appoint treasurer',
                                        'Kgetha ramatlotlo',
                                      )
                                    : tr(
                                        'Change to member',
                                        'Fetola go leloko',
                                      ),
                                onPressed: _busy || _loading
                                    ? null
                                    : () => _changeRole(member),
                                icon: const Icon(Icons.manage_accounts),
                              )
                            : member['role'] == 'Chairperson'
                            ? const Icon(Icons.lock_outline)
                            : null,
                      ),
                    ),
                  if (!_loading && _error == null && _members.isEmpty)
                    Text(tr('No members found.', 'Ga go maloko.')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
