import '../../../core/localization/localization_context.dart';
import '../../../core/localization/language_selector.dart';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'session_provider.dart';
import 'registration_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String? errorMessage;
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await ref
          .read(sessionProvider.notifier)
          .loginWithApi(emailController.text.trim(), passwordController.text);
    } on DioException catch (error) {
      if (!mounted) return;

      final status = error.response?.statusCode;

      setState(() {
        if (status == 400 || status == 401) {
          errorMessage = 'invalidCredentials';
        } else if (status == 429) {
          errorMessage = 'tooManyAttempts';
        } else {
          errorMessage = 'signInConnectionError';
        }
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'signInError';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.account_balance_wallet,
                  size: 72,
                  color: Colors.green,
                ),
                const SizedBox(height: 16),
                const Text(
                  'RondiTrack',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(l10n.signInSubtitle),
                const SizedBox(height: 24),
                const LanguageSelector(),
                const SizedBox(height: 32),
                TextField(
                  controller: emailController,
                  enabled: !isLoading,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: l10n.email,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  enabled: !isLoading,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l10n.password,
                    border: const OutlineInputBorder(),
                  ),
                  onSubmitted: (_) {
                    if (!isLoading) login();
                  },
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(switch (errorMessage) {
                    'invalidCredentials' => l10n.invalidCredentials,
                    'tooManyAttempts' => l10n.tooManyAttempts,
                    'signInConnectionError' => l10n.signInConnectionError,
                    _ => l10n.signInError,
                  }, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: isLoading ? null : login,
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.login),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  key: const Key('open_registration'),
                  onPressed: isLoading
                      ? null
                      : () async {
                          final email = await Navigator.of(context)
                              .push<String>(
                                MaterialPageRoute(
                                  builder: (_) => const RegistrationScreen(),
                                ),
                              );

                          if (!context.mounted || email == null) return;

                          emailController.text = email;
                          passwordController.clear();

                          setState(() => errorMessage = null);

                          final nso =
                              Localizations.localeOf(context).languageCode ==
                              'nso';

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                nso
                                    ? 'Akhaonto e hlamilwe. Tsena.'
                                    : 'Account created. You can now sign in.',
                              ),
                            ),
                          );
                        },
                  child: Text(
                    Localizations.localeOf(context).languageCode == 'nso'
                        ? 'Hlama akhaonto'
                        : 'Create an account',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
