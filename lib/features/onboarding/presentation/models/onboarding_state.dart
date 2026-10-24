import '../../domain/models/onboarding_step.dart';

/// Immutable UI state for the onboarding flow.
class OnboardingState {
  /// Creates the onboarding state.
  const OnboardingState({
    required this.currentStep,
    required this.completedSteps,
  });

  /// Initial state for the flow.
  factory OnboardingState.initial() {
    return const OnboardingState(
      currentStep: OnboardingStep.welcome,
      completedSteps: <OnboardingStep>{},
    );
  }

  /// Current visible step.
  final OnboardingStep currentStep;

  /// Tracks steps explicitly completed by the user.
  final Set<OnboardingStep> completedSteps;

  /// Creates a new state copy.
  OnboardingState copyWith({
    OnboardingStep? currentStep,
    Set<OnboardingStep>? completedSteps,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      completedSteps: completedSteps ?? this.completedSteps,
    );
  }
}
