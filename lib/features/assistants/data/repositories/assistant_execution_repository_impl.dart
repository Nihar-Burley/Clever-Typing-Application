import '../../domain/entities/assistant_execution_result.dart';
import '../../domain/repositories/assistant_execution_repository.dart';
import '../data_sources/assistant_execution_remote_data_source.dart';

class AssistantExecutionRepositoryImpl implements AssistantExecutionRepository {
  const AssistantExecutionRepositoryImpl(this._remoteDataSource);

  final AssistantExecutionRemoteDataSource _remoteDataSource;

  @override
  Future<AssistantExecutionResult> execute({
    required String assistantId,
    required String userText,
    String? promptTemplate,
  }) {
    return _remoteDataSource.execute(
      assistantId: assistantId,
      userText: userText,
      promptTemplate: promptTemplate,
    );
  }
}
