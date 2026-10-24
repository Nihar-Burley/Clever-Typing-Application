import '../entities/tone_option.dart';
import '../entities/writing_tool.dart';
import '../entities/writing_tool_result.dart';

abstract interface class WritingToolsRepository {
  Future<WritingToolResult> executeTool({
    required WritingTool tool,
    required String text,
    ToneOption? tone,
    bool preserveTone = false,
  });
}
