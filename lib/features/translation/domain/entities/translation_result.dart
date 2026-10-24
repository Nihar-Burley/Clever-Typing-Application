class TranslationResult {
  const TranslationResult({
    required this.translatedText,
    this.detectedSourceLanguage,
  });

  final String translatedText;
  final String? detectedSourceLanguage;
}
