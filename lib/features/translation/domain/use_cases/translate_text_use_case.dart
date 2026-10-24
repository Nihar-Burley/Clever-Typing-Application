import '../entities/translation_result.dart';
import '../repositories/translation_repository.dart';

/// Executes text translation using the active repository.
class TranslateTextUseCase {
  /// Creates the use case.
  const TranslateTextUseCase(this._repository);

  final TranslationRepository _repository;

  /// Translates input text.
  Future<TranslationResult> call({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
    required bool preserveTone,
  }) {
    return _repository.translate(
      text: text,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      preserveTone: preserveTone,
    );
  }
}
