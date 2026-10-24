import '../../../core/config/remote_config_repository.dart';
import '../../../core/storage/app_preferences_store.dart';
import '../../../core/storage/privacy_repository.dart';
import '../presentation/models/plan_tier.dart';

class SubscriptionSnapshot {
  const SubscriptionSnapshot({
    required this.activePlan,
    required this.dailyQuota,
    required this.usedToday,
  });

  final PlanTier activePlan;
  final int dailyQuota;
  final int usedToday;

  int get remainingDailyActions {
    if (activePlan == PlanTier.premium) {
      return 999;
    }
    final int remaining = dailyQuota - usedToday;
    return remaining > 0 ? remaining : 0;
  }
}

class SubscriptionRepository {
  const SubscriptionRepository(
    this._preferencesStore,
    this._privacyRepository,
    this._remoteConfigRepository,
  );

  final AppPreferencesStore _preferencesStore;
  final PrivacyRepository _privacyRepository;
  final RemoteConfigRepository _remoteConfigRepository;

  static const String _planKey = 'subscription_active_plan';
  static const int _defaultFreeDailyQuota = 10;

  Future<SubscriptionSnapshot> load() async {
    final String? rawPlan = await _preferencesStore.readString(_planKey);
    final PlanTier activePlan = switch (rawPlan) {
      'premium' => PlanTier.premium,
      _ => PlanTier.free,
    };
    final int dailyQuota = await _resolveDailyQuota();
    final DateTime now = DateTime.now();
    final DateTime startOfDay = DateTime(now.year, now.month, now.day);
    final int usedToday = await _privacyRepository.countUsageSince(startOfDay);
    return SubscriptionSnapshot(
      activePlan: activePlan,
      dailyQuota: dailyQuota,
      usedToday: usedToday,
    );
  }

  Future<void> savePlan(PlanTier planTier) {
    return _preferencesStore.writeString(_planKey, planTier.name);
  }

  Future<void> restorePurchases() async {
    await load();
  }

  Future<int> _resolveDailyQuota() async {
    try {
      final flags = await _remoteConfigRepository.load();
      final Object? override = flags.toJson()['freeDailyQuota'];
      if (override is int && override > 0) {
        return override;
      }
    } catch (_) {
      // Keep the last-known local default if remote config is unavailable.
    }
    return _defaultFreeDailyQuota;
  }
}
