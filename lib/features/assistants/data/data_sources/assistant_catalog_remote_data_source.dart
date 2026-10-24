import '../../../../core/networking/ai_backend_paths.dart';
import '../../../../core/networking/ai_http_client.dart';
import '../../domain/entities/assistant_template.dart';

class AssistantCatalogRemoteDataSource {
  const AssistantCatalogRemoteDataSource(this._client);

  final AiHttpClient _client;

  Future<List<AssistantTemplate>> fetchCatalog() async {
    final Map<String, dynamic> response = await _client.getJson(
      AiBackendPaths.assistantCatalog,
    );
    final Object? items = response['assistants'];
    if (items is! List) {
      return const <AssistantTemplate>[];
    }
    return items
        .whereType<Map>()
        .map(
          (Map<dynamic, dynamic> entry) => AssistantTemplate.fromJson(
            Map<String, Object?>.from(entry),
          ),
        )
        .toList();
  }
}
