/// Runtime configuration for AI service requests.
class AiBackendConfig {
  /// Creates backend configuration.
  const AiBackendConfig({
    required this.baseUrl,
    required this.apiKey,
    required this.refreshPath,
  });

  /// Builds configuration from compile-time environment variables.
  factory AiBackendConfig.fromEnvironment() {
    return const AiBackendConfig(
      baseUrl: String.fromEnvironment('AI_BASE_URL'),
      apiKey: String.fromEnvironment('AI_API_KEY'),
      refreshPath: String.fromEnvironment(
        'AI_REFRESH_PATH',
        defaultValue: '/v1/auth/refresh',
      ),
    );
  }

  /// Base URL for the AI backend.
  final String baseUrl;

  /// Bearer token or API key for the AI backend.
  final String apiKey;

  /// Refresh endpoint used when bearer access tokens expire.
  final String refreshPath;

  /// Whether the backend is configured for remote calls.
  bool get isConfigured => baseUrl.isNotEmpty && apiKey.isNotEmpty;
}
