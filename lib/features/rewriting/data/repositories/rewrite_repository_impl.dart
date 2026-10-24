import '../../domain/entities/correction_result.dart';
import '../../domain/failures/rewrite_failure.dart';
import '../../domain/repositories/rewrite_repository.dart';
import '../data_sources/rewrite_remote_data_source.dart';

/// Repository implementation for rewrite operations.
class RewriteRepositoryImpl implements RewriteRepository {
  /// Creates the repository implementation.
  const RewriteRepositoryImpl(this._remoteDataSource);

  final RewriteRemoteDataSource _remoteDataSource;

  @override
  Future<CorrectionResult> correctGrammar(String text) async {
    if (text.trim().isEmpty) {
      throw const RewriteFailure('Enter text before running grammar correction.');
    }

    try {
      final String correctedText = await _remoteDataSource.correctGrammar(text);

      return CorrectionResult(
        originalText: text,
        correctedText: correctedText,
      );
    } catch (error) {
      if (error is RewriteFailure) {
        rethrow;
      }
      throw const RewriteFailure('Unable to correct grammar right now.');
    }
  }
}
