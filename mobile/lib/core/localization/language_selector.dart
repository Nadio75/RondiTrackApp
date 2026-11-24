import 'localization_context.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../l10n/generated/app_localizations_en.dart';
import 'language_provider.dart';

class LanguageSelector extends ConsumerStatefulWidget {
  const LanguageSelector({super.key});

  @override
  ConsumerState<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends ConsumerState<LanguageSelector> {
  bool _saving = false;

  Future<void> _changeLanguage(Locale locale) async {
    if (_saving) return;

    setState(() => _saving = true);

    try {
      await ref.read(languageProvider.notifier).setLanguage(locale);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.languageSaveError)));
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n =
        Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizationsEn();

    final language = ref.watch(languageProvider);
    final selected = language.asData?.value ?? const Locale('en');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.appLanguage, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(l10n.chooseLanguage),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final option in const [
              (Locale('en'), 'English'),
              (Locale('nso'), 'Sepedi'),
            ])
              ChoiceChip(
                label: Text(option.$2),
                selected: selected == option.$1,
                onSelected: _saving || language.isLoading
                    ? null
                    : (value) {
                        if (value) {
                          _changeLanguage(option.$1);
                        }
                      },
              ),
          ],
        ),
      ],
    );
  }
}
