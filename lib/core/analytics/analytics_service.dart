import 'analytics_event.dart';

/// Contract for analytics tracking.
abstract interface class AnalyticsService {
  Future<void> track(AnalyticsEvent event);
}
