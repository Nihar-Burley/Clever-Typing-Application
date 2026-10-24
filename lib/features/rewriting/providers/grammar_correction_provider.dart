import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/core_providers.dart';
import '../../subscription/providers/subscription_provider.dart';
import '../data/data_sources/rewrite_remote_data_source.dart';
import '../data/repositories/rewrite_repository_impl.dart';
import '../domain/failures/rewrite_failure.dart';
import '../domain/repositories/rewrite_repository.dart';
import '../domain/use_cases/correct_grammar_use_case.dart';
import '../presentation/models/grammar_correction_state.dart';

final Provider<RewriteRemoteDataSource> rewriteRemoteDataSourceProvider =
    Provider<RewriteRemoteDataSource>(
  (Ref<RewriteRemoteDataSource> ref) => RewriteRemoteDataSource(
    ref.watch(aiHttpClientProvider),
  ),
);

final Provider<RewriteRepository> rewriteRepositoryProvider =
    Provider<RewriteRepository>(
  (Ref<RewriteRepository> ref) => RewriteRepositoryImpl(
    ref.watch(rewriteRemoteDataSourceProvider),
  ),
);

final Provider<CorrectGrammarUseCase> correctGrammarUseCaseProvider =
    Provider<CorrectGrammarUseCase>(
  (Ref<CorrectGrammarUseCase> ref) => CorrectGrammarUseCase(
    ref.watch(rewriteRepositoryProvider),
  ),
);

final NotifierProvider<GrammarCorrectionNotifier, GrammarCorrectionState>
    grammarCorrectionProvider =
    NotifierProvider<GrammarCorrectionNotifier, GrammarCorrectionState>(
  GrammarCorrectionNotifier.new,
);

/// Coordinates UI state and grammar correction execution.
class GrammarCorrectionNotifier extends Notifier<GrammarCorrectionState> {
  @override
  GrammarCorrectionState build() {
    return GrammarCorrectionState.initial();
  }

  /// Updates the current input text.
  void updateInput(String value) {
    state = state.copyWith(
      inputText: value,
      clearError: true,
      clearResult: true,
    );
  }

  /// Runs grammar correction using the active use case.
  Future<void> submit() async {
    final String text = state.inputText;
    final String? quotaError =
        await ref.read(aiQuotaGuardProvider).validateBeforeAiAction();
    if (quotaError != null) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: quotaError,
        clearResult: true,
      );
      return;
    }

    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
    );

    try {
      final result = await ref.read(correctGrammarUseCaseProvider)(text);

      ref
          .read(appLoggerProvider)
          .info('GrammarCorrection', 'submit', 'Correction generated');
      await ref.read(privacyRepositoryProvider).recordUsage(
            feature: 'grammar_correction',
            action: 'correct',
            inputPreview: text,
            outputPreview: result.correctedText,
            wasSuccessful: true,
          );

      state = state.copyWith(
        isSubmitting: false,
        result: result,
        clearError: true,
      );
    } on RewriteFailure catch (error) {
      await ref.read(privacyRepositoryProvider).recordUsage(
            feature: 'grammar_correction',
            action: 'correct',
            inputPreview: text,
            wasSuccessful: false,
          );
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: error.message,
        clearResult: true,
      );
    } catch (error) {
      ref.read(appLoggerProvider).error(
            'GrammarCorrection',
            'submit',
            error,
          );
      await ref.read(privacyRepositoryProvider).recordUsage(
            feature: 'grammar_correction',
            action: 'correct',
            inputPreview: text,
            wasSuccessful: false,
          );

      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Unable to correct grammar right now.',
        clearResult: true,
      );
    }
  }
}
