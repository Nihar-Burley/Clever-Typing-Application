import '../../../core/storage/app_preferences_store.dart';
import '../presentation/models/keyboard_settings_state.dart';

/// Persists keyboard settings between launches and restores them at startup.
class KeyboardSettingsRepository {
  const KeyboardSettingsRepository(this._preferencesStore);

  final AppPreferencesStore _preferencesStore;

  static const String _settingsKey = 'keyboard_settings';

  Future<KeyboardSettingsState> load() async {
    final Map<String, Object?>? stored =
        await _preferencesStore.readJson(_settingsKey);
    if (stored == null) {
      return KeyboardSettingsState.initial();
    }
    return KeyboardSettingsState.fromJson(stored);
  }

  Future<void> save(KeyboardSettingsState state) {
    return _preferencesStore.writeJson(_settingsKey, state.toJson());
  }
}
