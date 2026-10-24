import '../entities/reply_variant.dart';
import '../entities/smart_reply_result.dart';
import '../repositories/smart_reply_repository.dart';

/// Executes smart reply generation.
class GenerateSmartRepliesUseCase {
  /// Creates the use case.
  const GenerateSmartRepliesUseCase(this._repository);

  final SmartReplyRepository _repository;

  /// Returns reply suggestions for the provided context.
  Future<SmartReplyResult> call({
    required String conversationContext,
    required ReplyVariant variant,
  }) {
    return _repository.generateReplies(
      conversationContext: conversationContext,
      variant: variant,
    );
  }
}
