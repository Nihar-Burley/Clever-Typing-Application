import '../entities/tone_option.dart';
import '../entities/writing_tool.dart';
import '../entities/writing_tool_result.dart';
import '../repositories/writing_tools_repository.dart';

class ExecuteWritingToolUseCase {
  const ExecuteWritingToolUseCase(this._repository);

  final WritingToolsRepository _repository;

  Future<WritingToolResult> call({
    required WritingTool tool,
    required String text,
    ToneOption? tone,
    bool preserveTone = false,
  }) {
    return _repository.executeTool(
      tool: tool,
      text: text,
      tone: tone,
      preserveTone: preserveTone,
    );
  }
}
