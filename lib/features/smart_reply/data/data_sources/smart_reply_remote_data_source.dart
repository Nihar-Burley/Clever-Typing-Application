import '../../../../core/networking/ai_http_client.dart';
import '../../../../core/networking/ai_backend_paths.dart';
import '../../../../core/networking/ai_service_exception.dart';
import '../../domain/entities/reply_variant.dart';
import '../../domain/entities/smart_reply_result.dart';

/// Remote data source for smart reply generation.
class SmartReplyRemoteDataSource {
  /// Creates the data source.
  const SmartReplyRemoteDataSource(this._client);

  final AiHttpClient _client;

  /// Requests reply options from the AI backend.
  Future<SmartReplyResult> generateReplies({
    required String conversationContext,
    required ReplyVariant variant,
  }) async {
    final Map<String, dynamic> response = await _client.postJson(
      AiBackendPaths.smartReply,
      body: <String, dynamic>{
        'conversationContext': conversationContext,
        'variant': variant.name,
      },
    );

    final Object? replies = response['replies'];
    if (replies is! List) {
      throw const AiServiceException('Smart reply response was incomplete.');
    }

    return SmartReplyResult(
      replies: replies.whereType<String>().where((String item) => item.isNotEmpty).toList(),
    );
  }
}
