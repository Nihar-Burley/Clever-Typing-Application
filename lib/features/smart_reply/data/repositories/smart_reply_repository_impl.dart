import '../../domain/entities/reply_variant.dart';
import '../../domain/entities/smart_reply_result.dart';
import '../../domain/repositories/smart_reply_repository.dart';
import '../data_sources/smart_reply_remote_data_source.dart';

/// Repository implementation for smart reply requests.
class SmartReplyRepositoryImpl implements SmartReplyRepository {
  /// Creates the repository implementation.
  const SmartReplyRepositoryImpl(this._remoteDataSource);

  final SmartReplyRemoteDataSource _remoteDataSource;

  @override
  Future<SmartReplyResult> generateReplies({
    required String conversationContext,
    required ReplyVariant variant,
  }) {
    return _remoteDataSource.generateReplies(
      conversationContext: conversationContext,
      variant: variant,
    );
  }
}
