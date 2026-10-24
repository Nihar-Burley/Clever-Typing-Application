import '../networking/ai_backend_paths.dart';
import '../networking/ai_http_client.dart';
import '../storage/app_preferences_store.dart';
import 'feature_flags.dart';

/// Loads and caches remote feature flags.
class RemoteConfigRepository {
  const RemoteConfigRepository(
    this._client,
    this._preferencesStore,
  );

  final AiHttpClient _client;
  final AppPreferencesStore _preferencesStore;

  Future<FeatureFlags> load() async {
    final Map<String, Object?>? cached =
        await _preferencesStore.readJson('feature_flags');
    final FeatureFlags fallback =
        cached == null ? FeatureFlags.defaults() : FeatureFlags.fromJson(cached);

    try {
      final Map<String, dynamic> response = await _client.getJson(
        AiBackendPaths.featureFlags,
      );
      final FeatureFlags flags = FeatureFlags.fromJson(response);
      await _preferencesStore.writeJson('feature_flags', flags.toJson());
      return flags;
    } catch (_) {
      return fallback;
    }
  }
}
