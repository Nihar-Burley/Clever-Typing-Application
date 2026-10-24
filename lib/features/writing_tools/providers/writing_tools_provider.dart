import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/core_providers.dart';
import '../../subscription/providers/subscription_provider.dart';
import '../data/data_sources/writing_tools_remote_data_source.dart';
import '../data/repositories/writing_tools_repository_impl.dart';
import '../domain/entities/tone_option.dart';
import '../domain/entities/writing_tool.dart';
import '../domain/repositories/writing_tools_repository.dart';
import '../domain/use_cases/execute_writing_tool_use_case.dart';
import '../presentation/models/writing_tools_state.dart';

final Provider<WritingToolsRemoteDataSource> writingToolsRemoteDataSourceProvider =
    Provider<WritingToolsRemoteDataSource>(
  (Ref ref) => WritingToolsRemoteDataSource(ref.watch(aiHttpClientProvider)),
);

final Provider<WritingToolsRepository> writingToolsRepositoryProvider =
    Provider<WritingToolsRepository>(
  (Ref ref) => WritingToolsRepositoryImpl(
    ref.watch(writingToolsRemoteDataSourceProvider),
  ),
);

final Provider<ExecuteWritingToolUseCase> executeWritingToolUseCaseProvider =
    Provider<ExecuteWritingToolUseCase>(
  (Ref ref) => ExecuteWritingToolUseCase(
    ref.watch(writingToolsRepositoryProvider),
  ),
);

final Provider<List<WritingTool>> writingToolsCatalogProvider =
    Provider<List<WritingTool>>((Ref ref) => WritingTool.values);

final Provider<List<ToneOption>> writingToolTonesProvider =
    Provider<List<ToneOption>>((Ref ref) => ToneOption.values);

final NotifierProvider<WritingToolsNotifier, WritingToolsState>
    writingToolsProvider =
    NotifierProvider<WritingToolsNotifier, WritingToolsState>(
  WritingToolsNotifier.new,
);

class WritingToolsNotifier extends Notifier<WritingToolsState> {
  @override
  WritingToolsState build() {
    return WritingToolsState.initial();
  }

  void updateInput(String value) {
    state = state.copyWith(
      inputText: value,
      clearError: true,
      clearResult: true,
    );
  }

  void updateTool(WritingTool value) {
    state = state.copyWith(
      selectedTool: value,
      clearError: true,
      clearResult: true,
    );
  }

  void updateTone(ToneOption value) {
    state = state.copyWith(
      selectedTone: value,
      clearError: true,
      clearResult: true,
    );
  }

  void updatePreserveTone(bool value) {
    state = state.copyWith(
      preserveTone: value,
      clearError: true,
      clearResult: true,
    );
  }

  Future<void> submit() async {
    final text = state.inputText.trim();
    if (text.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Enter text before running the writing tool.',
        clearResult: true,
      );
      return;
    }
    final String? quotaError =
        await ref.read(aiQuotaGuardProvider).validateBeforeAiAction();
    if (quotaError != null) {
      state = state.copyWith(
        errorMessage: quotaError,
        clearResult: true,
      );
      return;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final result = await ref.read(executeWritingToolUseCaseProvider)(
        tool: state.selectedTool,
        text: text,
        tone: state.selectedTone,
        preserveTone: state.preserveTone,
      );
      ref.read(appLoggerProvider).info(
            'WritingTools',
            'submit',
            'Executed ${state.selectedTool.name}',
          );
      await ref.read(privacyRepositoryProvider).recordUsage(
            feature: 'writing_tools',
            action: state.selectedTool.name,
            inputPreview: text,
            outputPreview: result.outputText,
            wasSuccessful: true,
          );
      state = state.copyWith(
        isSubmitting: false,
        result: result,
        clearError: true,
      );
    } catch (_) {
      await ref.read(privacyRepositoryProvider).recordUsage(
            feature: 'writing_tools',
            action: state.selectedTool.name,
            inputPreview: text,
            wasSuccessful: false,
          );
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Unable to run the selected writing tool right now.',
        clearResult: true,
      );
    }
  }
}
