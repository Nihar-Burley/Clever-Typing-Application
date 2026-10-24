import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_section_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../providers/grammar_correction_provider.dart';
import '../models/grammar_correction_state.dart';

/// Screen for the first end-to-end grammar correction flow.
class GrammarCorrectionScreen extends ConsumerStatefulWidget {
  /// Creates the grammar correction screen.
  const GrammarCorrectionScreen({super.key});

  static const String routeName = 'grammar-correction';
  static const String routePath = '/grammar-correction';

  @override
  ConsumerState<GrammarCorrectionScreen> createState() =>
      _GrammarCorrectionScreenState();
}

class _GrammarCorrectionScreenState
    extends ConsumerState<GrammarCorrectionScreen> {
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
    final GrammarCorrectionState state = ref.watch(grammarCorrectionProvider);
    final GrammarCorrectionNotifier notifier =
        ref.read(grammarCorrectionProvider.notifier);
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
        title: Text(l10n.grammarCorrectionTitle),
      ),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: <Widget>[
          AppSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  l10n.grammarCorrectionHeadline,
                  style: textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.grammarCorrectionBody,
                  style: textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  controller: _controller,
                  minLines: 6,
                  maxLines: 10,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: l10n.grammarCorrectionInputLabel,
                    hintText: l10n.grammarCorrectionInputHint,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: notifier.updateInput,
                ),
                const SizedBox(height: AppSpacing.md),
                ElevatedButton(
                  onPressed: state.isSubmitting ? null : notifier.submit,
                  child: Text(
                    state.isSubmitting
                        ? l10n.grammarCorrectionLoading
                        : l10n.grammarCorrectionAction,
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
          if (state.result != null) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            AppSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    l10n.grammarCorrectionResultTitle,
                    style: textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.grammarCorrectionOriginalLabel,
                    style: textTheme.labelLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(state.result!.originalText),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.grammarCorrectionCorrectedLabel,
                    style: textTheme.labelLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(state.result!.correctedText),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
