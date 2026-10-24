import 'package:flutter_test/flutter_test.dart';

import 'package:clever_typing_application/core/networking/ai_http_client.dart';
import 'package:clever_typing_application/features/rewriting/data/data_sources/rewrite_remote_data_source.dart';
import 'package:clever_typing_application/features/smart_reply/data/data_sources/smart_reply_remote_data_source.dart';
import 'package:clever_typing_application/features/smart_reply/domain/entities/reply_variant.dart';
import 'package:clever_typing_application/features/translation/data/data_sources/translation_remote_data_source.dart';

void main() {
  group('RewriteRemoteDataSource', () {
    test('returns corrected text from backend response', () async {
      final RewriteRemoteDataSource dataSource = RewriteRemoteDataSource(
        _FakeAiHttpClient(
          <String, dynamic>{'correctedText': 'Corrected sentence.'},
        ),
      );

      final result = await dataSource.correctGrammar('wrong sentence');

      expect(result, 'Corrected sentence.');
    });
  });

  group('TranslationRemoteDataSource', () {
    test('returns translated result from backend response', () async {
      final TranslationRemoteDataSource dataSource = TranslationRemoteDataSource(
        _FakeAiHttpClient(
          <String, dynamic>{
            'translatedText': 'Hola mundo',
            'detectedSourceLanguage': 'English',
          },
        ),
      );

      final result = await dataSource.translate(
        text: 'Hello world',
        sourceLanguage: 'Auto Detect',
        targetLanguage: 'Spanish',
        preserveTone: true,
      );

      expect(result.translatedText, 'Hola mundo');
      expect(result.detectedSourceLanguage, 'English');
    });
  });

  group('SmartReplyRemoteDataSource', () {
    test('returns reply list from backend response', () async {
      final SmartReplyRemoteDataSource dataSource = SmartReplyRemoteDataSource(
        _FakeAiHttpClient(
          <String, dynamic>{
            'replies': <String>[
              'Thanks for the update.',
              'I will send it soon.',
            ],
          },
        ),
      );

      final result = await dataSource.generateReplies(
        conversationContext: 'Can you send that update?',
        variant: ReplyVariant.friendly,
      );

      expect(result.replies, hasLength(2));
    });
  });
}

class _FakeAiHttpClient implements AiHttpClient {
  _FakeAiHttpClient(this._response);

  final Map<String, dynamic> _response;

  @override
  Future<Map<String, dynamic>> getJson(String path) async {
    return _response;
  }

  @override
  Future<Map<String, dynamic>> postJson(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    return _response;
  }
}
