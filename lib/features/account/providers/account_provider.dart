import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/core_providers.dart';
import '../data/account_repository.dart';
import '../presentation/models/account_state.dart';

final Provider<AccountRepository> accountRepositoryProvider =
    Provider<AccountRepository>(
  (Ref<AccountRepository> ref) => AccountRepository(
    ref.watch(appPreferencesStoreProvider),
  ),
);

final NotifierProvider<AccountNotifier, AccountState> accountProvider =
    NotifierProvider<AccountNotifier, AccountState>(AccountNotifier.new);

class AccountNotifier extends Notifier<AccountState> {
  @override
  AccountState build() {
    Future<void>.microtask(refresh);
    return AccountState.initial();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final AccountState loaded = await ref.read(accountRepositoryProvider).load();
      state = loaded;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to load account state right now.',
      );
    }
  }

  Future<void> continueAsGuest() async {
    await ref.read(accountRepositoryProvider).save(
          mode: AccountMode.guest,
          displayName: 'Guest',
          email: '',
        );
    await ref.read(privacyRepositoryProvider).recordConsent(
          consentType: 'account_mode_selected',
          wasGranted: true,
          metadata: 'guest',
        );
    await refresh();
  }

  Future<void> signInWithEmail({
    required String displayName,
    required String email,
  }) async {
    if (displayName.trim().isEmpty || email.trim().isEmpty || !email.contains('@')) {
      state = state.copyWith(
        errorMessage: 'Enter a valid name and email address.',
      );
      return;
    }
    await ref.read(accountRepositoryProvider).save(
          mode: AccountMode.email,
          displayName: displayName.trim(),
          email: email.trim(),
        );
    await ref.read(privacyRepositoryProvider).recordConsent(
          consentType: 'account_mode_selected',
          wasGranted: true,
          metadata: 'email',
        );
    await refresh();
  }

  Future<void> connectGoogleProfile({
    required String displayName,
    required String email,
  }) async {
    if (displayName.trim().isEmpty ||
        email.trim().isEmpty ||
        !email.contains('@') ||
        !email.toLowerCase().endsWith('gmail.com')) {
      state = state.copyWith(
        errorMessage: 'Enter a valid Gmail address for Google profile mode.',
      );
      return;
    }
    await ref.read(accountRepositoryProvider).save(
          mode: AccountMode.google,
          displayName: displayName.trim(),
          email: email.trim(),
        );
    await ref.read(privacyRepositoryProvider).recordConsent(
          consentType: 'account_mode_selected',
          wasGranted: true,
          metadata: 'google',
        );
    await refresh();
  }

  Future<void> signOut() async {
    await ref.read(accountRepositoryProvider).clear();
    await continueAsGuest();
  }
}
