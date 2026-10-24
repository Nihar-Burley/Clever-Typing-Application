import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_section_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/tone_option.dart';
import '../../domain/entities/writing_tool.dart';
import '../../providers/writing_tools_provider.dart';
import '../models/writing_tools_state.dart';

class WritingToolsScreen extends ConsumerStatefulWidget {
  const WritingToolsScreen({super.key});

  static const String routeName = 'writing-tools';
  static const String routePath = '/writing-tools';

  @override
  ConsumerState<WritingToolsScreen> createState() => _WritingToolsScreenState();
}

class _WritingToolsScreenState extends ConsumerState<WritingToolsScreen> {
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
    final l10n = AppLocalizations.of(context);
    final WritingToolsState state = ref.watch(writingToolsProvider);
    final notifier = ref.read(writingToolsProvider.notifier);
    final tools = ref.watch(writingToolsCatalogProvider);
    final tones = ref.watch(writingToolTonesProvider);
    final textTheme = Theme.of(context).textTheme;

    if (_controller.text != state.inputText) {
      _controller.value = _controller.value.copyWith(
        text: state.inputText,
        selection: TextSelection.collapsed(offset: state.inputText.length),
        composing: TextRange.empty,
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.writingToolsTitle)),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: <Widget>[
          AppSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(l10n.writingToolsHeadline, style: textTheme.headlineSmall),
                const SizedBox(height: AppSpacing.sm),
                Text(l10n.writingToolsBody),
                const SizedBox(height: AppSpacing.lg),
                DropdownButtonFormField<WritingTool>(
                  initialValue: state.selectedTool,
                  items: tools
                      .map(
                        (tool) => DropdownMenuItem<WritingTool>(
                          value: tool,
                          child: Text(_toolLabel(l10n, tool)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      notifier.updateTool(value);
                    }
                  },
                  decoration: InputDecoration(
                    labelText: l10n.writingToolsToolLabel,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<ToneOption>(
                  initialValue: state.selectedTone,
                  items: tones
                      .map(
                        (tone) => DropdownMenuItem<ToneOption>(
                          value: tone,
                          child: Text(_toneLabel(l10n, tone)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      notifier.updateTone(value);
                    }
                  },
                  decoration: InputDecoration(
                    labelText: l10n.writingToolsToneLabel,
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
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _controller,
                  minLines: 6,
                  maxLines: 10,
                  decoration: InputDecoration(
                    labelText: l10n.writingToolsInputLabel,
                    hintText: l10n.writingToolsInputHint,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: notifier.updateInput,
                ),
                const SizedBox(height: AppSpacing.md),
                ElevatedButton(
                  onPressed: state.isSubmitting ? null : notifier.submit,
                  child: Text(
                    state.isSubmitting
                        ? l10n.writingToolsLoading
                        : l10n.writingToolsAction,
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
                    l10n.writingToolsResultTitle,
                    style: textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(state.result!.outputText),
                  if (state.result!.summaryBullets.isNotEmpty) ...<Widget>[
                    const SizedBox(height: AppSpacing.md),
                    ...state.result!.summaryBullets.map(
                      (bullet) => Text('- $bullet'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _toolLabel(AppLocalizations l10n, WritingTool tool) {
    return switch (tool) {
      WritingTool.grammarCorrection => l10n.toolGrammarCorrection,
      WritingTool.toneRewrite => l10n.toolToneRewrite,
      WritingTool.paraphrase => l10n.toolParaphrase,
      WritingTool.shorten => l10n.toolShorten,
      WritingTool.expand => l10n.toolExpand,
      WritingTool.simplify => l10n.toolSimplify,
      WritingTool.humanize => l10n.toolHumanize,
      WritingTool.summarize => l10n.toolSummarize,
      WritingTool.captionGeneration => l10n.toolCaptionGeneration,
      WritingTool.emailDraft => l10n.toolEmailDraft,
    };
  }

  String _toneLabel(AppLocalizations l10n, ToneOption tone) {
    return switch (tone) {
      ToneOption.neutral => l10n.toneNeutral,
      ToneOption.professional => l10n.toneProfessional,
      ToneOption.friendly => l10n.toneFriendly,
      ToneOption.formal => l10n.toneFormal,
      ToneOption.persuasive => l10n.tonePersuasive,
    };
  }
}
