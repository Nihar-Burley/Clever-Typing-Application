import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/core_providers.dart';
import '../../../core/storage/privacy_repository.dart';

class PrivacyDashboardState {
  const PrivacyDashboardState({
    required this.isLoading,
    required this.usageHistory,
    required this.consentLogs,
    required this.exportJson,
    required this.nativeStatus,
    required this.errorMessage,
  });

  factory PrivacyDashboardState.initial() {
    return const PrivacyDashboardState(
      isLoading: true,
      usageHistory: <UsageHistoryEntry>[],
      consentLogs: <ConsentLogEntry>[],
      exportJson: null,
      nativeStatus: <String, Object?>{},
      errorMessage: null,
    );
  }

  final bool isLoading;
  final List<UsageHistoryEntry> usageHistory;
  final List<ConsentLogEntry> consentLogs;
  final String? exportJson;
  final Map<String, Object?> nativeStatus;
  final String? errorMessage;

  PrivacyDashboardState copyWith({
    bool? isLoading,
    List<UsageHistoryEntry>? usageHistory,
    List<ConsentLogEntry>? consentLogs,
    String? exportJson,
    Map<String, Object?>? nativeStatus,
    String? errorMessage,
    bool clearExport = false,
    bool clearError = false,
  }) {
    return PrivacyDashboardState(
      isLoading: isLoading ?? this.isLoading,
      usageHistory: usageHistory ?? this.usageHistory,
      consentLogs: consentLogs ?? this.consentLogs,
      exportJson: clearExport ? null : (exportJson ?? this.exportJson),
      nativeStatus: nativeStatus ?? this.nativeStatus,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final NotifierProvider<PrivacyDashboardNotifier, PrivacyDashboardState>
    privacyDashboardProvider =
    NotifierProvider<PrivacyDashboardNotifier, PrivacyDashboardState>(
  PrivacyDashboardNotifier.new,
);

class PrivacyDashboardNotifier extends Notifier<PrivacyDashboardState> {
  @override
  PrivacyDashboardState build() {
    Future<void>.microtask(refresh);
    return PrivacyDashboardState.initial();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final snapshot = await ref.read(privacyRepositoryProvider).loadDashboard();
      final nativeStatus =
          await ref.read(keyboardPlatformServiceProvider).readNativeStatus();
      state = state.copyWith(
        isLoading: false,
        usageHistory: snapshot.usageHistory,
        consentLogs: snapshot.consentLogs,
        nativeStatus: nativeStatus,
        clearError: true,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to load privacy data right now.',
      );
    }
  }

  Future<void> exportData() async {
    final snapshot = await ref.read(privacyRepositoryProvider).loadDashboard();
    state = state.copyWith(exportJson: snapshot.toExportJson(), clearError: true);
  }

  Future<void> clearAllData() async {
    await ref.read(privacyRepositoryProvider).clearAll();
    await ref.read(appPreferencesStoreProvider).remove('feature_flags');
    await ref.read(appPreferencesStoreProvider).remove('keyboard_settings');
    await ref.read(secureTokenStoreProvider).clear();
    await ref.read(keyboardPlatformServiceProvider).clearNativeData();
    await refresh();
  }
}
