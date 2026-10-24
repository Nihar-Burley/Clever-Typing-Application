import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/di/core_providers.dart';
import '../../../../core/platform/models/keyboard_status.dart';
import '../../../../core/widgets/app_section_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../account/presentation/screens/account_screen.dart';
import '../../../assistants/presentation/screens/assistant_gallery_screen.dart';
import '../../../help/presentation/screens/help_screen.dart';
import '../../../keyboard_settings/presentation/screens/keyboard_settings_screen.dart';
import '../../../privacy/presentation/screens/privacy_dashboard_screen.dart';
import '../../../rewriting/presentation/screens/grammar_correction_screen.dart';
import '../../../smart_reply/presentation/screens/smart_reply_screen.dart';
import '../../../subscription/presentation/screens/subscription_screen.dart';
import '../../../translation/presentation/screens/translation_screen.dart';
import '../../../writing_tools/presentation/screens/writing_tools_screen.dart';

final FutureProvider<KeyboardStatus> homeKeyboardStatusProvider =
    FutureProvider<KeyboardStatus>(
  (Ref ref) {
    return ref.read(keyboardPlatformServiceProvider).getKeyboardStatus();
  },
);

/// Landing screen after onboarding completion.
class HomeScreen extends ConsumerWidget {
  /// Creates the home screen.
  const HomeScreen({super.key});

  static const String routeName = 'home';
  static const String routePath = '/home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final TextTheme textTheme = Theme.of(context).textTheme;
    final AsyncValue<KeyboardStatus> keyboardStatus = ref.watch(
      homeKeyboardStatusProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
      ),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: <Widget>[
          AppSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  l10n.homeWelcomeTitle,
                  style: textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.homeWelcomeBody,
                  style: textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  l10n.homeNextStepsTitle,
                  style: textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(l10n.homeNextStepsItemKeyboard),
                const SizedBox(height: AppSpacing.xs),
                Text(l10n.homeNextStepsItemSettings),
                const SizedBox(height: AppSpacing.xs),
                Text(l10n.homeNextStepsItemAi),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  l10n.homeFeatureDemoTitle,
                  style: textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.homeFeatureDemoBody,
                  style: textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.md),
                ElevatedButton(
                  onPressed: () {
                    ref
                        .read(keyboardPlatformServiceProvider)
                        .openKeyboardSettings();
                  },
                  child: Text(l10n.homeFeatureDemoAction),
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton(
                  onPressed: () {
                    ref
                        .read(keyboardPlatformServiceProvider)
                        .showInputMethodPicker();
                  },
                  child: Text(l10n.homeChooseKeyboardAction),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppSectionCard(
            child: keyboardStatus.when(
              data: (KeyboardStatus status) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    l10n.homeKeyboardStatusTitle,
                    style: textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.keyboardSettingsEnabledStatus(status.isKeyboardEnabled),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.keyboardSettingsSelectedStatus(status.isKeyboardSelected),
                  ),
                ],
              ),
              loading: () => Text(l10n.homeKeyboardStatusLoading),
              error: (_, __) => Text(l10n.keyboardSettingsStatusUnavailable),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.homeFeatureHubTitle,
            style: textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          _FeatureNavCard(
            title: l10n.homeCardAccountTitle,
            body: l10n.homeCardAccountBody,
            actionLabel: l10n.homeCardOpenFeature,
            onPressed: () => context.go(AccountScreen.routePath),
          ),
          const SizedBox(height: AppSpacing.md),
          _FeatureNavCard(
            title: l10n.homeCardWritingToolsTitle,
            body: l10n.homeCardWritingToolsBody,
            actionLabel: l10n.homeCardOpenFeature,
            onPressed: () => context.go(WritingToolsScreen.routePath),
          ),
          const SizedBox(height: AppSpacing.md),
          _FeatureNavCard(
            title: l10n.homeCardGrammarTitle,
            body: l10n.homeCardGrammarBody,
            actionLabel: l10n.homeCardOpenFeature,
            onPressed: () => context.go(GrammarCorrectionScreen.routePath),
          ),
          const SizedBox(height: AppSpacing.md),
          _FeatureNavCard(
            title: l10n.homeCardTranslationTitle,
            body: l10n.homeCardTranslationBody,
            actionLabel: l10n.homeCardOpenFeature,
            onPressed: () => context.go(TranslationScreen.routePath),
          ),
          const SizedBox(height: AppSpacing.md),
          _FeatureNavCard(
            title: l10n.homeCardAssistantsTitle,
            body: l10n.homeCardAssistantsBody,
            actionLabel: l10n.homeCardOpenFeature,
            onPressed: () => context.go(AssistantGalleryScreen.routePath),
          ),
          const SizedBox(height: AppSpacing.md),
          _FeatureNavCard(
            title: l10n.homeCardSmartReplyTitle,
            body: l10n.homeCardSmartReplyBody,
            actionLabel: l10n.homeCardOpenFeature,
            onPressed: () => context.go(SmartReplyScreen.routePath),
          ),
          const SizedBox(height: AppSpacing.md),
          _FeatureNavCard(
            title: l10n.homeCardSettingsTitle,
            body: l10n.homeCardSettingsBody,
            actionLabel: l10n.homeCardOpenFeature,
            onPressed: () => context.go(KeyboardSettingsScreen.routePath),
          ),
          const SizedBox(height: AppSpacing.md),
          _FeatureNavCard(
            title: l10n.homeCardSubscriptionTitle,
            body: l10n.homeCardSubscriptionBody,
            actionLabel: l10n.homeCardOpenFeature,
            onPressed: () => context.go(SubscriptionScreen.routePath),
          ),
          const SizedBox(height: AppSpacing.md),
          _FeatureNavCard(
            title: l10n.homeCardPrivacyTitle,
            body: l10n.homeCardPrivacyBody,
            actionLabel: l10n.homeCardOpenFeature,
            onPressed: () => context.go(PrivacyDashboardScreen.routePath),
          ),
          const SizedBox(height: AppSpacing.md),
          _FeatureNavCard(
            title: l10n.homeCardHelpTitle,
            body: l10n.homeCardHelpBody,
            actionLabel: l10n.homeCardOpenFeature,
            onPressed: () => context.go(HelpScreen.routePath),
          ),
        ],
      ),
    );
  }
}

class _FeatureNavCard extends StatelessWidget {
  const _FeatureNavCard({
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onPressed,
  });

  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(body),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton(
            onPressed: onPressed,
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}
