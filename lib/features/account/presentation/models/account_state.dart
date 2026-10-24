enum AccountMode {
  guest,
  email,
  google,
}

class AccountState {
  const AccountState({
    required this.mode,
    required this.displayName,
    required this.email,
    required this.isLoading,
    required this.errorMessage,
  });

  factory AccountState.initial() {
    return const AccountState(
      mode: AccountMode.guest,
      displayName: 'Guest',
      email: '',
      isLoading: false,
      errorMessage: null,
    );
  }

  final AccountMode mode;
  final String displayName;
  final String email;
  final bool isLoading;
  final String? errorMessage;

  bool get isGuest => mode == AccountMode.guest;

  AccountState copyWith({
    AccountMode? mode,
    String? displayName,
    String? email,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AccountState(
      mode: mode ?? this.mode,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
