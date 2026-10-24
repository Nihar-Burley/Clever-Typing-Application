import '../../domain/entities/reply_variant.dart';

/// Immutable UI state for smart reply preview.
class SmartReplyState {
  /// Creates the state.
  const SmartReplyState({
    required this.contextText,
    required this.selectedVariant,
    required this.isAccessibilityEnabled,
    required this.isSubmitting,
    required this.replies,
    required this.errorMessage,
  });

  /// Initial state.
  factory SmartReplyState.initial() {
    return const SmartReplyState(
      contextText: '',
      selectedVariant: ReplyVariant.friendly,
      isAccessibilityEnabled: false,
      isSubmitting: false,
      replies: <String>[],
      errorMessage: null,
    );
  }

  final String contextText;
  final ReplyVariant selectedVariant;
  final bool isAccessibilityEnabled;
  final bool isSubmitting;
  final List<String> replies;
  final String? errorMessage;

  /// Returns a new state instance.
  SmartReplyState copyWith({
    String? contextText,
    ReplyVariant? selectedVariant,
    bool? isAccessibilityEnabled,
    bool? isSubmitting,
    List<String>? replies,
    String? errorMessage,
    bool clearReplies = false,
    bool clearError = false,
  }) {
    return SmartReplyState(
      contextText: contextText ?? this.contextText,
      selectedVariant: selectedVariant ?? this.selectedVariant,
      isAccessibilityEnabled:
          isAccessibilityEnabled ?? this.isAccessibilityEnabled,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      replies: clearReplies ? <String>[] : (replies ?? this.replies),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
