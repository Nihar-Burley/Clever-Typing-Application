import '../networking/ai_backend_config.dart';
import '../../features/keyboard_settings/presentation/models/keyboard_settings_state.dart';
import 'models/keyboard_status.dart';

/// Contract for platform-specific keyboard actions and status.
abstract interface class KeyboardPlatformService {
  /// Opens Android input-method settings.
  Future<void> openKeyboardSettings();

  /// Shows the Android input-method picker.
  Future<void> showInputMethodPicker();

  /// Reads current activation status of the keyboard.
  Future<KeyboardStatus> getKeyboardStatus();

  /// Returns whether accessibility-based conversation capture is enabled.
  Future<bool> isAccessibilityCaptureEnabled();

  /// Opens Android accessibility settings.
  Future<void> openAccessibilitySettings();

  /// Reads the latest captured conversation context.
  Future<String?> readLatestConversationContext();

  /// Reads native keyboard privacy metrics and current settings.
  Future<Map<String, Object?>> readNativeStatus();

  /// Clears keyboard-side cached privacy data and counters.
  Future<void> clearNativeData();

  /// Syncs the assistant pinned for quick execution from the native IME.
  Future<void> syncPinnedAssistant(String? assistantId);

  /// Writes keyboard preferences so native IME code can read them.
  Future<void> syncKeyboardSettings(KeyboardSettingsState state);

  /// Writes runtime backend settings so native keyboard actions can reach
  /// the same AI service contract as the Flutter host app.
  Future<void> syncBackendConfig(AiBackendConfig config);
}
