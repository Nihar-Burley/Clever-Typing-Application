import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../analytics/analytics_service.dart';
import '../analytics/console_analytics_service.dart';
import '../config/remote_config_repository.dart';
import '../logging/app_logger.dart';
import '../logging/console_app_logger.dart';
import '../networking/ai_backend_config.dart';
import '../networking/ai_http_client.dart';
import '../networking/dart_ai_http_client.dart';
import '../platform/keyboard_platform_service.dart';
import '../platform/method_channel_keyboard_platform_service.dart';
import '../storage/app_database.dart';
import '../storage/app_preferences_store.dart';
import '../storage/privacy_repository.dart';
import '../storage/secure_token_store.dart';

final Provider<AppLogger> appLoggerProvider = Provider<AppLogger>(
  (Ref<AppLogger> ref) => ConsoleAppLogger(),
);

final Provider<AnalyticsService> analyticsServiceProvider =
    Provider<AnalyticsService>(
  (Ref<AnalyticsService> ref) => ConsoleAnalyticsService(
    ref.watch(appLoggerProvider),
  ),
);

final Provider<AiBackendConfig> aiBackendConfigProvider =
    Provider<AiBackendConfig>(
  (Ref<AiBackendConfig> ref) => AiBackendConfig.fromEnvironment(),
);

final Provider<AppPreferencesStore> appPreferencesStoreProvider =
    Provider<AppPreferencesStore>(
  (Ref<AppPreferencesStore> ref) => const AppPreferencesStore(),
);

final Provider<AppDatabase> appDatabaseProvider = Provider<AppDatabase>(
  (Ref<AppDatabase> ref) => AppDatabase(),
);

final Provider<PrivacyRepository> privacyRepositoryProvider =
    Provider<PrivacyRepository>(
  (Ref<PrivacyRepository> ref) => PrivacyRepository(
    ref.watch(appDatabaseProvider),
  ),
);

final Provider<FlutterSecureStorage> flutterSecureStorageProvider =
    Provider<FlutterSecureStorage>(
  (Ref<FlutterSecureStorage> ref) => const FlutterSecureStorage(),
);

final Provider<SecureTokenStore> secureTokenStoreProvider =
    Provider<SecureTokenStore>(
  (Ref<SecureTokenStore> ref) => SecureTokenStore(
    ref.watch(flutterSecureStorageProvider),
  ),
);

final Provider<AiHttpClient> aiHttpClientProvider = Provider<AiHttpClient>(
  (Ref<AiHttpClient> ref) => DartAiHttpClient(
    ref.watch(aiBackendConfigProvider),
    ref.watch(secureTokenStoreProvider),
    ref.watch(analyticsServiceProvider),
  ),
);

final Provider<RemoteConfigRepository> remoteConfigRepositoryProvider =
    Provider<RemoteConfigRepository>(
  (Ref<RemoteConfigRepository> ref) => RemoteConfigRepository(
    ref.watch(aiHttpClientProvider),
    ref.watch(appPreferencesStoreProvider),
  ),
);

final Provider<KeyboardPlatformService> keyboardPlatformServiceProvider =
    Provider<KeyboardPlatformService>(
  (Ref<KeyboardPlatformService> ref) => MethodChannelKeyboardPlatformService(),
);
