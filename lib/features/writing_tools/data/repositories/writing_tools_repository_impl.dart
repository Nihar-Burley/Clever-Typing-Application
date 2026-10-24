import '../../domain/entities/tone_option.dart';
import '../../domain/entities/writing_tool.dart';
import '../../domain/entities/writing_tool_result.dart';
import '../../domain/repositories/writing_tools_repository.dart';
import '../data_sources/writing_tools_remote_data_source.dart';

class WritingToolsRepositoryImpl implements WritingToolsRepository {
  const WritingToolsRepositoryImpl(this._remoteDataSource);

  final WritingToolsRemoteDataSource _remoteDataSource;

  @override
  Future<WritingToolResult> executeTool({
    required WritingTool tool,
    required String text,
    ToneOption? tone,
    bool preserveTone = false,
  }) {
    return _remoteDataSource.executeTool(
      tool: tool,
      text: text,
      tone: tone,
      preserveTone: preserveTone,
    );
  }
}
