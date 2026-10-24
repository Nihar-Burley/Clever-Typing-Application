import 'package:flutter/services.dart';

import '../networking/ai_backend_config.dart';
import '../../features/keyboard_settings/presentation/models/keyboard_settings_state.dart';
import 'keyboard_platform_service.dart';
import 'models/keyboard_status.dart';

/// Method-channel implementation for Android keyboard integration.
class MethodChannelKeyboardPlatformService implements KeyboardPlatformService {
  static const MethodChannel _channel = MethodChannel('clever_typing/keyboard');

  @override
  Future<KeyboardStatus> getKeyboardStatus() async {
    final Map<Object?, Object?> result =
        await _channel.invokeMapMethod<Object?, Object?>('getKeyboardStatus') ??
            <Object?, Object?>{};

    return KeyboardStatus(
      isKeyboardEnabled: result['isKeyboardEnabled'] == true,
      isKeyboardSelected: result['isKeyboardSelected'] == true,
    );
  }

  @override
  Future<bool> isAccessibilityCaptureEnabled() async {
    return await _channel.invokeMethod<bool>('isAccessibilityCaptureEnabled') ??
        false;
  }

  @override
  Future<void> openAccessibilitySettings() {
    return _channel.invokeMethod<void>('openAccessibilitySettings');
  }

  @override
  Future<String?> readLatestConversationContext() {
    return _channel.invokeMethod<String>('readLatestConversationContext');
  }

  @override
  Future<Map<String, Object?>> readNativeStatus() async {
    final Map<Object?, Object?> result =
        await _channel.invokeMapMethod<Object?, Object?>('readNativeStatus') ??
            <Object?, Object?>{};
    return result.map(
      (Object? key, Object? value) =>
          MapEntry<String, Object?>(key.toString(), value),
    );
  }

  @override
  Future<void> clearNativeData() {
    return _channel.invokeMethod<void>('clearNativeData');
  }

  @override
  Future<void> syncPinnedAssistant(String? assistantId) {
    return _channel.invokeMethod<void>(
      'syncPinnedAssistant',
      <String, Object?>{
        'assistantId': assistantId,
      },
    );
  }

  @override
  Future<void> openKeyboardSettings() {
    return _channel.invokeMethod<void>('openKeyboardSettings');
  }

  @override
  Future<void> showInputMethodPicker() {
    return _channel.invokeMethod<void>('showInputMethodPicker');
  }

  @override
  Future<void> syncKeyboardSettings(KeyboardSettingsState state) {
    return _channel.invokeMethod<void>(
      'syncKeyboardSettings',
      <String, Object>{
        'autoCapitalizationEnabled': state.autoCapitalizationEnabled,
        'autoSpaceEnabled': state.autoSpaceEnabled,
        'hapticFeedbackEnabled': state.hapticFeedbackEnabled,
        'soundFeedbackEnabled': state.soundFeedbackEnabled,
        'oneHandedModeEnabled': state.oneHandedModeEnabled,
        'keyboardHeight': state.keyboardHeight,
        'themePalette': state.themePalette,
        'primaryLanguage': state.primaryLanguage,
        'secondaryLanguage': state.secondaryLanguage,
        'incognitoModeEnabled': state.incognitoModeEnabled,
      },
    );
  }

  @override
  Future<void> syncBackendConfig(AiBackendConfig config) {
    return _channel.invokeMethod<void>(
      'syncBackendConfig',
      <String, Object>{
        'baseUrl': config.baseUrl,
        'apiKey': config.apiKey,
      },
    );
  }
}
