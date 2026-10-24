/// Immutable UI state for keyboard settings.
class KeyboardSettingsState {
  /// Creates settings state.
  const KeyboardSettingsState({
    required this.autoCapitalizationEnabled,
    required this.autoSpaceEnabled,
    required this.hapticFeedbackEnabled,
    required this.soundFeedbackEnabled,
    required this.oneHandedModeEnabled,
    required this.keyboardHeight,
    required this.themePalette,
    required this.primaryLanguage,
    required this.secondaryLanguage,
    required this.incognitoModeEnabled,
  });

  /// Initial defaults.
  factory KeyboardSettingsState.initial() {
    return const KeyboardSettingsState(
      autoCapitalizationEnabled: true,
      autoSpaceEnabled: true,
      hapticFeedbackEnabled: true,
      soundFeedbackEnabled: false,
      oneHandedModeEnabled: false,
      keyboardHeight: 1.0,
      themePalette: 'sunrise',
      primaryLanguage: 'English',
      secondaryLanguage: 'Hindi',
      incognitoModeEnabled: false,
    );
  }

  factory KeyboardSettingsState.fromJson(Map<String, Object?> json) {
    return KeyboardSettingsState(
      autoCapitalizationEnabled:
          json['autoCapitalizationEnabled'] as bool? ?? true,
      autoSpaceEnabled: json['autoSpaceEnabled'] as bool? ?? true,
      hapticFeedbackEnabled: json['hapticFeedbackEnabled'] as bool? ?? true,
      soundFeedbackEnabled: json['soundFeedbackEnabled'] as bool? ?? false,
      oneHandedModeEnabled: json['oneHandedModeEnabled'] as bool? ?? false,
      keyboardHeight: (json['keyboardHeight'] as num?)?.toDouble() ?? 1.0,
      themePalette: json['themePalette'] as String? ?? 'sunrise',
      primaryLanguage: json['primaryLanguage'] as String? ?? 'English',
      secondaryLanguage: json['secondaryLanguage'] as String? ?? 'Hindi',
      incognitoModeEnabled: json['incognitoModeEnabled'] as bool? ?? false,
    );
  }

  final bool autoCapitalizationEnabled;
  final bool autoSpaceEnabled;
  final bool hapticFeedbackEnabled;
  final bool soundFeedbackEnabled;
  final bool oneHandedModeEnabled;
  final double keyboardHeight;
  final String themePalette;
  final String primaryLanguage;
  final String secondaryLanguage;
  final bool incognitoModeEnabled;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'autoCapitalizationEnabled': autoCapitalizationEnabled,
      'autoSpaceEnabled': autoSpaceEnabled,
      'hapticFeedbackEnabled': hapticFeedbackEnabled,
      'soundFeedbackEnabled': soundFeedbackEnabled,
      'oneHandedModeEnabled': oneHandedModeEnabled,
      'keyboardHeight': keyboardHeight,
      'themePalette': themePalette,
      'primaryLanguage': primaryLanguage,
      'secondaryLanguage': secondaryLanguage,
      'incognitoModeEnabled': incognitoModeEnabled,
    };
  }

  /// Returns a copy with modified values.
  KeyboardSettingsState copyWith({
    bool? autoCapitalizationEnabled,
    bool? autoSpaceEnabled,
    bool? hapticFeedbackEnabled,
    bool? soundFeedbackEnabled,
    bool? oneHandedModeEnabled,
    double? keyboardHeight,
    String? themePalette,
    String? primaryLanguage,
    String? secondaryLanguage,
    bool? incognitoModeEnabled,
  }) {
    return KeyboardSettingsState(
      autoCapitalizationEnabled:
          autoCapitalizationEnabled ?? this.autoCapitalizationEnabled,
      autoSpaceEnabled: autoSpaceEnabled ?? this.autoSpaceEnabled,
      hapticFeedbackEnabled:
          hapticFeedbackEnabled ?? this.hapticFeedbackEnabled,
      soundFeedbackEnabled: soundFeedbackEnabled ?? this.soundFeedbackEnabled,
      oneHandedModeEnabled:
          oneHandedModeEnabled ?? this.oneHandedModeEnabled,
      keyboardHeight: keyboardHeight ?? this.keyboardHeight,
      themePalette: themePalette ?? this.themePalette,
      primaryLanguage: primaryLanguage ?? this.primaryLanguage,
      secondaryLanguage: secondaryLanguage ?? this.secondaryLanguage,
      incognitoModeEnabled:
          incognitoModeEnabled ?? this.incognitoModeEnabled,
    );
  }
}
