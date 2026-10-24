/// Error thrown when an AI service request fails.
class AiServiceException implements Exception {
  /// Creates an AI service exception.
  const AiServiceException(
    this.message, {
    this.statusCode,
    this.code,
  });

  /// User-safe or diagnostic message.
  final String message;

  /// Optional HTTP status code.
  final int? statusCode;

  /// Optional backend error code.
  final String? code;
}
