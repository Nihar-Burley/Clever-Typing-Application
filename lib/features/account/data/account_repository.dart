import '../../../core/storage/app_preferences_store.dart';
import '../presentation/models/account_state.dart';

class AccountRepository {
  const AccountRepository(this._preferencesStore);

  final AppPreferencesStore _preferencesStore;

  static const String _accountKey = 'account_profile';

  Future<AccountState> load() async {
    final Map<String, Object?>? json = await _preferencesStore.readJson(_accountKey);
    if (json == null) {
      return AccountState.initial();
    }
    return AccountState(
      mode: _modeFromString(json['mode'] as String?),
      displayName: json['displayName'] as String? ?? 'Guest',
      email: json['email'] as String? ?? '',
      isLoading: false,
      errorMessage: null,
    );
  }

  Future<void> save({
    required AccountMode mode,
    required String displayName,
    required String email,
  }) {
    return _preferencesStore.writeJson(
      _accountKey,
      <String, Object?>{
        'mode': mode.name,
        'displayName': displayName,
        'email': email,
      },
    );
  }

  Future<void> clear() async {
    await _preferencesStore.remove(_accountKey);
  }

  AccountMode _modeFromString(String? value) {
    return switch (value) {
      'email' => AccountMode.email,
      'google' => AccountMode.google,
      _ => AccountMode.guest,
    };
  }
}
