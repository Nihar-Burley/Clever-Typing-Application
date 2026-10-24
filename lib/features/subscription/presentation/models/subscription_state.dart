import 'plan_tier.dart';

/// Immutable UI state for subscription and quota display.
class SubscriptionState {
  /// Creates subscription state.
  const SubscriptionState({
    required this.activePlan,
    required this.remainingDailyActions,
    required this.dailyQuota,
    required this.usedToday,
    required this.isLoading,
    required this.errorMessage,
  });

  /// Initial free-tier state.
  factory SubscriptionState.initial() {
    return const SubscriptionState(
      activePlan: PlanTier.free,
      remainingDailyActions: 10,
      dailyQuota: 10,
      usedToday: 0,
      isLoading: false,
      errorMessage: null,
    );
  }

  final PlanTier activePlan;
  final int remainingDailyActions;
  final int dailyQuota;
  final int usedToday;
  final bool isLoading;
  final String? errorMessage;

  /// Returns a modified copy.
  SubscriptionState copyWith({
    PlanTier? activePlan,
    int? remainingDailyActions,
    int? dailyQuota,
    int? usedToday,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SubscriptionState(
      activePlan: activePlan ?? this.activePlan,
      remainingDailyActions:
          remainingDailyActions ?? this.remainingDailyActions,
      dailyQuota: dailyQuota ?? this.dailyQuota,
      usedToday: usedToday ?? this.usedToday,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
