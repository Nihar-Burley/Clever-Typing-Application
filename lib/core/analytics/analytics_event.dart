/// Structured analytics event emitted through the analytics service.
class AnalyticsEvent {
  const AnalyticsEvent({
    required this.name,
    required this.feature,
    required this.properties,
  });

  final String name;
  final String feature;
  final Map<String, Object?> properties;
}
