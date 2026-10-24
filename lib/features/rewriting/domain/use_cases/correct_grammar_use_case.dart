import '../entities/correction_result.dart';
import '../repositories/rewrite_repository.dart';

/// Executes grammar correction against the active rewrite repository.
class CorrectGrammarUseCase {
  /// Creates the use case.
  const CorrectGrammarUseCase(this._repository);

  final RewriteRepository _repository;

  /// Corrects the input text.
  Future<CorrectionResult> call(String text) {
    return _repository.correctGrammar(text);
  }
}
