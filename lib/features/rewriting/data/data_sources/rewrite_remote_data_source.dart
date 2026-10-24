import '../../../../core/networking/ai_http_client.dart';
import '../../../../core/networking/ai_backend_paths.dart';
import '../../../../core/networking/ai_service_exception.dart';

/// Remote data source for grammar correction requests.
class RewriteRemoteDataSource {
  /// Creates the data source.
  const RewriteRemoteDataSource(this._client);

  final AiHttpClient _client;

  /// Sends text to the backend for grammar correction.
  Future<String> correctGrammar(String text) async {
    final Map<String, dynamic> response = await _client.postJson(
      AiBackendPaths.grammarCorrect,
      body: <String, dynamic>{
        'text': text,
      },
    );

    final Object? correctedText = response['correctedText'];
    if (correctedText is! String || correctedText.trim().isEmpty) {
      throw const AiServiceException('Grammar correction response was incomplete.');
    }

    return correctedText;
  }
}
