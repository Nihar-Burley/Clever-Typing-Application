import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_section_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/assistant_template.dart';
import '../../providers/assistant_execution_provider.dart';

class AssistantExecutionScreen extends ConsumerStatefulWidget {
  const AssistantExecutionScreen({
    required this.assistant,
    super.key,
  });

  final AssistantTemplate assistant;

  @override
  ConsumerState<AssistantExecutionScreen> createState() =>
      _AssistantExecutionScreenState();
}

class _AssistantExecutionScreenState
    extends ConsumerState<AssistantExecutionScreen> {
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
    final state = ref.watch(assistantExecutionProvider(widget.assistant));
    final notifier =
        ref.read(assistantExecutionProvider(widget.assistant).notifier);
    final textTheme = Theme.of(context).textTheme;

    if (_controller.text != state.inputText) {
      _controller.value = _controller.value.copyWith(
        text: state.inputText,
        selection: TextSelection.collapsed(offset: state.inputText.length),
        composing: TextRange.empty,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.assistant.name),
      ),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: <Widget>[
          AppSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(widget.assistant.description, style: textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                Text(widget.assistant.promptIntent),
                const SizedBox(height: AppSpacing.sm),
                Text(l10n.assistantExecutionBody),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _controller,
                  minLines: 6,
                  maxLines: 10,
                  decoration: InputDecoration(
                    labelText: l10n.assistantExecutionInputLabel,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: notifier.updateInput,
                ),
                const SizedBox(height: AppSpacing.md),
                ElevatedButton(
                  onPressed: state.isSubmitting ? null : notifier.submit,
                  child: Text(
                    state.isSubmitting
                        ? l10n.assistantExecutionLoading
                        : l10n.assistantExecutionAction,
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
                    l10n.assistantExecutionResultTitle,
                    style: textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(state.result!.outputText),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
