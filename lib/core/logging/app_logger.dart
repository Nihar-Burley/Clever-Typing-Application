/// Minimal logging contract for the initial app shell.
abstract interface class AppLogger {
  /// Records a debug or informational event.
  void info(String feature, String action, String result);

  /// Records an error event.
  void error(String feature, String action, Object error);
}
