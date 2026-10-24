import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/core_providers.dart';
import '../data/keyboard_settings_repository.dart';
import '../presentation/models/keyboard_settings_state.dart';

final Provider<KeyboardSettingsRepository> keyboardSettingsRepositoryProvider =
    Provider<KeyboardSettingsRepository>(
  (Ref ref) => KeyboardSettingsRepository(
    ref.watch(appPreferencesStoreProvider),
  ),
);

final NotifierProvider<KeyboardSettingsNotifier, KeyboardSettingsState>
    keyboardSettingsProvider =
    NotifierProvider<KeyboardSettingsNotifier, KeyboardSettingsState>(
  KeyboardSettingsNotifier.new,
);

/// Manages keyboard preference state.
class KeyboardSettingsNotifier extends Notifier<KeyboardSettingsState> {
  @override
  KeyboardSettingsState build() {
    Future<void>.microtask(_restore);
    return KeyboardSettingsState.initial();
  }

  void setAutoCapitalization(bool value) {
    state = state.copyWith(autoCapitalizationEnabled: value);
    _sync();
  }

  void setAutoSpace(bool value) {
    state = state.copyWith(autoSpaceEnabled: value);
    _sync();
  }

  void setHapticFeedback(bool value) {
    state = state.copyWith(hapticFeedbackEnabled: value);
    _sync();
  }

  void setSoundFeedback(bool value) {
    state = state.copyWith(soundFeedbackEnabled: value);
    _sync();
  }

  void setOneHandedMode(bool value) {
    state = state.copyWith(oneHandedModeEnabled: value);
    _sync();
  }

  void setKeyboardHeight(double value) {
    state = state.copyWith(keyboardHeight: value);
    _sync();
  }

  void setThemePalette(String value) {
    state = state.copyWith(themePalette: value);
    _sync();
  }

  void setPrimaryLanguage(String value) {
    state = state.copyWith(primaryLanguage: value);
    _sync();
  }

  void setSecondaryLanguage(String value) {
    state = state.copyWith(secondaryLanguage: value);
    _sync();
  }

  void setIncognitoMode(bool value) {
    state = state.copyWith(incognitoModeEnabled: value);
    _sync();
  }

  Future<void> _restore() async {
    final KeyboardSettingsState restored =
        await ref.read(keyboardSettingsRepositoryProvider).load();
    state = restored;
    await ref.read(keyboardPlatformServiceProvider).syncKeyboardSettings(state);
  }

  void _sync() {
    unawaited(
      Future.wait(<Future<void>>[
        ref.read(keyboardSettingsRepositoryProvider).save(state),
        ref.read(keyboardPlatformServiceProvider).syncKeyboardSettings(state),
      ]),
    );
  }
}
