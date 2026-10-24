import '../../domain/entities/translation_result.dart';
import '../../domain/repositories/translation_repository.dart';
import '../data_sources/translation_remote_data_source.dart';

/// Repository implementation for translation features.
class TranslationRepositoryImpl implements TranslationRepository {
  /// Creates the repository implementation.
  const TranslationRepositoryImpl(this._remoteDataSource);

  final TranslationRemoteDataSource _remoteDataSource;

  @override
  Future<TranslationResult> translate({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
    required bool preserveTone,
  }) {
    return _remoteDataSource.translate(
      text: text,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      preserveTone: preserveTone,
    );
  }
}
