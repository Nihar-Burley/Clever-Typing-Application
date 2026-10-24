/// Immutable UI state for translation.
class TranslationState {
  /// Creates translation state.
  const TranslationState({
    required this.inputText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.preserveTone,
    required this.isSubmitting,
    required this.translatedText,
    required this.detectedSourceLanguage,
    required this.errorMessage,
  });

  /// Initial state.
  factory TranslationState.initial() {
    return const TranslationState(
      inputText: '',
      sourceLanguage: 'Auto Detect',
      targetLanguage: 'Spanish',
      preserveTone: true,
      isSubmitting: false,
      translatedText: null,
      detectedSourceLanguage: null,
      errorMessage: null,
    );
  }

  /// Raw user text.
  final String inputText;

  /// Source language or auto detect marker.
  final String sourceLanguage;

  /// Selected translation target.
  final String targetLanguage;

  /// Preserve original tone while translating.
  final bool preserveTone;

  /// Whether translation is running.
  final bool isSubmitting;

  /// Latest translation output.
  final String? translatedText;

  /// Detected source language from the backend.
  final String? detectedSourceLanguage;

  /// User-safe error.
  final String? errorMessage;

  /// Copies the state with changes.
  TranslationState copyWith({
    String? inputText,
    String? sourceLanguage,
    String? targetLanguage,
    bool? preserveTone,
    bool? isSubmitting,
    String? translatedText,
    String? detectedSourceLanguage,
    bool clearTranslatedText = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TranslationState(
      inputText: inputText ?? this.inputText,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      preserveTone: preserveTone ?? this.preserveTone,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      translatedText: clearTranslatedText
          ? null
          : (translatedText ?? this.translatedText),
      detectedSourceLanguage: clearTranslatedText
          ? null
          : (detectedSourceLanguage ?? this.detectedSourceLanguage),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
