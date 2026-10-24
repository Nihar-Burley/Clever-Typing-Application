import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../networking/ai_auth_session.dart';

/// Secure storage for backend auth tokens.
class SecureTokenStore {
  const SecureTokenStore(this._storage);

  final FlutterSecureStorage _storage;

  static const String _accessTokenKey = 'ai_access_token';
  static const String _refreshTokenKey = 'ai_refresh_token';

  Future<AiAuthSession> read() async {
    return AiAuthSession(
      accessToken: await _storage.read(key: _accessTokenKey) ?? '',
      refreshToken: await _storage.read(key: _refreshTokenKey) ?? '',
    );
  }

  Future<void> write(AiAuthSession session) async {
    await _storage.write(key: _accessTokenKey, value: session.accessToken);
    await _storage.write(key: _refreshTokenKey, value: session.refreshToken);
  }

  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}
