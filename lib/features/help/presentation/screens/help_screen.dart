import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_section_card.dart';
import '../../../../l10n/app_localizations.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const String routeName = 'help';
  static const String routePath = '/help';

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.helpTitle),
      ),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                colors: <Color>[
                  colorScheme.secondary,
                  colorScheme.primary.withValues(alpha: 0.82),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  l10n.helpHeadline,
                  style: textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.helpBody,
                  style: textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    l10n.helpSupportEmail,
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Quick start', style: textTheme.titleLarge),
                const SizedBox(height: AppSpacing.md),
                const _SupportStep(
                  number: '1',
                  title: 'Enable the keyboard',
                  body: 'Open Android input settings and turn on Clever Typing as an available keyboard.',
                ),
                const SizedBox(height: AppSpacing.sm),
                const _SupportStep(
                  number: '2',
                  title: 'Switch to Clever Typing',
                  body: 'Use the system input picker from any text field to make the keyboard active.',
                ),
                const SizedBox(height: AppSpacing.sm),
                const _SupportStep(
                  number: '3',
                  title: 'Grant only the needed permissions',
                  body: 'Accessibility is only required for smart reply. Core typing and most app flows work without it.',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(l10n.helpFaqTitle, style: textTheme.titleLarge),
                const SizedBox(height: AppSpacing.md),
                _FaqTile(
                  icon: Icons.keyboard_alt_outlined,
                  title: l10n.helpFaqEnableKeyboardQuestion,
                  body: l10n.helpFaqEnableKeyboardAnswer,
                ),
                const SizedBox(height: AppSpacing.sm),
                _FaqTile(
                  icon: Icons.privacy_tip_outlined,
                  title: l10n.helpFaqAiQuestion,
                  body: l10n.helpFaqAiAnswer,
                ),
                const SizedBox(height: AppSpacing.sm),
                _FaqTile(
                  icon: Icons.bar_chart_outlined,
                  title: l10n.helpFaqQuotaQuestion,
                  body: l10n.helpFaqQuotaAnswer,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(l10n.helpSupportTitle, style: textTheme.titleLarge),
                const SizedBox(height: AppSpacing.sm),
                Text(l10n.helpSupportBody),
                const SizedBox(height: AppSpacing.sm),
                SelectableText(l10n.helpSupportEmail),
                const SizedBox(height: AppSpacing.md),
                const _SupportChecklist(
                  items: <String>[
                    'Device model and Android version',
                    'Whether the issue is in onboarding, typing, AI actions, or permissions',
                    'Whether the device is on guest, email, or Google profile mode',
                    'Any error message shown in the app or keyboard',
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportStep extends StatelessWidget {
  const _SupportStep({
    required this.number,
    required this.title,
    required this.body,
  });

  final String number;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            number,
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(body, style: textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: colorScheme.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(body, style: textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportChecklist extends StatelessWidget {
  const _SupportChecklist({
    required this.items,
  });

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (String item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(
                    Icons.check_circle_outline,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(item, style: textTheme.bodyMedium),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
