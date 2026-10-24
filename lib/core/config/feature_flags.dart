/// Remote feature-flag snapshot consumed by the app.
class FeatureFlags {
  const FeatureFlags({
    required this.assistantCreationEnabled,
    required this.assistantCatalogEnabled,
    required this.smartReplyEnabled,
    required this.incognitoModeEnabled,
    required this.freeDailyQuota,
  });

  factory FeatureFlags.defaults() {
    return const FeatureFlags(
      assistantCreationEnabled: true,
      assistantCatalogEnabled: true,
      smartReplyEnabled: true,
      incognitoModeEnabled: true,
      freeDailyQuota: 10,
    );
  }

  factory FeatureFlags.fromJson(Map<String, Object?> json) {
    return FeatureFlags(
      assistantCreationEnabled: json['assistantCreationEnabled'] != false,
      assistantCatalogEnabled: json['assistantCatalogEnabled'] != false,
      smartReplyEnabled: json['smartReplyEnabled'] != false,
      incognitoModeEnabled: json['incognitoModeEnabled'] != false,
      freeDailyQuota: (json['freeDailyQuota'] as int?) ?? 10,
    );
  }

  final bool assistantCreationEnabled;
  final bool assistantCatalogEnabled;
  final bool smartReplyEnabled;
  final bool incognitoModeEnabled;
  final int freeDailyQuota;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'assistantCreationEnabled': assistantCreationEnabled,
      'assistantCatalogEnabled': assistantCatalogEnabled,
      'smartReplyEnabled': smartReplyEnabled,
      'incognitoModeEnabled': incognitoModeEnabled,
      'freeDailyQuota': freeDailyQuota,
    };
  }
}
