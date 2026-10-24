import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/core_providers.dart';
import '../../subscription/providers/subscription_provider.dart';
import '../data/data_sources/translation_remote_data_source.dart';
import '../data/repositories/translation_repository_impl.dart';
import '../domain/entities/translation_result.dart';
import '../domain/repositories/translation_repository.dart';
import '../domain/use_cases/translate_text_use_case.dart';
import '../presentation/models/translation_state.dart';

final Provider<TranslationRemoteDataSource> translationRemoteDataSourceProvider =
    Provider<TranslationRemoteDataSource>(
  (Ref<TranslationRemoteDataSource> ref) => TranslationRemoteDataSource(
    ref.watch(aiHttpClientProvider),
  ),
);

final Provider<TranslationRepository> translationRepositoryProvider =
    Provider<TranslationRepository>(
  (Ref<TranslationRepository> ref) => TranslationRepositoryImpl(
    ref.watch(translationRemoteDataSourceProvider),
  ),
);

final Provider<TranslateTextUseCase> translateTextUseCaseProvider =
    Provider<TranslateTextUseCase>(
  (Ref<TranslateTextUseCase> ref) => TranslateTextUseCase(
    ref.watch(translationRepositoryProvider),
  ),
);

final Provider<List<String>> translationLanguagesProvider =
    Provider<List<String>>(
  (Ref<List<String>> ref) => const <String>[
    'Auto Detect',
    'Spanish',
    'French',
    'German',
    'Hindi',
    'Arabic',
  ],
);

final NotifierProvider<TranslationNotifier, TranslationState>
    translationProvider = NotifierProvider<TranslationNotifier, TranslationState>(
  TranslationNotifier.new,
);

/// Manages translation UI state.
class TranslationNotifier extends Notifier<TranslationState> {
  @override
  TranslationState build() {
    return TranslationState.initial();
  }

  /// Updates the input text.
  void updateInput(String value) {
    state = state.copyWith(
      inputText: value,
      clearTranslatedText: true,
      clearError: true,
    );
  }

  /// Updates the active target language.
  void updateTargetLanguage(String value) {
    state = state.copyWith(
      targetLanguage: value,
      clearTranslatedText: true,
      clearError: true,
    );
  }

  /// Updates the source language.
  void updateSourceLanguage(String value) {
    state = state.copyWith(
      sourceLanguage: value,
      clearTranslatedText: true,
      clearError: true,
    );
  }

  /// Updates tone preservation preference.
  void updatePreserveTone(bool value) {
    state = state.copyWith(
      preserveTone: value,
      clearTranslatedText: true,
      clearError: true,
    );
  }

  /// Executes translation through the active repository.
  Future<void> translate() async {
    final String text = state.inputText.trim();
    if (text.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Enter text before running translation.',
        clearTranslatedText: true,
      );
      return;
    }
    final String? quotaError =
        await ref.read(aiQuotaGuardProvider).validateBeforeAiAction();
    if (quotaError != null) {
      state = state.copyWith(
        errorMessage: quotaError,
        clearTranslatedText: true,
      );
      return;
    }

    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
    );

    try {
      final TranslationResult translatedResult =
          await ref.read(translateTextUseCaseProvider)(
        text: text,
        sourceLanguage: state.sourceLanguage,
        targetLanguage: state.targetLanguage,
        preserveTone: state.preserveTone,
      );

      ref.read(appLoggerProvider).info(
            'Translation',
            'translate',
            'Translated to ${state.targetLanguage}',
          );
      await ref.read(privacyRepositoryProvider).recordUsage(
            feature: 'translation',
            action: 'translate',
            inputPreview: text,
            outputPreview: translatedResult.translatedText,
            wasSuccessful: true,
          );

      state = state.copyWith(
        isSubmitting: false,
        translatedText: translatedResult.translatedText,
        detectedSourceLanguage: translatedResult.detectedSourceLanguage,
        clearError: true,
      );
    } catch (_) {
      await ref.read(privacyRepositoryProvider).recordUsage(
            feature: 'translation',
            action: 'translate',
            inputPreview: text,
            wasSuccessful: false,
          );
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Unable to translate text right now.',
        clearTranslatedText: true,
      );
    }
  }
}
