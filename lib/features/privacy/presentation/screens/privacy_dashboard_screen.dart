import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_section_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../providers/privacy_dashboard_provider.dart';

/// Presents privacy promises and permission guidance.
class PrivacyDashboardScreen extends ConsumerWidget {
  /// Creates the privacy dashboard screen.
  const PrivacyDashboardScreen({super.key});

  static const String routeName = 'privacy-dashboard';
  static const String routePath = '/privacy';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final TextTheme textTheme = Theme.of(context).textTheme;
    final PrivacyDashboardState state = ref.watch(privacyDashboardProvider);
    final PrivacyDashboardNotifier notifier =
        ref.read(privacyDashboardProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.privacyTitle),
        actions: <Widget>[
          IconButton(
            onPressed: notifier.refresh,
            icon: const Icon(Icons.refresh),
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
                  l10n.privacyHeadline,
                  style: textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(l10n.privacyBody),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Live privacy status',
                  style: textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                if (state.isLoading)
                  const CircularProgressIndicator()
                else ...<Widget>[
                  Text(
                    'Accessibility enabled: '
                    '${state.nativeStatus['isAccessibilityEnabled'] == true ? 'Yes' : 'No'}',
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Incognito mode: '
                    '${state.nativeStatus['incognitoModeEnabled'] == true ? 'On' : 'Off'}',
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Sensitive-field blocks: '
                    '${state.nativeStatus['blockedSensitiveActions'] ?? 0}',
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Native AI executions: '
                    '${state.nativeStatus['nativeAiExecutions'] ?? 0}',
                  ),
                ],
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
          AppSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  l10n.privacyRulesTitle,
                  style: textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(l10n.privacyRuleLocalTyping),
                const SizedBox(height: AppSpacing.xs),
                Text(l10n.privacyRuleExplicitAi),
                const SizedBox(height: AppSpacing.xs),
                Text(l10n.privacyRuleSensitiveFields),
                const SizedBox(height: AppSpacing.xs),
                Text(l10n.privacyRuleAccessibility),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Data controls', style: textTheme.titleLarge),
                const SizedBox(height: AppSpacing.sm),
                ElevatedButton(
                  onPressed: () async {
                    await notifier.exportData();
                    if (!context.mounted) {
                      return;
                    }
                    final String exportText =
                        ref.read(privacyDashboardProvider).exportJson ?? '';
                    await showDialog<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Exported data'),
                          content: SingleChildScrollView(
                            child: SelectableText(exportText),
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Close'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const Text('Export data'),
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton(
                  onPressed: notifier.clearAllData,
                  child: const Text('Delete local data'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Recent usage', style: textTheme.titleLarge),
                const SizedBox(height: AppSpacing.sm),
                ...state.usageHistory.take(5).map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Text(
                          '${entry.feature} / ${entry.action} / '
                          '${entry.wasSuccessful ? 'success' : 'failure'}',
                        ),
                      ),
                    ),
                if (state.usageHistory.isEmpty) const Text('No usage yet.'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Consent log', style: textTheme.titleLarge),
                const SizedBox(height: AppSpacing.sm),
                ...state.consentLogs.take(5).map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Text(
                          '${entry.consentType} / '
                          '${entry.wasGranted ? 'granted' : 'denied'}',
                        ),
                      ),
                    ),
                if (state.consentLogs.isEmpty) const Text('No consent events yet.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
