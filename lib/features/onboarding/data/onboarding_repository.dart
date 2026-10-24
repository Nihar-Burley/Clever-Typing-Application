import '../../../core/storage/app_preferences_store.dart';

/// Persists onboarding completion across app launches.
class OnboardingRepository {
  const OnboardingRepository(this._preferencesStore);

  static const String completionKey = 'onboarding_completed';

  final AppPreferencesStore _preferencesStore;

  Future<bool> isCompleted() async {
    return await _preferencesStore.readBool(completionKey) ?? false;
  }

  Future<void> setCompleted(bool value) {
    return _preferencesStore.writeBool(completionKey, value);
  }
}
