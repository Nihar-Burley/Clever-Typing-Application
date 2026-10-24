import '../../../../core/networking/ai_http_client.dart';
import '../../../../core/networking/ai_backend_paths.dart';
import '../../../../core/networking/ai_service_exception.dart';
import '../../domain/entities/translation_result.dart';

/// Remote translation data source.
class TranslationRemoteDataSource {
  /// Creates the data source.
  const TranslationRemoteDataSource(this._client);

  final AiHttpClient _client;

  /// Requests a translation from the backend.
  Future<TranslationResult> translate({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
    required bool preserveTone,
  }) async {
    final Map<String, dynamic> response = await _client.postJson(
      AiBackendPaths.translate,
      body: <String, dynamic>{
        'text': text,
        'sourceLanguage': sourceLanguage,
        'targetLanguage': targetLanguage,
        'preserveTone': preserveTone,
      },
    );

    final Object? translatedText = response['translatedText'];
    if (translatedText is! String || translatedText.trim().isEmpty) {
      throw const AiServiceException('Translation response was incomplete.');
    }

    return TranslationResult(
      translatedText: translatedText,
      detectedSourceLanguage: response['detectedSourceLanguage'] as String?,
    );
  }
}
