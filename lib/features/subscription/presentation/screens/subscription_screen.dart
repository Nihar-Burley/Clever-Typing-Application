import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_section_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../providers/subscription_provider.dart';
import '../models/plan_tier.dart';
import '../models/subscription_state.dart';

/// Screen showing the current plan and premium value.
class SubscriptionScreen extends ConsumerWidget {
  /// Creates the subscription screen.
  const SubscriptionScreen({super.key});

  static const String routeName = 'subscription';
  static const String routePath = '/subscription';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final SubscriptionState state = ref.watch(subscriptionProvider);
    final SubscriptionNotifier notifier = ref.read(subscriptionProvider.notifier);
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isPremium = state.activePlan == PlanTier.premium;
    final double progress = isPremium || state.dailyQuota <= 0
        ? 1
        : (state.usedToday / state.dailyQuota).clamp(0, 1).toDouble();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.subscriptionTitle),
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
                  colorScheme.primary,
                  colorScheme.primary.withValues(alpha: 0.78),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _PlanBadge(
                  label: isPremium
                      ? l10n.subscriptionPremiumPlan
                      : l10n.subscriptionFreePlan,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.subscriptionHeadline,
                  style: textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.subscriptionBody,
                  style: textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _MetricCard(
                        title: 'Remaining',
                        value: isPremium
                            ? 'Unlimited'
                            : state.remainingDailyActions.toString(),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _MetricCard(
                        title: 'Used today',
                        value: state.usedToday.toString(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: Colors.white.withValues(alpha: 0.18),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.subscriptionUsageToday(
                    state.usedToday,
                    state.dailyQuota,
                  ),
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
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
                Text(
                  l10n.subscriptionPlansTitle,
                  style: textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Switch between the free daily quota model and the premium unlocked model used by the companion app.',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                SegmentedButton<PlanTier>(
                  segments: <ButtonSegment<PlanTier>>[
                    ButtonSegment<PlanTier>(
                      value: PlanTier.free,
                      label: Text(l10n.subscriptionFreePlan),
                    ),
                    ButtonSegment<PlanTier>(
                      value: PlanTier.premium,
                      label: Text(l10n.subscriptionPremiumPlan),
                    ),
                  ],
                  selected: <PlanTier>{state.activePlan},
                  onSelectionChanged: state.isLoading
                      ? null
                      : (Set<PlanTier> selection) {
                          notifier.selectPlan(selection.first);
                        },
                ),
                const SizedBox(height: AppSpacing.lg),
                _PlanDetailsCard(
                  icon: Icons.bolt_outlined,
                  title: l10n.subscriptionFreePlan,
                  subtitle: l10n.subscriptionFeatureFree,
                ),
                const SizedBox(height: AppSpacing.sm),
                _PlanDetailsCard(
                  icon: Icons.workspace_premium_outlined,
                  title: l10n.subscriptionPremiumPlan,
                  subtitle: l10n.subscriptionFeaturePremium,
                ),
                const SizedBox(height: AppSpacing.sm),
                _PlanDetailsCard(
                  icon: Icons.auto_awesome_outlined,
                  title: 'Premium roadmap',
                  subtitle: l10n.subscriptionFeatureSmartReply,
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: <Widget>[
                    OutlinedButton.icon(
                      onPressed: state.isLoading ? null : notifier.refresh,
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.subscriptionRefreshAction),
                    ),
                    ElevatedButton.icon(
                      onPressed:
                          state.isLoading ? null : notifier.restorePurchases,
                      icon: const Icon(Icons.restore),
                      label: Text(l10n.subscriptionRestorePurchases),
                    ),
                  ],
                ),
                if (state.isLoading) ...<Widget>[
                  const SizedBox(height: AppSpacing.md),
                  const LinearProgressIndicator(),
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
        ],
      ),
    );
  }
}

class _PlanBadge extends StatelessWidget {
  const _PlanBadge({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.88),
                ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                ),
          ),
        ],
      ),
    );
  }
}

class _PlanDetailsCard extends StatelessWidget {
  const _PlanDetailsCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
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
                Text(subtitle, style: textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
