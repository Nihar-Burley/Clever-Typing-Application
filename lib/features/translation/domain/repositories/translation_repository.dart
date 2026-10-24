import '../entities/translation_result.dart';

/// Contract for text translation operations.
abstract interface class TranslationRepository {
  /// Translates text into the target language.
  Future<TranslationResult> translate({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
    required bool preserveTone,
  });
}
