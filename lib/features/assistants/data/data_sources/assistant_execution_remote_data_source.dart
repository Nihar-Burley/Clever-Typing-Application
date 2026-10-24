import '../../../../core/networking/ai_http_client.dart';
import '../../../../core/networking/ai_backend_paths.dart';
import '../../../../core/networking/ai_service_exception.dart';
import '../../domain/entities/assistant_execution_result.dart';

class AssistantExecutionRemoteDataSource {
  const AssistantExecutionRemoteDataSource(this._client);

  final AiHttpClient _client;

  Future<AssistantExecutionResult> execute({
    required String assistantId,
    required String userText,
    String? promptTemplate,
  }) async {
    final response = await _client.postJson(
      AiBackendPaths.assistantExecute,
      body: <String, dynamic>{
        'assistantId': assistantId,
        'userText': userText,
        'promptTemplate': promptTemplate,
      }..removeWhere((_, Object? value) => value == null),
    );

    final Object? outputText = response['outputText'];
    if (outputText is! String || outputText.trim().isEmpty) {
      throw const AiServiceException('Assistant response was incomplete.');
    }

    return AssistantExecutionResult(outputText: outputText);
  }
}
