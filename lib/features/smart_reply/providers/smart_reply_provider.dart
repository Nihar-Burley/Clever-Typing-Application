import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/data_sources/smart_reply_remote_data_source.dart';
import '../data/repositories/smart_reply_permission_repository_impl.dart';
import '../data/repositories/smart_reply_repository_impl.dart';
import '../domain/entities/reply_variant.dart';
import '../domain/repositories/smart_reply_repository.dart';
import '../domain/repositories/smart_reply_permission_repository.dart';
import '../domain/use_cases/generate_smart_replies_use_case.dart';
import '../presentation/models/smart_reply_state.dart';

import '../../../core/di/core_providers.dart';
import '../../subscription/providers/subscription_provider.dart';

final Provider<SmartReplyRemoteDataSource> smartReplyRemoteDataSourceProvider =
    Provider<SmartReplyRemoteDataSource>(
  (Ref<SmartReplyRemoteDataSource> ref) => SmartReplyRemoteDataSource(
    ref.watch(aiHttpClientProvider),
  ),
);

final Provider<SmartReplyRepository> smartReplyRepositoryProvider =
    Provider<SmartReplyRepository>(
  (Ref<SmartReplyRepository> ref) => SmartReplyRepositoryImpl(
    ref.watch(smartReplyRemoteDataSourceProvider),
  ),
);

final Provider<SmartReplyPermissionRepository>
    smartReplyPermissionRepositoryProvider =
    Provider<SmartReplyPermissionRepository>(
  (Ref<SmartReplyPermissionRepository> ref) =>
      SmartReplyPermissionRepositoryImpl(
    ref.watch(keyboardPlatformServiceProvider),
  ),
);

final Provider<GenerateSmartRepliesUseCase> generateSmartRepliesUseCaseProvider =
    Provider<GenerateSmartRepliesUseCase>(
  (Ref<GenerateSmartRepliesUseCase> ref) => GenerateSmartRepliesUseCase(
    ref.watch(smartReplyRepositoryProvider),
  ),
);

final NotifierProvider<SmartReplyNotifier, SmartReplyState>
    smartReplyProvider = NotifierProvider<SmartReplyNotifier, SmartReplyState>(
  SmartReplyNotifier.new,
);

/// Manages smart reply preview state.
class SmartReplyNotifier extends Notifier<SmartReplyState> {
  @override
  SmartReplyState build() {
    Future<void>.microtask(refreshPermissionState);
    return SmartReplyState.initial();
  }

  Future<void> refreshPermissionState() async {
    final bool isEnabled = await ref
        .read(smartReplyPermissionRepositoryProvider)
        .isAccessibilityEnabled();
    final String? latestContext = await ref
        .read(smartReplyPermissionRepositoryProvider)
        .readLatestConversationContext();

    state = state.copyWith(
      isAccessibilityEnabled: isEnabled,
      contextText: latestContext ?? state.contextText,
    );
  }

  void updateContext(String value) {
    state = state.copyWith(
      contextText: value,
      clearReplies: true,
      clearError: true,
    );
  }

  void updateVariant(ReplyVariant value) {
    state = state.copyWith(
      selectedVariant: value,
      clearReplies: true,
      clearError: true,
    );
  }

  Future<void> openAccessibilitySettings() {
    unawaited(
      ref.read(privacyRepositoryProvider).recordConsent(
            consentType: 'accessibility_capture_settings_opened',
            wasGranted: true,
          ),
    );
    return ref
        .read(smartReplyPermissionRepositoryProvider)
        .openAccessibilitySettings();
  }

  Future<void> refreshCapturedContext() {
    return refreshPermissionState();
  }

  Future<void> generateReplies() async {
    final String text = state.contextText.trim();
    if (text.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Enter conversation context before generating replies.',
        clearReplies: true,
      );
      return;
    }
    final String? quotaError =
        await ref.read(aiQuotaGuardProvider).validateBeforeAiAction();
    if (quotaError != null) {
      state = state.copyWith(
        errorMessage: quotaError,
        clearReplies: true,
      );
      return;
    }

    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
    );

    try {
      final result = await ref.read(generateSmartRepliesUseCaseProvider)(
        conversationContext: text,
        variant: state.selectedVariant,
      );
      await ref.read(privacyRepositoryProvider).recordUsage(
            feature: 'smart_reply',
            action: state.selectedVariant.name,
            inputPreview: text,
            outputPreview: result.replies.join(' | '),
            wasSuccessful: true,
          );

      state = state.copyWith(
        isSubmitting: false,
        replies: result.replies,
        clearError: true,
      );
    } catch (_) {
      await ref.read(privacyRepositoryProvider).recordUsage(
            feature: 'smart_reply',
            action: state.selectedVariant.name,
            inputPreview: text,
            wasSuccessful: false,
          );
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Unable to generate smart replies right now.',
        clearReplies: true,
      );
    }
  }
}
