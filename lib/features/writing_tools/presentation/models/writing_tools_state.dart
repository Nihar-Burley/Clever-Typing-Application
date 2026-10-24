import '../../domain/entities/tone_option.dart';
import '../../domain/entities/writing_tool.dart';
import '../../domain/entities/writing_tool_result.dart';

class WritingToolsState {
  const WritingToolsState({
    required this.inputText,
    required this.selectedTool,
    required this.selectedTone,
    required this.preserveTone,
    required this.isSubmitting,
    required this.result,
    required this.errorMessage,
  });

  factory WritingToolsState.initial() {
    return const WritingToolsState(
      inputText: '',
      selectedTool: WritingTool.toneRewrite,
      selectedTone: ToneOption.professional,
      preserveTone: true,
      isSubmitting: false,
      result: null,
      errorMessage: null,
    );
  }

  final String inputText;
  final WritingTool selectedTool;
  final ToneOption selectedTone;
  final bool preserveTone;
  final bool isSubmitting;
  final WritingToolResult? result;
  final String? errorMessage;

  WritingToolsState copyWith({
    String? inputText,
    WritingTool? selectedTool,
    ToneOption? selectedTone,
    bool? preserveTone,
    bool? isSubmitting,
    WritingToolResult? result,
    bool clearResult = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return WritingToolsState(
      inputText: inputText ?? this.inputText,
      selectedTool: selectedTool ?? this.selectedTool,
      selectedTone: selectedTone ?? this.selectedTone,
      preserveTone: preserveTone ?? this.preserveTone,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      result: clearResult ? null : (result ?? this.result),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
