import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import 'session_provider.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  CancelToken? _cancelToken;

  bool _busy = false;
  bool _hidePassword = true;
  bool _hideConfirm = true;

  String? _error;

  String tr(String en, String nso) =>
      Localizations.localeOf(context).languageCode == 'nso' ? nso : en;

  @override
  void dispose() {
    _cancelToken?.cancel();

    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();

    super.dispose();
  }

  Future<void> _register() async {
    if (_busy || ref.read(sessionProvider) != null) return;

    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final token = CancelToken();
    _cancelToken = token;

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final response = await ref
          .read(dioProvider)
          .post<dynamic>(
            '/api/v1/auth/register',
            data: {
              'name': _name.text.trim(),
              'contactNumber': _phone.text.trim(),
              'email': _email.text.trim().toLowerCase(),
              'password': _password.text,
            },
            cancelToken: token,
          );

      if (!mounted) return;

      if (response.statusCode != 201) {
        throw StateError('Unexpected registration response.');
      }

      _password.clear();
      _confirm.clear();

      final email = _email.text.trim().toLowerCase();

      setState(() => _busy = false);

      Navigator.of(context).pop(email);
    } on DioException catch (error) {
      if (!mounted) return;

      setState(() {
        _error = switch (error.response?.statusCode) {
          409 => tr(
            'This email address is already registered.',
            'Imeile ye e setse e ngodisitswe.',
          ),
          400 || 422 => tr(
            'Please check your registration details.',
            'Lekola dintlha tsa gago.',
          ),
          429 => tr(
            'Too many attempts. Try again later.',
            'Leka gape ka morago.',
          ),
          _ => tr(
            'Registration failed. Check your connection.',
            'Ngodiso e padile. Lekola kgokagano.',
          ),
        };
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _error = tr(
          'Unable to create your account.',
          'Ga go kgonege go hlama akhaonto.',
        );
      });
    } finally {
      _cancelToken = null;

      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_busy,
      child: Scaffold(
        appBar: AppBar(title: Text(tr('Create account', 'Hlama akhaonto'))),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.person_add_alt_1,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        tr('Join RondiTrack', 'Tsena go RondiTrack'),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        key: const Key('register_name'),
                        controller: _name,
                        enabled: !_busy,
                        textCapitalization: TextCapitalization.words,
                        maxLength: 100,
                        decoration: InputDecoration(
                          labelText: tr('Full name', 'Leina ka botlalo'),
                          prefixIcon: const Icon(Icons.person_outline),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          final name = value?.trim() ?? '';

                          if (name.isEmpty || name.length > 100) {
                            return tr(
                              'Enter a valid full name.',
                              'Tsenya leina la gago.',
                            );
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        key: const Key('register_phone'),
                        controller: _phone,
                        enabled: !_busy,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          labelText: tr('Contact number', 'Nomoro ya mogala'),
                          prefixIcon: const Icon(Icons.phone_outlined),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            RegExp(r'^[0-9]{10}$').hasMatch(value ?? '')
                            ? null
                            : tr(
                                'Enter exactly 10 digits.',
                                'Tsenya dinomoro tse 10.',
                              ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        key: const Key('register_email'),
                        controller: _email,
                        enabled: !_busy,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        maxLength: 320,
                        decoration: InputDecoration(
                          labelText: tr('Email address', 'Imeile'),
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          final email = value?.trim() ?? '';

                          if (email.length > 320 ||
                              !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                  .hasMatch(email)) {
                            return tr(
                              'Enter a valid email address.',
                              'Tsenya imeile ya maleba.',
                            );
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        key: const Key('register_password'),
                        controller: _password,
                        enabled: !_busy,
                        obscureText: _hidePassword,
                        autocorrect: false,
                        enableSuggestions: false,
                        decoration: InputDecoration(
                          labelText: tr('Password', 'Lentsuphetiso'),
                          helperText: tr(
                            'At least 12 characters',
                            'Bonyane ditlhaka tse 12',
                          ),
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            onPressed: () =>
                                setState(() => _hidePassword = !_hidePassword),
                            icon: Icon(
                              _hidePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator: (value) => (value ?? '').length < 12
                            ? tr(
                                'Use at least 12 characters.',
                                'Somisa ditlhaka tse 12 goba go feta.',
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        key: const Key('register_confirm'),
                        controller: _confirm,
                        enabled: !_busy,
                        obscureText: _hideConfirm,
                        autocorrect: false,
                        enableSuggestions: false,
                        decoration: InputDecoration(
                          labelText: tr(
                            'Confirm password',
                            'Netefatsa lentsuphetiso',
                          ),
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            onPressed: () =>
                                setState(() => _hideConfirm = !_hideConfirm),
                            icon: Icon(
                              _hideConfirm
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator: (value) => value != _password.text
                            ? tr(
                                'Passwords do not match.',
                                'Mantsuphetiso ga a swane.',
                              )
                            : null,
                      ),
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
                      const SizedBox(height: 24),
                      FilledButton(
                        key: const Key('register_submit'),
                        onPressed: _busy ? null : _register,
                        child: _busy
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(tr('Create account', 'Hlama akhaonto')),
                      ),
                      TextButton(
                        onPressed: _busy
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: Text(
                          tr(
                            'Already have an account? Sign in',
                            'O na le akhaonto? Tsena',
                          ),
                        ),
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
