/// Contract for sending AI backend requests.
abstract interface class AiHttpClient {
  /// Sends a JSON GET request and returns the decoded response body.
  Future<Map<String, dynamic>> getJson(String path);

  /// Sends a JSON request and returns the decoded response body.
  Future<Map<String, dynamic>> postJson(
    String path, {
    required Map<String, dynamic> body,
  });
}
