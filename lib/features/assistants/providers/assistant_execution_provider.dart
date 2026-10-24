import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/core_providers.dart';
import '../../subscription/providers/subscription_provider.dart';
import '../data/data_sources/assistant_execution_remote_data_source.dart';
import '../data/repositories/assistant_execution_repository_impl.dart';
import '../domain/entities/assistant_execution_result.dart';
import '../domain/entities/assistant_template.dart';
import '../domain/repositories/assistant_execution_repository.dart';

class AssistantExecutionState {
  const AssistantExecutionState({
    required this.inputText,
    required this.isSubmitting,
    required this.result,
    required this.errorMessage,
  });

  factory AssistantExecutionState.initial() {
    return const AssistantExecutionState(
      inputText: '',
      isSubmitting: false,
      result: null,
      errorMessage: null,
    );
  }

  final String inputText;
  final bool isSubmitting;
  final AssistantExecutionResult? result;
  final String? errorMessage;

  AssistantExecutionState copyWith({
    String? inputText,
    bool? isSubmitting,
    AssistantExecutionResult? result,
    bool clearResult = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AssistantExecutionState(
      inputText: inputText ?? this.inputText,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      result: clearResult ? null : (result ?? this.result),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final Provider<AssistantExecutionRemoteDataSource>
    assistantExecutionRemoteDataSourceProvider =
    Provider<AssistantExecutionRemoteDataSource>(
  (Ref ref) => AssistantExecutionRemoteDataSource(
    ref.watch(aiHttpClientProvider),
  ),
);

final Provider<AssistantExecutionRepository> assistantExecutionRepositoryProvider =
    Provider<AssistantExecutionRepository>(
  (Ref ref) => AssistantExecutionRepositoryImpl(
    ref.watch(assistantExecutionRemoteDataSourceProvider),
  ),
);

final AutoDisposeNotifierProviderFamily<
        AssistantExecutionNotifier, AssistantExecutionState, AssistantTemplate>
    assistantExecutionProvider = AutoDisposeNotifierProviderFamily<
        AssistantExecutionNotifier, AssistantExecutionState, AssistantTemplate>(
  AssistantExecutionNotifier.new,
);

class AssistantExecutionNotifier
    extends AutoDisposeFamilyNotifier<AssistantExecutionState, AssistantTemplate> {
  @override
  AssistantExecutionState build(AssistantTemplate arg) {
    return AssistantExecutionState.initial();
  }

  void updateInput(String value) {
    state = state.copyWith(
      inputText: value,
      clearError: true,
      clearResult: true,
    );
  }

  Future<void> submit() async {
    final String text = state.inputText.trim();
    if (text.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Enter text before running the assistant.',
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

    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
    );

    try {
      final result = await ref.read(assistantExecutionRepositoryProvider).execute(
            assistantId: arg.id,
            userText: text,
            promptTemplate: arg.promptTemplate,
          );
      await ref.read(privacyRepositoryProvider).recordUsage(
            feature: 'assistants',
            action: 'execute',
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
            feature: 'assistants',
            action: 'execute',
            inputPreview: text,
            wasSuccessful: false,
          );
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Unable to run the assistant right now.',
        clearResult: true,
      );
    }
  }
}
