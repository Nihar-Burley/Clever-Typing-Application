import '../entities/reply_variant.dart';
import '../entities/smart_reply_result.dart';

/// Contract for smart reply generation.
abstract interface class SmartReplyRepository {
  /// Generates reply options from conversation context.
  Future<SmartReplyResult> generateReplies({
    required String conversationContext,
    required ReplyVariant variant,
  });
}
