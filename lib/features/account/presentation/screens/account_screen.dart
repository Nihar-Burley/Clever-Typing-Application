import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_section_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../providers/account_provider.dart';
import '../models/account_state.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  static const String routeName = 'account';
  static const String routePath = '/account';

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AccountState state = ref.watch(accountProvider);
    final AccountNotifier notifier = ref.read(accountProvider.notifier);
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    if (_nameController.text.isEmpty && !state.isGuest) {
      _nameController.text = state.displayName;
      _emailController.text = state.email;
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.accountTitle)),
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
                  colorScheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
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
                    state.mode.name.toUpperCase(),
                    style: textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.accountHeadline,
                  style: textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.accountBody,
                  style: textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: <Widget>[
                    _InfoChip(
                      icon: Icons.person_outline,
                      label: state.displayName,
                      dark: true,
                    ),
                    _InfoChip(
                      icon: Icons.alternate_email,
                      label: state.email.isEmpty ? 'No email linked' : state.email,
                      dark: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(l10n.accountManageTitle, style: textTheme.titleLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Pick the account mode that should back this device. Guest mode keeps the host app usable without connecting an identity.',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                _ModeCard(
                  title: 'Guest mode',
                  subtitle: 'Best for local keyboard setup and private testing.',
                  icon: Icons.lock_outline,
                  isSelected: state.mode == AccountMode.guest,
                ),
                const SizedBox(height: AppSpacing.sm),
                _ModeCard(
                  title: 'Email profile',
                  subtitle: 'Save a direct email identity for account and quota flows.',
                  icon: Icons.mail_outline,
                  isSelected: state.mode == AccountMode.email,
                ),
                const SizedBox(height: AppSpacing.sm),
                _ModeCard(
                  title: 'Google profile',
                  subtitle: 'Prepare the device for a future real Google sign-in integration.',
                  icon: Icons.account_circle_outlined,
                  isSelected: state.mode == AccountMode.google,
                ),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.accountNameLabel,
                    prefixIcon: const Icon(Icons.badge_outlined),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: l10n.accountEmailLabel,
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: state.isLoading
                          ? null
                          : () => notifier.signInWithEmail(
                                displayName: _nameController.text,
                                email: _emailController.text,
                              ),
                      child: Text(l10n.accountEmailAction),
                    ),
                    OutlinedButton(
                      onPressed: state.isLoading
                          ? null
                          : () => notifier.connectGoogleProfile(
                                displayName: _nameController.text,
                                email: _emailController.text,
                              ),
                      child: Text(l10n.accountGoogleAction),
                    ),
                    TextButton(
                      onPressed:
                          state.isLoading ? null : notifier.continueAsGuest,
                      child: Text(l10n.accountGuestAction),
                    ),
                    if (!state.isGuest)
                      TextButton(
                        onPressed: state.isLoading ? null : notifier.signOut,
                        child: Text(l10n.accountSignOutAction),
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
          const SizedBox(height: AppSpacing.lg),
          AppSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Trust model', style: textTheme.titleLarge),
                const SizedBox(height: AppSpacing.md),
                const _TrustBullet(
                  icon: Icons.verified_user_outlined,
                  title: 'Identity stays local-first',
                  body: 'This MVP stores the selected account mode on device so onboarding, quota, and support flows remain coherent.',
                ),
                const SizedBox(height: AppSpacing.sm),
                const _TrustBullet(
                  icon: Icons.cloud_off_outlined,
                  title: 'No silent account dependency',
                  body: 'Guest mode remains valid, and keyboard core features continue to work even without a linked identity.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isSelected
            ? colorScheme.primary.withValues(alpha: 0.08)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.35)
              : colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
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
          Icon(
            isSelected ? Icons.check_circle : Icons.circle_outlined,
            color: isSelected ? colorScheme.primary : colorScheme.outline,
          ),
        ],
      ),
    );
  }
}

class _TrustBullet extends StatelessWidget {
  const _TrustBullet({
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.secondary.withValues(alpha: 0.14),
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
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    this.dark = false,
  });

  final IconData icon;
  final String label;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final Color color = dark ? Colors.white : Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: dark
            ? Colors.white.withValues(alpha: 0.14)
            : Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
