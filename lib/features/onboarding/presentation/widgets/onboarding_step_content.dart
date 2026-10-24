import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';

/// Reusable content block for a single onboarding step.
class OnboardingStepContent extends StatelessWidget {
  /// Creates step content.
  const OnboardingStepContent({
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.buttonLabel,
    required this.onPressed,
    this.supportingNote,
    this.isBusy = false,
    super.key,
  });

  /// Small section label above the title.
  final String eyebrow;

  /// Main heading.
  final String title;

  /// Supporting text.
  final String body;

  /// Primary action label.
  final String buttonLabel;

  /// Tap handler for the primary action.
  final VoidCallback onPressed;

  /// Optional note shown below the body copy.
  final String? supportingNote;

  /// Whether the primary action is currently busy.
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          eyebrow,
          style: textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          title,
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          body,
          style: textTheme.bodyLarge,
        ),
        if (supportingNote != null) ...<Widget>[
          const SizedBox(height: AppSpacing.md),
          Text(
            supportingNote!,
            style: textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
        const Spacer(),
        ElevatedButton(
          onPressed: isBusy ? null : onPressed,
          child: isBusy
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(buttonLabel),
        ),
      ],
    );
  }
}
