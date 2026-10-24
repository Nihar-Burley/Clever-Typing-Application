import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/core_providers.dart';
import '../data/onboarding_repository.dart';
import '../domain/models/onboarding_step.dart';
import '../presentation/models/onboarding_state.dart';

final Provider<OnboardingRepository> onboardingRepositoryProvider =
    Provider<OnboardingRepository>(
  (Ref ref) => OnboardingRepository(ref.watch(appPreferencesStoreProvider)),
);

final NotifierProvider<OnboardingNotifier, OnboardingState>
    onboardingProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(
  OnboardingNotifier.new,
);

/// Manages onboarding step transitions.
class OnboardingNotifier extends Notifier<OnboardingState> {
  @override
  OnboardingState build() {
    return OnboardingState.initial();
  }

  static const List<OnboardingStep> _orderedSteps = <OnboardingStep>[
    OnboardingStep.welcome,
    OnboardingStep.enableKeyboard,
    OnboardingStep.selectKeyboard,
    OnboardingStep.privacy,
  ];

  /// Advances to the next onboarding step.
  Future<void> continueFlow() async {
    final int currentIndex = _orderedSteps.indexOf(state.currentStep);
    final Set<OnboardingStep> completedSteps =
        Set<OnboardingStep>.from(state.completedSteps)
          ..add(state.currentStep);

    if (currentIndex == _orderedSteps.length - 1) {
      ref
          .read(appLoggerProvider)
          .info('Onboarding', 'complete', 'User completed setup flow');
      await ref.read(onboardingRepositoryProvider).setCompleted(true);
      state = state.copyWith(completedSteps: completedSteps);
      return;
    }

    state = state.copyWith(
      currentStep: _orderedSteps[currentIndex + 1],
      completedSteps: completedSteps,
    );
  }
}
