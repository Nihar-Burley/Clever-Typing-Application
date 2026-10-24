import '../logging/app_logger.dart';
import 'analytics_event.dart';
import 'analytics_service.dart';

/// Logger-backed analytics implementation used until a production SDK is wired.
class ConsoleAnalyticsService implements AnalyticsService {
  const ConsoleAnalyticsService(this._logger);

  final AppLogger _logger;

  @override
  Future<void> track(AnalyticsEvent event) async {
    _logger.info(
      event.feature,
      event.name,
      event.properties.entries
          .map((MapEntry<String, Object?> entry) => '${entry.key}=${entry.value}')
          .join(', '),
    );
  }
}
