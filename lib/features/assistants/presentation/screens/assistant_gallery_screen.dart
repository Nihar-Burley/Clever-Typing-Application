import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_section_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/assistant_template.dart';
import '../../providers/assistant_gallery_provider.dart';
import 'assistant_execution_screen.dart';

/// Shows built-in and custom assistant templates available to the user.
class AssistantGalleryScreen extends ConsumerWidget {
  /// Creates the assistant gallery screen.
  const AssistantGalleryScreen({super.key});

  static const String routeName = 'assistant-gallery';
  static const String routePath = '/assistants';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AssistantGalleryState state = ref.watch(assistantGalleryProvider);
    final AssistantGalleryNotifier notifier =
        ref.read(assistantGalleryProvider.notifier);
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.assistantGalleryTitle),
        actions: <Widget>[
          IconButton(
            onPressed: state.isLoading ? null : notifier.refresh,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () => _showAssistantEditor(
              context,
              notifier,
              existing: null,
            ),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: <Widget>[
          AppSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  l10n.assistantGalleryHeadline,
                  style: textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.assistantGalleryBody,
                  style: textTheme.bodyLarge,
                ),
                if (state.errorMessage != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.sm),
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
          const SizedBox(height: AppSpacing.lg),
          if (state.isLoading)
            const Center(child: CircularProgressIndicator())
          else
            ...state.assistants.map(
              (AssistantTemplate assistant) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: AppSectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              assistant.name,
                              style: textTheme.titleLarge,
                            ),
                          ),
                          if (assistant.isPinned)
                            const Icon(Icons.push_pin, size: 18),
                          if (assistant.isPremium)
                            Padding(
                              padding:
                                  const EdgeInsetsDirectional.only(start: 8),
                              child: Chip(label: Text(l10n.commonPremium)),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(assistant.description),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        assistant.promptIntent,
                        style: textTheme.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: <Widget>[
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      AssistantExecutionScreen(assistant: assistant),
                                ),
                              );
                            },
                            child: Text(l10n.assistantExecutionAction),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => notifier.togglePinned(assistant),
                            icon: Icon(
                              assistant.isPinned
                                  ? Icons.push_pin
                                  : Icons.push_pin_outlined,
                            ),
                            label: Text(
                              assistant.isPinned ? 'Unpin' : 'Pin',
                            ),
                          ),
                          if (assistant.isCustom) ...<Widget>[
                            OutlinedButton.icon(
                              onPressed: () => _showAssistantEditor(
                                context,
                                notifier,
                                existing: assistant,
                              ),
                              icon: const Icon(Icons.edit_outlined),
                              label: const Text('Edit'),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => notifier.deleteAssistant(assistant),
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Delete'),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showAssistantEditor(
    BuildContext context,
    AssistantGalleryNotifier notifier, {
    AssistantTemplate? existing,
  }) async {
    final TextEditingController nameController = TextEditingController(
      text: existing?.name ?? '',
    );
    final TextEditingController descriptionController = TextEditingController(
      text: existing?.description ?? '',
    );
    final TextEditingController intentController = TextEditingController(
      text: existing?.promptIntent ?? '',
    );
    final TextEditingController promptController = TextEditingController(
      text: existing?.promptTemplate ?? '',
    );

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(existing == null ? 'Create assistant' : 'Edit assistant'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: intentController,
                  decoration: const InputDecoration(labelText: 'Intent'),
                ),
                TextField(
                  controller: promptController,
                  minLines: 4,
                  maxLines: 8,
                  decoration:
                      const InputDecoration(labelText: 'Prompt template'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final AssistantTemplate assistant = (existing ??
                        AssistantTemplate(
                          id: 'custom-${DateTime.now().millisecondsSinceEpoch}',
                          name: '',
                          description: '',
                          promptIntent: '',
                          promptTemplate: '',
                          isPremium: false,
                          isCustom: true,
                          isPinned: false,
                          updatedAt: DateTime.now(),
                        ))
                    .copyWith(
                  name: nameController.text.trim(),
                  description: descriptionController.text.trim(),
                  promptIntent: intentController.text.trim(),
                  promptTemplate: promptController.text.trim(),
                  isCustom: true,
                  updatedAt: DateTime.now(),
                );
                await notifier.saveAssistant(assistant);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
