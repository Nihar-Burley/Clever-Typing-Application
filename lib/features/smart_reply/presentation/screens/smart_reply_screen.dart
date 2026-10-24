import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_section_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/reply_variant.dart';
import '../../presentation/models/smart_reply_state.dart';
import '../../providers/smart_reply_provider.dart';

/// Preview screen for the smart reply feature.
class SmartReplyScreen extends ConsumerStatefulWidget {
  /// Creates the smart reply screen.
  const SmartReplyScreen({super.key});

  static const String routeName = 'smart-reply';
  static const String routePath = '/smart-reply';

  @override
  ConsumerState<SmartReplyScreen> createState() => _SmartReplyScreenState();
}

class _SmartReplyScreenState extends ConsumerState<SmartReplyScreen> {
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
    final SmartReplyState state = ref.watch(smartReplyProvider);
    final SmartReplyNotifier notifier = ref.read(smartReplyProvider.notifier);
    final TextTheme textTheme = Theme.of(context).textTheme;

    if (_controller.text != state.contextText) {
      _controller.value = _controller.value.copyWith(
        text: state.contextText,
        selection: TextSelection.collapsed(offset: state.contextText.length),
        composing: TextRange.empty,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.smartReplyTitle),
      ),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: <Widget>[
          AppSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  l10n.smartReplyHeadline,
                  style: textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(l10n.smartReplyBody),
                const SizedBox(height: AppSpacing.md),
                Text(
                  state.isAccessibilityEnabled
                      ? l10n.smartReplyAccessibilityEnabled
                      : l10n.smartReplyAccessibilityDisabled,
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton(
                  onPressed: notifier.openAccessibilitySettings,
                  child: Text(l10n.smartReplyAccessibilityAction),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: notifier.refreshCapturedContext,
                  child: Text(l10n.smartReplyRefreshContextAction),
                ),
                const SizedBox(height: AppSpacing.lg),
                DropdownButtonFormField<ReplyVariant>(
                  initialValue: state.selectedVariant,
                  items: ReplyVariant.values
                      .map(
                        (ReplyVariant variant) =>
                            DropdownMenuItem<ReplyVariant>(
                          value: variant,
                          child: Text(_variantLabel(l10n, variant)),
                        ),
                      )
                      .toList(),
                  onChanged: (ReplyVariant? value) {
                    if (value != null) {
                      notifier.updateVariant(value);
                    }
                  },
                  decoration: InputDecoration(
                    labelText: l10n.smartReplyVariantLabel,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _controller,
                  minLines: 5,
                  maxLines: 8,
                  decoration: InputDecoration(
                    labelText: l10n.smartReplyInputLabel,
                    hintText: l10n.smartReplyInputHint,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: notifier.updateContext,
                ),
                const SizedBox(height: AppSpacing.md),
                ElevatedButton(
                  onPressed:
                      state.isSubmitting ? null : notifier.generateReplies,
                  child: Text(
                    state.isSubmitting
                        ? l10n.smartReplyLoading
                        : l10n.smartReplyAction,
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
          if (state.replies.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            ...state.replies.map(
              (String reply) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: AppSectionCard(
                  child: Text(reply),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _variantLabel(AppLocalizations l10n, ReplyVariant variant) {
    return switch (variant) {
      ReplyVariant.short => l10n.smartReplyVariantShort,
      ReplyVariant.friendly => l10n.smartReplyVariantFriendly,
      ReplyVariant.professional => l10n.smartReplyVariantProfessional,
      ReplyVariant.positive => l10n.smartReplyVariantPositive,
    };
  }
}
