import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_section_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../presentation/models/translation_state.dart';
import '../../providers/translation_provider.dart';

/// Screen for translation and multilingual support.
class TranslationScreen extends ConsumerStatefulWidget {
  /// Creates the translation screen.
  const TranslationScreen({super.key});

  static const String routeName = 'translation';
  static const String routePath = '/translation';

  @override
  ConsumerState<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends ConsumerState<TranslationScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final TranslationState state = ref.watch(translationProvider);
    final TranslationNotifier notifier = ref.read(translationProvider.notifier);
    final List<String> languages = ref.watch(translationLanguagesProvider);
    final TextTheme textTheme = Theme.of(context).textTheme;

    if (_controller.text != state.inputText) {
      _controller.value = _controller.value.copyWith(
        text: state.inputText,
        selection: TextSelection.collapsed(offset: state.inputText.length),
        composing: TextRange.empty,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translationTitle),
      ),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: <Widget>[
          AppSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  l10n.translationHeadline,
                  style: textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.translationBody,
                  style: textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.lg),
                DropdownButtonFormField<String>(
                  initialValue: state.sourceLanguage,
                  items: languages
                      .map(
                        (String language) => DropdownMenuItem<String>(
                          value: language,
                          child: Text(language),
                        ),
                      )
                      .toList(),
                  onChanged: (String? value) {
                    if (value != null) {
                      notifier.updateSourceLanguage(value);
                    }
                  },
                  decoration: InputDecoration(
                    labelText: l10n.translationSourceLanguageLabel,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<String>(
                  initialValue: state.targetLanguage,
                  items: languages
                      .where((String language) => language != 'Auto Detect')
                      .map(
                        (String language) => DropdownMenuItem<String>(
                          value: language,
                          child: Text(language),
                        ),
                      )
                      .toList(),
                  onChanged: (String? value) {
                    if (value != null) {
                      notifier.updateTargetLanguage(value);
                    }
                  },
                  decoration: InputDecoration(
                    labelText: l10n.translationLanguageLabel,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.translationPreserveToneLabel),
                  value: state.preserveTone,
                  onChanged: notifier.updatePreserveTone,
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _controller,
                  minLines: 5,
                  maxLines: 8,
                  decoration: InputDecoration(
                    labelText: l10n.translationInputLabel,
                    hintText: l10n.translationInputHint,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: notifier.updateInput,
                ),
                const SizedBox(height: AppSpacing.md),
                ElevatedButton(
                  onPressed: state.isSubmitting ? null : notifier.translate,
                  child: Text(
                    state.isSubmitting
                        ? l10n.translationLoading
                        : l10n.translationAction,
                  ),
                ),
                if (state.errorMessage != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    state.errorMessage!,
                    style: textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (state.translatedText != null) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            AppSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    l10n.translationResultTitle,
                    style: textTheme.titleLarge,
                  ),
                  if (state.detectedSourceLanguage != null) ...<Widget>[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.translationDetectedLanguage(
                        state.detectedSourceLanguage!,
                      ),
                      style: textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  Text(state.translatedText!),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
