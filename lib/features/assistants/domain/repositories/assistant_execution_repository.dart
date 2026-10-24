import '../entities/assistant_execution_result.dart';

abstract interface class AssistantExecutionRepository {
  Future<AssistantExecutionResult> execute({
    required String assistantId,
    required String userText,
    String? promptTemplate,
  });
}
