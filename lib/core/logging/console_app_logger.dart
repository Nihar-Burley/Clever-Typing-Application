import 'app_logger.dart';

/// Temporary logger implementation for the skeleton app.
class ConsoleAppLogger implements AppLogger {
  @override
  void error(String feature, String action, Object error) {
    // ignore: avoid_print
    print('ERROR [$feature/$action] $error');
  }

  @override
  void info(String feature, String action, String result) {
    // ignore: avoid_print
    print('INFO [$feature/$action] $result');
  }
}
