/// Result returned by the grammar correction use case.
class CorrectionResult {
  /// Creates a correction result.
  const CorrectionResult({
    required this.originalText,
    required this.correctedText,
  });

  /// Original user-provided content.
  final String originalText;

  /// Corrected text returned by the processor.
  final String correctedText;
}
