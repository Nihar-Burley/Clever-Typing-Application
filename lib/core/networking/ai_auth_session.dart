/// Auth session used by the AI backend client.
class AiAuthSession {
  const AiAuthSession({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;

  bool get hasAccessToken => accessToken.isNotEmpty;
  bool get hasRefreshToken => refreshToken.isNotEmpty;
}
