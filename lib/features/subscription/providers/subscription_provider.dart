import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/core_providers.dart';
import '../data/subscription_repository.dart';
import '../presentation/models/plan_tier.dart';
import '../presentation/models/subscription_state.dart';

final Provider<SubscriptionRepository> subscriptionRepositoryProvider =
    Provider<SubscriptionRepository>(
  (Ref<SubscriptionRepository> ref) => SubscriptionRepository(
    ref.watch(appPreferencesStoreProvider),
    ref.watch(privacyRepositoryProvider),
    ref.watch(remoteConfigRepositoryProvider),
  ),
);

final NotifierProvider<SubscriptionNotifier, SubscriptionState>
    subscriptionProvider =
    NotifierProvider<SubscriptionNotifier, SubscriptionState>(
  SubscriptionNotifier.new,
);

/// Manages active entitlement state.
class SubscriptionNotifier extends Notifier<SubscriptionState> {
  @override
  SubscriptionState build() {
    Future<void>.microtask(refresh);
    return SubscriptionState.initial();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final snapshot = await ref.read(subscriptionRepositoryProvider).load();
      state = state.copyWith(
        activePlan: snapshot.activePlan,
        remainingDailyActions: snapshot.remainingDailyActions,
        dailyQuota: snapshot.dailyQuota,
        usedToday: snapshot.usedToday,
        isLoading: false,
        clearError: true,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to load subscription state right now.',
      );
    }
  }

  Future<void> selectPlan(PlanTier planTier) async {
    await ref.read(subscriptionRepositoryProvider).savePlan(planTier);
    await refresh();
  }

  Future<void> restorePurchases() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(subscriptionRepositoryProvider).restorePurchases();
      await refresh();
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to restore purchases right now.',
      );
    }
  }
}

final Provider<AiQuotaGuard> aiQuotaGuardProvider = Provider<AiQuotaGuard>(
  (Ref<AiQuotaGuard> ref) => AiQuotaGuard(ref),
);

class AiQuotaGuard {
  const AiQuotaGuard(this._ref);

  final Ref _ref;

  Future<String?> validateBeforeAiAction() async {
    final snapshot = await _ref.read(subscriptionRepositoryProvider).load();
    if (snapshot.activePlan == PlanTier.premium) {
      return null;
    }
    if (snapshot.remainingDailyActions <= 0) {
      return 'Daily AI quota reached. Upgrade to Premium or try again tomorrow.';
    }
    return null;
  }
}
