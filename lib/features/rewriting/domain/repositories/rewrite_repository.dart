import '../entities/correction_result.dart';

/// Contract for grammar correction and rewrite operations.
abstract interface class RewriteRepository {
  /// Corrects grammar and punctuation for the provided text.
  Future<CorrectionResult> correctGrammar(String text);
}
