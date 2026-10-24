import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/di/core_providers.dart';
import '../../../../core/platform/models/keyboard_status.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../domain/models/onboarding_step.dart';
import '../models/onboarding_state.dart';
import '../../providers/onboarding_provider.dart';
import '../widgets/onboarding_step_content.dart';

/// Initial setup flow for the keyboard app.
class OnboardingScreen extends ConsumerStatefulWidget {
  /// Creates the onboarding screen.
  const OnboardingScreen({super.key});

  static const String routeName = 'onboarding';
  static const String routePath = '/';

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with WidgetsBindingObserver {
  String? _supportingNote;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncKeyboardStatus();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncKeyboardStatus();
    }
  }

  void _setBusy(bool value) {
    if (!mounted) {
      return;
    }
    setState(() {
      _isBusy = value;
    });
  }

  void _setSupportingNote(String? value) {
    if (!mounted) {
      return;
    }
    setState(() {
      _supportingNote = value;
    });
  }

  Future<void> _syncKeyboardStatus() async {
    final OnboardingState onboardingState = ref.read(onboardingProvider);
    if (onboardingState.currentStep == OnboardingStep.welcome ||
        onboardingState.currentStep == OnboardingStep.privacy) {
      return;
    }

    _setBusy(true);
    try {
      final KeyboardStatus status =
          await ref.read(keyboardPlatformServiceProvider).getKeyboardStatus();
      final OnboardingNotifier notifier = ref.read(onboardingProvider.notifier);

      if (onboardingState.currentStep == OnboardingStep.enableKeyboard) {
        if (status.isKeyboardEnabled) {
          _setSupportingNote(null);
          await notifier.continueFlow();
          return;
        }
        _setSupportingNote(AppLocalizations.of(context).onboardingEnableKeyboardPending);
        return;
      }

      if (status.isKeyboardSelected) {
        _setSupportingNote(null);
        await notifier.continueFlow();
        return;
      }
      _setSupportingNote(AppLocalizations.of(context).onboardingSelectKeyboardPending);
    } finally {
      _setBusy(false);
    }
  }

  Future<void> _handleStepAction(OnboardingStep step) async {
    final OnboardingNotifier notifier = ref.read(onboardingProvider.notifier);

    switch (step) {
      case OnboardingStep.welcome:
        await notifier.continueFlow();
        return;
      case OnboardingStep.enableKeyboard:
        _setSupportingNote(AppLocalizations.of(context).onboardingEnableKeyboardPending);
        await ref.read(keyboardPlatformServiceProvider).openKeyboardSettings();
        return;
      case OnboardingStep.selectKeyboard:
        _setSupportingNote(AppLocalizations.of(context).onboardingSelectKeyboardPending);
        _setBusy(true);
        try {
          await ref.read(keyboardPlatformServiceProvider).showInputMethodPicker();
          await Future<void>.delayed(const Duration(milliseconds: 350));
          await _syncKeyboardStatus();
        } finally {
          _setBusy(false);
        }
        return;
      case OnboardingStep.privacy:
        await notifier.continueFlow();
        return;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    ref.listen<OnboardingState>(
      onboardingProvider,
      (previous, next) {
        if (next.completedSteps.length == OnboardingStep.values.length) {
          context.go(HomeScreen.routePath);
        }
        if (previous?.currentStep != next.currentStep) {
          if (next.currentStep == OnboardingStep.enableKeyboard) {
            _setSupportingNote(l10n.onboardingEnableKeyboardPrompt);
          } else if (next.currentStep == OnboardingStep.selectKeyboard) {
            _setSupportingNote(l10n.onboardingSelectKeyboardPrompt);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _syncKeyboardStatus();
            });
          } else {
            _setSupportingNote(null);
          }
        }
      },
    );
    final OnboardingState state = ref.watch(onboardingProvider);

    final (_OnboardingCopy copy, int index) = switch (state.currentStep) {
      OnboardingStep.welcome => (
          _OnboardingCopy(
            eyebrow: l10n.onboardingStepWelcomeEyebrow,
            title: l10n.onboardingStepWelcomeTitle,
            body: l10n.onboardingStepWelcomeBody,
            buttonLabel: l10n.onboardingContinue,
          ),
          0,
        ),
      OnboardingStep.enableKeyboard => (
          _OnboardingCopy(
            eyebrow: l10n.onboardingStepEnableEyebrow,
            title: l10n.onboardingStepEnableTitle,
            body: l10n.onboardingStepEnableBody,
            buttonLabel: l10n.onboardingEnableKeyboardAction,
          ),
          1,
        ),
      OnboardingStep.selectKeyboard => (
          _OnboardingCopy(
            eyebrow: l10n.onboardingStepSelectEyebrow,
            title: l10n.onboardingStepSelectTitle,
            body: l10n.onboardingStepSelectBody,
            buttonLabel: l10n.onboardingSelectKeyboardAction,
          ),
          2,
        ),
      OnboardingStep.privacy => (
          _OnboardingCopy(
            eyebrow: l10n.onboardingStepPrivacyEyebrow,
            title: l10n.onboardingStepPrivacyTitle,
            body: l10n.onboardingStepPrivacyBody,
            buttonLabel: l10n.onboardingFinish,
          ),
          3,
        ),
    };

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _OnboardingProgress(index: index),
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: OnboardingStepContent(
                  eyebrow: copy.eyebrow,
                  title: copy.title,
                  body: copy.body,
                  buttonLabel: copy.buttonLabel,
                  supportingNote: _supportingNote,
                  isBusy: _isBusy,
                  onPressed: () {
                    _handleStepAction(state.currentStep);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingProgress extends StatelessWidget {
  const _OnboardingProgress({
    required this.index,
  });

  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List<Widget>.generate(
        OnboardingStep.values.length,
        (int itemIndex) => Expanded(
          child: Container(
            height: 6,
            margin: EdgeInsets.only(
              right: itemIndex == OnboardingStep.values.length - 1
                  ? 0
                  : AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: itemIndex <= index
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingCopy {
  const _OnboardingCopy({
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.buttonLabel,
  });

  final String eyebrow;
  final String title;
  final String body;
  final String buttonLabel;
}
