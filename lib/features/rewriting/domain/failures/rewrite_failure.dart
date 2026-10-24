/// Base failure type for rewrite and grammar-correction operations.
class RewriteFailure implements Exception {
  /// Creates a rewrite failure.
  const RewriteFailure(this.message);

  /// User-safe error message.
  final String message;
}
