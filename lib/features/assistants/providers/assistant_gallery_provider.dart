import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/core_providers.dart';
import '../data/data_sources/assistant_catalog_local_data_source.dart';
import '../data/data_sources/assistant_catalog_remote_data_source.dart';
import '../data/repositories/assistant_catalog_repository.dart';
import '../domain/entities/assistant_template.dart';

class AssistantGalleryState {
  const AssistantGalleryState({
    required this.isLoading,
    required this.assistants,
    required this.errorMessage,
  });

  factory AssistantGalleryState.initial() {
    return const AssistantGalleryState(
      isLoading: true,
      assistants: <AssistantTemplate>[],
      errorMessage: null,
    );
  }

  final bool isLoading;
  final List<AssistantTemplate> assistants;
  final String? errorMessage;

  AssistantGalleryState copyWith({
    bool? isLoading,
    List<AssistantTemplate>? assistants,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AssistantGalleryState(
      isLoading: isLoading ?? this.isLoading,
      assistants: assistants ?? this.assistants,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final Provider<AssistantCatalogLocalDataSource>
    assistantCatalogLocalDataSourceProvider =
    Provider<AssistantCatalogLocalDataSource>(
  (Ref ref) => AssistantCatalogLocalDataSource(
    ref.watch(appDatabaseProvider),
  ),
);

final Provider<AssistantCatalogRemoteDataSource>
    assistantCatalogRemoteDataSourceProvider =
    Provider<AssistantCatalogRemoteDataSource>(
  (Ref ref) => AssistantCatalogRemoteDataSource(
    ref.watch(aiHttpClientProvider),
  ),
);

final Provider<AssistantCatalogRepository> assistantCatalogRepositoryProvider =
    Provider<AssistantCatalogRepository>(
  (Ref ref) => AssistantCatalogRepository(
    ref.watch(assistantCatalogLocalDataSourceProvider),
    ref.watch(assistantCatalogRemoteDataSourceProvider),
  ),
);

final NotifierProvider<AssistantGalleryNotifier, AssistantGalleryState>
    assistantGalleryProvider =
    NotifierProvider<AssistantGalleryNotifier, AssistantGalleryState>(
  AssistantGalleryNotifier.new,
);

class AssistantGalleryNotifier extends Notifier<AssistantGalleryState> {
  @override
  AssistantGalleryState build() {
    Future<void>.microtask(refresh);
    return AssistantGalleryState.initial();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final List<AssistantTemplate> assistants =
          await ref.read(assistantCatalogRepositoryProvider).loadCatalog();
      state = state.copyWith(
        isLoading: false,
        assistants: _sortedAssistants(assistants),
        clearError: true,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to load assistants right now.',
      );
    }
  }

  Future<void> saveAssistant(AssistantTemplate assistant) async {
    await ref.read(assistantCatalogRepositoryProvider).saveAssistant(assistant);
    await _syncPinnedAssistantId();
    await ref.read(privacyRepositoryProvider).recordUsage(
          feature: 'assistants',
          action: assistant.isCustom ? 'save_custom' : 'save_catalog',
          inputPreview: assistant.name,
          outputPreview: assistant.promptIntent,
          wasSuccessful: true,
        );
    await refresh();
  }

  Future<void> deleteAssistant(AssistantTemplate assistant) async {
    await ref
        .read(assistantCatalogRepositoryProvider)
        .deleteAssistant(assistant.id);
    await _syncPinnedAssistantId(deletingAssistantId: assistant.id);
    await ref.read(privacyRepositoryProvider).recordUsage(
          feature: 'assistants',
          action: 'delete',
          inputPreview: assistant.name,
          wasSuccessful: true,
        );
    await refresh();
  }

  Future<void> togglePinned(AssistantTemplate assistant) async {
    final List<AssistantTemplate> current = state.assistants;
    for (final AssistantTemplate item in current.where((item) => item.isPinned)) {
      if (item.id != assistant.id) {
        await ref.read(assistantCatalogRepositoryProvider).saveAssistant(
              item.copyWith(
                isPinned: false,
                updatedAt: DateTime.now(),
              ),
            );
      }
    }
    await saveAssistant(
      assistant.copyWith(
        isPinned: !assistant.isPinned,
        updatedAt: DateTime.now(),
      ),
    );
  }

  List<AssistantTemplate> _sortedAssistants(List<AssistantTemplate> assistants) {
    final List<AssistantTemplate> sorted = List<AssistantTemplate>.from(assistants);
    sorted.sort((AssistantTemplate left, AssistantTemplate right) {
      if (left.isPinned != right.isPinned) {
        return left.isPinned ? -1 : 1;
      }
      return right.updatedAt.compareTo(left.updatedAt);
    });
    return sorted;
  }

  Future<void> _syncPinnedAssistantId({String? deletingAssistantId}) async {
    final List<AssistantTemplate> assistants =
        await ref.read(assistantCatalogRepositoryProvider).loadCatalog();
    String? assistantId;
    for (final AssistantTemplate assistant in assistants) {
      if (assistant.isPinned && assistant.id != deletingAssistantId) {
        assistantId = assistant.id;
        break;
      }
    }
    await ref.read(keyboardPlatformServiceProvider).syncPinnedAssistant(
          assistantId,
        );
  }
}
