import 'treasurer_review_screen.dart';
import 'manage_members_screen.dart';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../../contributions/presentation/api_contribution_screen.dart';
import '../../home/domain/offline_home_provider.dart';
import '../../session/presentation/session_provider.dart';
import '../../session/presentation/session_origin_provider.dart';

class ApiStokvelManagementScreen extends ConsumerStatefulWidget {
  const ApiStokvelManagementScreen({
    super.key,
    required this.stokvelId,
    required this.stokvelName,
    required this.role,
    required this.accountId,
    required this.sessionGeneration,
  });

  final String stokvelId;
  final String stokvelName;
  final String role;
  final String accountId;
  final int sessionGeneration;

  @override
  ConsumerState<ApiStokvelManagementScreen> createState() =>
      _ApiStokvelManagementScreenState();
}

class _ApiStokvelManagementScreenState
    extends ConsumerState<ApiStokvelManagementScreen> {
  Map<String, dynamic>? _details;
  bool _loading = true;
  bool _busy = false;
  String? _error;
  CancelToken? _cancelToken;

  bool get _chairperson => widget.role.toLowerCase() == 'chairperson';

  bool get _member => widget.role.toLowerCase() == 'member';

  String get _path => '/api/v1/stokvels/${widget.stokvelId}';

  String tr(String en, String nso) =>
      Localizations.localeOf(context).languageCode == 'nso' ? nso : en;

  bool _current(int generation) =>
      mounted &&
      ref.read(sessionProvider)?.id == widget.accountId &&
      ref.read(sessionOriginProvider) == SessionOrigin.api &&
      ref.read(sessionProvider.notifier).sessionGeneration ==
          widget.sessionGeneration &&
      ref.read(apiAuthClientProvider).sessionGeneration == generation &&
      ref.read(apiAuthClientProvider).isAuthenticated;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  @override
  void dispose() {
    _cancelToken?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final generation = ref.read(apiAuthClientProvider).sessionGeneration;

    if (!_current(generation) || _busy) return;

    _cancelToken?.cancel();

    final token = CancelToken();
    _cancelToken = token;

    setState(() {
      _loading = true;
      _error = null;
      _details = null;
    });

    try {
      final response = await ref
          .read(dioProvider)
          .get<Map<String, dynamic>>(
            _path,
            cancelToken: token,
            options: Options(
              extra: {'requiredAuthSessionGeneration': generation},
            ),
          );

      if (!_current(generation) || token.isCancelled) return;

      final details = response.data;

      if (details == null || details['id'] != widget.stokvelId) {
        throw const FormatException('Invalid stokvel details');
      }

      setState(() => _details = details);
    } catch (_) {
      if (!_current(generation) || token.isCancelled) return;

      setState(() {
        _error = tr(
          'Unable to load stokvel details.',
          'Ga re kgone go bula dintlha tsa stokvel.',
        );
      });
    } finally {
      if (_current(generation) && !token.isCancelled) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _inviteMembers() async {
    if (_busy || _loading || _details == null) return;

    if (!_chairperson && widget.role.toLowerCase() != 'treasurer') {
      return;
    }

    final generation = ref.read(apiAuthClientProvider).sessionGeneration;

    if (!_current(generation)) return;

    final token = CancelToken();
    _cancelToken = token;

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final response = await ref
          .read(dioProvider)
          .post<Map<String, dynamic>>(
            '$_path/invites',
            cancelToken: token,
            options: Options(
              extra: {'requiredAuthSessionGeneration': generation},
            ),
          );

      if (!mounted || !_current(generation)) return;

      final data = response.data;
      final code = data?['code'];
      final expiry = data?['expiresAtUtc'];

      if (response.statusCode != 201 ||
          code is! String ||
          code.isEmpty ||
          code.length > 128 ||
          expiry is! String) {
        throw const FormatException('Invalid invitation response');
      }

      final expires = DateTime.tryParse(expiry);

      if (expires == null) {
        throw const FormatException('Invalid invitation expiry');
      }

      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(Icons.group_add_outlined),
          title: Text(tr('Invite members', 'Mema maloko')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(widget.stokvelName),
                const SizedBox(height: 16),
                Text(
                  tr(
                    'Share this invitation code privately with '
                        'the person you want to invite.',
                    'Abelana khoutu ye le motho yo o mo memago.',
                  ),
                ),
                const SizedBox(height: 16),
                SelectableText(
                  code,
                  key: const Key('generated_invitation_code'),
                  textAlign: TextAlign.center,
                  style: Theme.of(dialogContext).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  tr(
                    'Expires: ${expires.toLocal().toString().split(".").first}',
                    'E fela: ${expires.toLocal().toString().split(".").first}',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  tr(
                    'The invitation is valid for seven days. '
                        'Anyone with the code can use it while it is valid.',
                    'Khoutu e soma matshatsi a supago.',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(tr('Close', 'Tswalela')),
            ),
            FilledButton.icon(
              key: const Key('copy_invitation_code'),
              icon: const Icon(Icons.copy),
              label: Text(tr('Copy code', 'Kopisa khoutu')),
              onPressed: () async {
                if (!_current(generation)) return;

                try {
                  await Clipboard.setData(ClipboardData(text: code));

                  if (!mounted || !_current(generation)) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        tr('Invitation code copied.', 'Khoutu e kopisitswe.'),
                      ),
                    ),
                  );
                } catch (_) {
                  if (!mounted || !_current(generation)) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        tr(
                          'Copy failed. Select the code manually.',
                          'Kgetha khoutu ka seatla.',
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      );
    } on DioException catch (error) {
      if (!_current(generation)) return;

      setState(() {
        _error = switch (error.response?.statusCode) {
          401 || 403 => tr(
            'You do not have permission to invite members.',
            'Ga o na tumelelo ya go mema maloko.',
          ),
          404 => tr(
            'This stokvel is no longer available.',
            'Stokvel ga e sa hwetagala.',
          ),
          _ => tr(
            'Unable to generate an invitation. Try again.',
            'Ga re kgone go hlama memo. Leka gape.',
          ),
        };
      });
    } catch (_) {
      if (!_current(generation)) return;

      setState(() {
        _error = tr(
          'Unable to generate an invitation.',
          'Ga re kgone go hlama memo.',
        );
      });
    } finally {
      if (_current(generation)) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _createCycle() async {
    if (_busy || _loading || _details == null) return;

    final allowed = _chairperson || widget.role.toLowerCase() == 'treasurer';

    if (!allowed) return;

    final generation = ref.read(apiAuthClientProvider).sessionGeneration;

    if (!mounted || !_current(generation)) return;

    final amount = _details?['contributionAmount'];
    final members = _details?['memberCount'];
    final closingDay = _details?['closingDayOfMonth'];

    if (amount is! num ||
        !amount.isFinite ||
        amount <= 0 ||
        members is! int ||
        members <= 0) {
      return;
    }

    final target = amount * members;

    final existing = ref
        .read(apiContributionCyclesProvider(widget.stokvelId))
        .asData
        ?.value;

    if (existing == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(
              'Refresh contribution cycles before continuing.',
              'Mpshafatsa medikologo pele o tswela pele.',
            ),
          ),
        ),
      );
      return;
    }

    final usedPeriods = existing.map((c) => c.period).toSet();
    final now = DateTime.now();

    final periods = List.generate(12, (index) {
      final date = DateTime(now.year, now.month + index);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}';
    }).where((period) => !usedPeriods.contains(period)).toList();

    if (periods.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(
              'All available months already have cycles.',
              'Dikgwedi ka moka di na le medikologo.',
            ),
          ),
        ),
      );
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      var selected = periods.first;

      final period = await showDialog<String>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, updateDialog) => AlertDialog(
            title: Text(tr('Create contribution cycle', 'Hlama modikologo')),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(widget.stokvelName),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selected,
                    decoration: InputDecoration(
                      labelText: tr('Contribution month', 'Kgwedi'),
                      border: const OutlineInputBorder(),
                    ),
                    items: periods
                        .map(
                          (period) => DropdownMenuItem(
                            value: period,
                            child: Text(period),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        updateDialog(() => selected = value);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    tr(
                      'Monthly contribution: R ${amount.toStringAsFixed(2)}',
                      'Moneelo: R ${amount.toStringAsFixed(2)}',
                    ),
                  ),
                  Text(tr('Members: $members', 'Maloko: $members')),
                  if (closingDay is int)
                    Text(
                      tr(
                        'Monthly closing day: $closingDay',
                        'Letsatsi la go tswalela: $closingDay',
                      ),
                    ),
                  const Divider(),
                  Text(tr('Total cycle target', 'Palomoka')),
                  Text(
                    'R ${target.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(tr('Cancel', 'Khansela')),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(selected),
                child: Text(tr('Create cycle', 'Hlama modikologo')),
              ),
            ],
          ),
        ),
      );

      if (period == null || !_current(generation)) return;

      final token = CancelToken();
      _cancelToken = token;

      final response = await ref
          .read(dioProvider)
          .post<dynamic>(
            '$_path/cycles',
            data: {'period': period, 'targetAmount': target},
            cancelToken: token,
            options: Options(
              extra: {'requiredAuthSessionGeneration': generation},
            ),
          );

      if (!mounted || !_current(generation)) return;

      if (response.statusCode != 201) {
        throw StateError('Unexpected cycle creation response');
      }

      ref.invalidate(apiContributionCyclesProvider(widget.stokvelId));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr('Contribution cycle created.', 'Modikologo o hlamilwe.'),
          ),
        ),
      );
    } on DioException catch (error) {
      if (!mounted || !_current(generation)) return;

      ref.invalidate(apiContributionCyclesProvider(widget.stokvelId));

      setState(() {
        _error = switch (error.response?.statusCode) {
          409 => tr(
            'A cycle already exists or creation conflicts with existing data.',
            'Modikologo o ka ba o le gona.',
          ),
          401 || 403 => tr(
            'You do not have permission to create cycles.',
            'Ga o na tumelelo.',
          ),
          _ => tr(
            'Cycle creation could not be confirmed. Refresh before retrying.',
            'Mpshafatsa medikologo pele o leka gape.',
          ),
        };
      });
    } catch (_) {
      if (!mounted || !_current(generation)) return;

      ref.invalidate(apiContributionCyclesProvider(widget.stokvelId));

      setState(() {
        _error = tr(
          'Unable to confirm cycle creation. Refresh before retrying.',
          'Mpshafatsa medikologo pele o leka gape.',
        );
      });
    } finally {
      if (_current(generation)) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _remove() async {
    if (_busy || _loading || _details == null) return;
    if (!_chairperson && !_member) return;

    final generation = ref.read(apiAuthClientProvider).sessionGeneration;

    if (!_current(generation)) return;

    setState(() {
      _busy = true;
      _error = null;
    });

    final action = _chairperson
        ? tr('Delete stokvel', 'Phumola stokvel')
        : tr('Leave stokvel', 'Tloga stokvel');

    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(action),
          content: Text(
            _chairperson
                ? tr(
                    'Permanently delete "${widget.stokvelName}"? '
                        'This cannot be undone. Only unused stokvels '
                        'without other members or financial history '
                        'can be deleted.',
                    'O nyaka go phumola stokvel ye?',
                  )
                : tr(
                    'Leave "${widget.stokvelName}"? '
                        'You will lose access to this stokvel. '
                        'Financial restrictions may prevent leaving.',
                    'O nyaka go tloga stokvel ye?',
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(tr('Cancel', 'Khansela')),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(dialogContext).colorScheme.error,
                foregroundColor: Theme.of(dialogContext).colorScheme.onError,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(action),
            ),
          ],
        ),
      );

      if (confirmed != true || !_current(generation)) return;

      final token = CancelToken();
      _cancelToken = token;

      final response = await ref
          .read(dioProvider)
          .delete<void>(
            _chairperson ? _path : '$_path/members/me',
            cancelToken: token,
            options: Options(
              extra: {'requiredAuthSessionGeneration': generation},
            ),
          );

      if (!_current(generation)) return;

      if (response.statusCode != 204) {
        throw StateError('Unexpected removal response');
      }

      ref.invalidate(authenticatedHomeProvider);
      ref.invalidate(apiContributionCyclesProvider(widget.stokvelId));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _chairperson
                ? tr('Stokvel deleted.', 'Stokvel e phumotswe.')
                : tr('You left the stokvel.', 'O tlogile stokvel.'),
          ),
        ),
      );

      Navigator.of(context).pop();
    } on DioException catch (error) {
      if (!_current(generation)) return;

      setState(() {
        _error = switch (error.response?.statusCode) {
          409 => tr(
            'This stokvel cannot be removed because of '
                'membership or financial restrictions.',
            'Stokvel e na le dithibelo tsa maloko goba tshelete.',
          ),
          401 || 403 => tr(
            'You do not have permission for this action.',
            'Ga o na tumelelo.',
          ),
          404 => tr(
            'This stokvel is no longer available.',
            'Stokvel ga e sa hwetagala.',
          ),
          _ => tr(
            'Removal could not be confirmed. '
                'Refresh your stokvel list before retrying.',
            'Lekola lenaneo la distokvel pele o leka gape.',
          ),
        };
      });
    } catch (_) {
      if (!_current(generation)) return;

      setState(() {
        _error = tr(
          'Removal could not be confirmed. Refresh your list.',
          'Lekola lenaneo la distokvel.',
        );
      });
    } finally {
      if (_current(generation)) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(sessionProvider);
    final origin = ref.watch(sessionOriginProvider);

    if (user?.id != widget.accountId ||
        origin != SessionOrigin.api ||
        ref.read(sessionProvider.notifier).sessionGeneration !=
            widget.sessionGeneration) {
      return Scaffold(
        body: Center(child: Text(tr('Please sign in.', 'Ka kgopelo tsena.'))),
      );
    }

    final theme = Theme.of(context);
    final amount = _details?['contributionAmount'];
    final members = _details?['memberCount'];
    final rules = _details?['rules'];
    final closingDay = _details?['closingDayOfMonth'];

    final cycles = ref.watch(apiContributionCyclesProvider(widget.stokvelId));

    final activeCycles = cycles.asData?.value
        .where(
          (cycle) =>
              cycle.isClosed != true &&
              cycle.closedAtUtc == null &&
              (cycle.status?.toLowerCase() == 'active' ||
                  cycle.status?.toLowerCase() == 'open'),
        )
        .length;

    return PopScope(
      canPop: !_busy,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.stokvelName),
          actions: [
            IconButton(
              tooltip: tr('Refresh', 'Mpshafatsa'),
              onPressed: _busy || _loading
                  ? null
                  : () {
                      ref.invalidate(
                        apiContributionCyclesProvider(widget.stokvelId),
                      );
                      _load();
                    },
              icon: const Icon(Icons.refresh),
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
                  if (_loading) const LinearProgressIndicator(),

                  Card(
                    color: theme.colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tr('STOKVEL OVERVIEW', 'KAKARETSO'),
                            style: theme.textTheme.labelLarge,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.stokvelName,
                            style: theme.textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Chip(label: Text(widget.role)),
                          const SizedBox(height: 16),
                          Text(
                            amount is num
                                ? 'R ${amount.toStringAsFixed(2)}'
                                : '--',
                            style: theme.textTheme.headlineMedium,
                          ),
                          Text(tr('Monthly contribution', 'Moneelo wa kgwedi')),
                          if (closingDay is int) ...[
                            const SizedBox(height: 8),
                            Text(
                              tr(
                                'Monthly closing day: $closingDay',
                                'Letsatsi la go tswalela: $closingDay',
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _stat(
                          Icons.groups_outlined,
                          members?.toString() ?? '--',
                          tr('Members', 'Maloko'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _stat(
                          Icons.calendar_month_outlined,
                          activeCycles?.toString() ?? '--',
                          tr('Active cycles', 'Medikologo'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Text(
                    tr('Manage stokvel', 'Laola stokvel'),
                    style: theme.textTheme.titleLarge,
                  ),

                  const SizedBox(height: 12),

                  Card(
                    child: ListTile(
                      key: const Key('open_contribution_cycles'),
                      leading: const Icon(Icons.calendar_month_outlined),
                      title: Text(tr('Contribution cycles', 'Medikologo')),
                      subtitle: Text(
                        tr(
                          'View cycles and record contributions',
                          'Bona medikologo le meneelo',
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap:
                          _busy ||
                              _details == null ||
                              amount is! num ||
                              !amount.isFinite ||
                              amount <= 0
                          ? null
                          : () => Navigator.of(context).push<void>(
                              MaterialPageRoute<void>(
                                builder: (_) => ApiContributionScreen(
                                  requiredAmount: amount.toDouble(),
                                  stokvelId: widget.stokvelId,
                                  stokvelName: widget.stokvelName,
                                  accountId: widget.accountId,
                                  sessionGeneration: widget.sessionGeneration,
                                ),
                              ),
                            ),
                    ),
                  ),

                  if (_chairperson || widget.role.toLowerCase() == 'treasurer')
                    Card(
                      child: ListTile(
                        key: const Key('create_contribution_cycle'),
                        leading: const Icon(Icons.event_available),
                        title: Text(
                          tr('Create contribution cycle', 'Hlama modikologo'),
                        ),
                        subtitle: Text(
                          tr(
                            'Open another monthly contribution cycle',
                            'Bula modikologo wa kgwedi',
                          ),
                        ),
                        trailing: const Icon(Icons.add_circle_outline),
                        onTap: _busy || _loading || _details == null
                            ? null
                            : _createCycle,
                      ),
                    ),

                  if (_chairperson || widget.role.toLowerCase() == 'treasurer')
                    Card(
                      child: ListTile(
                        key: const Key('invite_stokvel_members'),
                        leading: const Icon(Icons.group_add_outlined),
                        title: Text(tr('Invite members', 'Mema maloko')),
                        subtitle: Text(
                          tr(
                            'Generate and share an invitation code',
                            'Hlama khoutu ya memo',
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _busy || _loading || _details == null
                            ? null
                            : _inviteMembers,
                      ),
                    ),

                  Card(
                    child: ListTile(
                      key: const Key('manage_stokvel_members'),
                      leading: const Icon(Icons.groups_outlined),
                      title: Text(tr('Manage members', 'Laola maloko')),
                      subtitle: Text(
                        tr(
                          'View members and membership roles',
                          'Bona maloko le maemo',
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _busy || _loading || _details == null
                          ? null
                          : () {
                              final generation = ref
                                  .read(apiAuthClientProvider)
                                  .sessionGeneration;

                              Navigator.of(context).push<void>(
                                MaterialPageRoute<void>(
                                  builder: (_) => ManageMembersScreen(
                                    stokvelId: widget.stokvelId,
                                    stokvelName: widget.stokvelName,
                                    accountId: widget.accountId,
                                    canManage: _chairperson,
                                    authGeneration: generation,
                                    isSessionCurrent: () =>
                                        _current(generation),
                                  ),
                                ),
                              );
                            },
                    ),
                  ),

                  if (widget.role.toLowerCase() == 'treasurer')
                    Card(
                      child: ListTile(
                        key: const Key('review_contributions'),
                        leading: const Icon(Icons.fact_check_outlined),
                        title: Text(
                          tr('Review contributions', 'Lekola meneelo'),
                        ),
                        subtitle: Text(
                          tr('Review recorded payments', 'Lekola ditefelo'),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _busy || _loading || _details == null
                            ? null
                            : () {
                                final generation = ref
                                    .read(apiAuthClientProvider)
                                    .sessionGeneration;

                                Navigator.of(context).push<void>(
                                  MaterialPageRoute<void>(
                                    builder: (_) => TreasurerReviewScreen(
                                      stokvelId: widget.stokvelId,
                                      stokvelName: widget.stokvelName,
                                      accountId: widget.accountId,
                                      authGeneration: generation,
                                      isSessionCurrent: () =>
                                          _current(generation),
                                    ),
                                  ),
                                );
                              },
                      ),
                    ),

                  if (rules is String && rules.trim().isNotEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tr('Stokvel rules', 'Melao'),
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(rules),
                          ],
                        ),
                      ),
                    ),

                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Semantics(
                        liveRegion: true,
                        child: Text(
                          _error!,
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 12),

                  if (_chairperson || _member)
                    OutlinedButton.icon(
                      key: Key(
                        _chairperson ? 'delete_empty_stokvel' : 'leave_stokvel',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                        side: BorderSide(color: theme.colorScheme.error),
                        padding: const EdgeInsets.all(16),
                      ),
                      onPressed: _busy || _loading || _details == null
                          ? null
                          : _remove,
                      icon: _busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              _chairperson
                                  ? Icons.delete_outline
                                  : Icons.logout,
                            ),
                      label: Text(
                        _chairperson
                            ? tr('Delete empty stokvel', 'Phumola stokvel')
                            : tr('Leave stokvel', 'Tloga stokvel'),
                      ),
                    ),

                  const SizedBox(height: 16),

                  Text(
                    tr('Stokvel reference', 'Nomoro ya stokvel'),
                    style: theme.textTheme.labelMedium,
                  ),
                  SelectableText(
                    widget.stokvelId,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _stat(IconData icon, String value, String label) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(height: 12),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
            Text(label),
          ],
        ),
      ),
    );
  }
}
