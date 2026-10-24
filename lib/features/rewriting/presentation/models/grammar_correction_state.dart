import '../../domain/entities/correction_result.dart';

/// Immutable UI state for the grammar correction feature.
class GrammarCorrectionState {
  /// Creates feature state.
  const GrammarCorrectionState({
    required this.inputText,
    required this.isSubmitting,
    required this.result,
    required this.errorMessage,
  });

  /// Initial state.
  factory GrammarCorrectionState.initial() {
    return const GrammarCorrectionState(
      inputText: '',
      isSubmitting: false,
      result: null,
      errorMessage: null,
    );
  }

  /// Current editable text.
  final String inputText;

  /// Whether the correction request is running.
  final bool isSubmitting;

  /// Latest correction result, if any.
  final CorrectionResult? result;

  /// User-safe error message.
  final String? errorMessage;

  /// Creates a modified copy.
  GrammarCorrectionState copyWith({
    String? inputText,
    bool? isSubmitting,
    CorrectionResult? result,
    bool clearResult = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return GrammarCorrectionState(
      inputText: inputText ?? this.inputText,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      result: clearResult ? null : (result ?? this.result),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
