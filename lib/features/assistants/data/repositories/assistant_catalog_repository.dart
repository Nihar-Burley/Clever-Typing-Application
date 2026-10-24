import '../../domain/entities/assistant_template.dart';
import '../data_sources/assistant_catalog_local_data_source.dart';
import '../data_sources/assistant_catalog_remote_data_source.dart';

class AssistantCatalogRepository {
  const AssistantCatalogRepository(
    this._localDataSource,
    this._remoteDataSource,
  );

  final AssistantCatalogLocalDataSource _localDataSource;
  final AssistantCatalogRemoteDataSource _remoteDataSource;

  Future<List<AssistantTemplate>> loadCatalog() async {
    final List<AssistantTemplate> local = await _localDataSource.readAll();

    try {
      final List<AssistantTemplate> remote = await _remoteDataSource.fetchCatalog();
      final List<AssistantTemplate> custom =
          local.where((AssistantTemplate item) => item.isCustom).toList();
      final List<AssistantTemplate> merged = <AssistantTemplate>[
        ...remote,
        ...custom,
      ];
      await _localDataSource.upsertAll(merged);
      return merged;
    } catch (_) {
      return local;
    }
  }

  Future<void> saveAssistant(AssistantTemplate assistant) {
    return _localDataSource.upsert(assistant);
  }

  Future<void> deleteAssistant(String assistantId) {
    return _localDataSource.delete(assistantId);
  }
}
