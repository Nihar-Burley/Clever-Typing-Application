import '../../../../core/networking/ai_http_client.dart';
import '../../../../core/networking/ai_backend_paths.dart';
import '../../../../core/networking/ai_service_exception.dart';
import '../../domain/entities/tone_option.dart';
import '../../domain/entities/writing_tool.dart';
import '../../domain/entities/writing_tool_result.dart';
import '../mappers/writing_tool_api_mapper.dart';

class WritingToolsRemoteDataSource {
  const WritingToolsRemoteDataSource(this._client);

  final AiHttpClient _client;

  Future<WritingToolResult> executeTool({
    required WritingTool tool,
    required String text,
    ToneOption? tone,
    bool preserveTone = false,
  }) async {
    final response = await _client.postJson(
      AiBackendPaths.rewrite,
      body: <String, dynamic>{
        'tool': WritingToolApiMapper.toolName(tool),
        'text': text,
        'tone': tone == null ? null : WritingToolApiMapper.toneName(tone),
        'preserveTone': preserveTone,
      }..removeWhere((_, value) => value == null),
    );

    final Object? outputText = response['outputText'];
    if (outputText is! String || outputText.trim().isEmpty) {
      throw const AiServiceException('Writing tool response was incomplete.');
    }

    final Object? summaryBullets = response['summaryBullets'];

    return WritingToolResult(
      tool: tool,
      outputText: outputText,
      tone: tone,
      detectedLanguage: response['detectedLanguage'] as String?,
      summaryBullets: summaryBullets is List
          ? summaryBullets.whereType<String>().toList()
          : const <String>[],
    );
  }
}
