import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../../session/presentation/session_provider.dart';
import '../../session/presentation/session_origin_provider.dart';

class CreateStokvelScreen extends ConsumerStatefulWidget {
  const CreateStokvelScreen({super.key});

  @override
  ConsumerState<CreateStokvelScreen> createState() =>
      _CreateStokvelScreenState();
}

class _CreateStokvelScreenState extends ConsumerState<CreateStokvelScreen> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _amount = TextEditingController();
  final _rules = TextEditingController();

  bool _createFirstCycle = true;
  int _closingDay = 25;

  DateTime _firstMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month + 1,
  );

  String _period(DateTime month) =>
      '${month.year}-${month.month.toString().padLeft(2, '0')}';

  String _monthLabel(DateTime month) =>
      MaterialLocalizations.of(context).formatMonthYear(month);

  CancelToken? _cancelToken;
  bool _busy = false;
  String? _error;

  String tr(String en, String nso) =>
      Localizations.localeOf(context).languageCode == 'nso' ? nso : en;

  @override
  void dispose() {
    _cancelToken?.cancel();
    _name.dispose();
    _amount.dispose();
    _rules.dispose();
    super.dispose();
  }

  int? _parseCents(String value) {
    final text = value.trim();

    if (!RegExp(r'^\d{1,8}(\.\d{1,2})?$').hasMatch(text)) {
      return null;
    }

    final parts = text.split('.');
    final whole = int.parse(parts.first);
    final fraction = parts.length == 2
        ? int.parse(parts.last.padRight(2, '0'))
        : 0;

    final cents = whole * 100 + fraction;

    return cents > 0 && cents <= 2147483647 ? cents : null;
  }

  Future<void> _create() async {
    if (_busy || !_formKey.currentState!.validate()) return;

    final user = ref.read(sessionProvider);
    final auth = ref.read(apiAuthClientProvider);

    if (user == null ||
        !auth.isAuthenticated ||
        ref.read(sessionOriginProvider) != SessionOrigin.api) {
      return;
    }

    final generation = auth.sessionGeneration;
    final accountId = user.id;
    final token = CancelToken();

    _cancelToken = token;

    FocusScope.of(context).unfocus();

    setState(() {
      _busy = true;
      _error = null;
    });

    bool current() =>
        mounted &&
        ref.read(sessionProvider)?.id == accountId &&
        ref.read(sessionOriginProvider) == SessionOrigin.api &&
        auth.sessionGeneration == generation;

    try {
      final response = await ref
          .read(dioProvider)
          .post<Map<String, dynamic>>(
            '/api/v1/stokvels',
            data: {
              'name': _name.text.trim(),
              'contributionAmount': _parseCents(_amount.text)! / 100,
              'rules': _rules.text.trim(),
              'closingDayOfMonth': _closingDay,
              'firstCyclePeriod': _createFirstCycle
                  ? _period(_firstMonth)
                  : null,
            },
            cancelToken: token,
            options: Options(
              extra: {'requiredAuthSessionGeneration': generation},
            ),
          );

      if (!current()) return;

      final id = response.data?['id'];

      if (response.statusCode != 201 || id is! String || id.isEmpty) {
        throw StateError('Unexpected stokvel response.');
      }

      if (!mounted) return;

      Navigator.of(context).pop(id);
    } on DioException catch (error) {
      if (!current()) return;

      setState(() {
        _error = switch (error.response?.statusCode) {
          400 || 422 => tr(
            'Please check the stokvel details.',
            'Lekola dintlha tsa stokvel.',
          ),
          401 || 403 => tr('Please sign in again.', 'Tsena gape.'),
          429 => tr(
            'Too many requests. Try again later.',
            'Leka gape ka morago.',
          ),
          _ => tr(
            'Creation could not be confirmed. Check your stokvel list before retrying.',
            'Lekola lenaneo la distokvel pele o leka gape.',
          ),
        };
      });
    } catch (_) {
      if (!current()) return;

      setState(() {
        _error = tr(
          'Creation could not be confirmed. Check your stokvel list.',
          'Lekola lenaneo la distokvel.',
        );
      });
    } finally {
      _cancelToken = null;

      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_busy,
      child: Scaffold(
        appBar: AppBar(title: Text(tr('Create stokvel', 'Hlama stokvel'))),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.groups_outlined,
                        size: 72,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        tr('Start your own stokvel', 'Thoma stokvel ya gago'),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        tr(
                          'You will automatically become the chairperson.',
                          'O tla ba modulasetulo.',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        key: const Key('create_stokvel_name'),
                        controller: _name,
                        onChanged: (_) => setState(() {}),
                        enabled: !_busy,
                        maxLength: 100,
                        decoration: InputDecoration(
                          labelText: tr('Stokvel name', 'Leina la stokvel'),
                          prefixIcon: const Icon(Icons.groups),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) => (value ?? '').trim().isEmpty
                            ? tr(
                                'Enter a stokvel name.',
                                'Tsenya leina la stokvel.',
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        key: const Key('create_stokvel_amount'),
                        controller: _amount,
                        onChanged: (_) => setState(() {}),
                        enabled: !_busy,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: tr(
                            'Monthly contribution',
                            'Moneelo wa kgwedi',
                          ),
                          prefixText: 'R ',
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) => _parseCents(value ?? '') == null
                            ? tr(
                                'Enter a valid positive amount.',
                                'Tsenya tshelete ya maleba.',
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        key: const Key('create_stokvel_rules'),
                        controller: _rules,
                        enabled: !_busy,
                        maxLines: 4,
                        maxLength: 500,
                        decoration: InputDecoration(
                          labelText: tr(
                            'Rules (optional)',
                            'Melao (ga e gapeletsege)',
                          ),
                          alignLabelWithHint: true,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
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
                      const SizedBox(height: 24),

                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),
                      Text(
                        tr('Contribution schedule', 'Lenaneo la meneelo'),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      InputDecorator(
                        decoration: InputDecoration(
                          labelText: tr(
                            'Contribution frequency',
                            'Nako ya meneelo',
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(tr('Monthly', 'Kgwedi le kgwedi')),
                            ),
                            const Icon(Icons.lock_outline),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        key: const Key('stokvel_closing_day'),
                        initialValue: _closingDay,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: tr(
                            'Monthly closing day',
                            'Letšatši la go tswalela',
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        items: List.generate(
                          28,
                          (index) => DropdownMenuItem(
                            value: index + 1,
                            child: Text(
                              tr(
                                'Day ${index + 1} of every month',
                                'Letšatši ${index + 1}',
                              ),
                            ),
                          ),
                        ),
                        onChanged: _busy
                            ? null
                            : (value) {
                                if (value != null) {
                                  setState(() => _closingDay = value);
                                }
                              },
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        key: const Key('create_first_cycle'),
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          tr(
                            'Create first contribution cycle',
                            'Hlama modikologo wa mathomo',
                          ),
                        ),
                        subtitle: Text(
                          tr(
                            'Automatically create your first monthly cycle.',
                            'Hlama modikologo wa kgwedi.',
                          ),
                        ),
                        value: _createFirstCycle,
                        onChanged: _busy
                            ? null
                            : (value) =>
                                  setState(() => _createFirstCycle = value),
                      ),
                      if (_createFirstCycle) ...[
                        const SizedBox(height: 12),
                        DropdownButtonFormField<DateTime>(
                          key: const Key('first_cycle_month'),
                          initialValue: _firstMonth,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: tr(
                              'First contribution month',
                              'Kgwedi ya mathomo',
                            ),
                            border: const OutlineInputBorder(),
                          ),
                          items: List.generate(24, (index) {
                            final now = DateTime.now();

                            final month = DateTime(
                              now.year,
                              now.month + 1 + index,
                            );

                            return DropdownMenuItem(
                              value: month,
                              child: Text(_monthLabel(month)),
                            );
                          }),
                          onChanged: _busy
                              ? null
                              : (value) {
                                  if (value != null) {
                                    setState(() => _firstMonth = value);
                                  }
                                },
                        ),
                      ],
                      const SizedBox(height: 24),
                      Card(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                tr(
                                  'Your stokvel summary',
                                  'Kakaretšo ya stokvel',
                                ),
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const Divider(),
                              _summaryRow(
                                tr('Name', 'Leina'),
                                _name.text.trim().isEmpty
                                    ? tr('Not entered', 'Ga go na leina')
                                    : _name.text.trim(),
                              ),
                              _summaryRow(
                                tr('Your role', 'Maikarabelo'),
                                tr('Chairperson', 'Modulasetulo'),
                              ),
                              _summaryRow(
                                tr('Monthly contribution', 'Moneelo'),
                                'R ${((_parseCents(_amount.text) ?? 0) / 100).toStringAsFixed(2)}',
                              ),
                              _summaryRow(
                                tr('Closing day', 'Letšatši'),
                                '$_closingDay',
                              ),
                              _summaryRow(
                                tr('First cycle', 'Modikologo'),
                                _createFirstCycle
                                    ? _monthLabel(_firstMonth)
                                    : tr('Not created', 'Ga se wa hlangwa'),
                              ),
                              _summaryRow(tr('Initial members', 'Maloko'), '1'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        key: const Key('create_stokvel_submit'),
                        onPressed: _busy ? null : _create,
                        icon: _busy
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.add),
                        label: Text(tr('Create stokvel', 'Hlama stokvel')),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
