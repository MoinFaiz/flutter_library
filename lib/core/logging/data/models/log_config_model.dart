class LogConfigModel {
  final bool enabled;
  final String globalLevel;
  final Map<String, String> featureLevels;
  final bool remoteLoggingEnabled;
  final bool localLoggingEnabled;
  final bool performanceTrackingEnabled;
  final bool auditTrackingEnabled;
  final double performanceThreshold;
  final List<String> tracingEnabledForUsers;
  final int maxLocalEntries;
  final int syncIntervalSeconds;

  const LogConfigModel({
    required this.enabled,
    required this.globalLevel,
    required this.featureLevels,
    required this.remoteLoggingEnabled,
    required this.localLoggingEnabled,
    required this.performanceTrackingEnabled,
    required this.auditTrackingEnabled,
    required this.performanceThreshold,
    required this.tracingEnabledForUsers,
    required this.maxLocalEntries,
    required this.syncIntervalSeconds,
  });

  factory LogConfigModel.fromJson(Map<String, dynamic> json) {
    return LogConfigModel(
      enabled: json['enabled'] as bool? ?? true,
      globalLevel: json['global_level'] as String? ?? 'info',
      featureLevels: Map<String, String>.from(json['feature_levels'] ?? {}),
      remoteLoggingEnabled: json['remote_logging_enabled'] as bool? ?? true,
      localLoggingEnabled: json['local_logging_enabled'] as bool? ?? true,
      performanceTrackingEnabled: json['performance_tracking_enabled'] as bool? ?? true,
      auditTrackingEnabled: json['audit_tracking_enabled'] as bool? ?? true,
      performanceThreshold: (json['performance_threshold'] as num?)?.toDouble() ?? 100.0,
      tracingEnabledForUsers: List<String>.from(json['tracing_enabled_for_users'] ?? []),
      maxLocalEntries: json['max_local_entries'] as int? ?? 1000,
      syncIntervalSeconds: json['sync_interval_seconds'] as int? ?? 300,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'global_level': globalLevel,
      'feature_levels': featureLevels,
      'remote_logging_enabled': remoteLoggingEnabled,
      'local_logging_enabled': localLoggingEnabled,
      'performance_tracking_enabled': performanceTrackingEnabled,
      'audit_tracking_enabled': auditTrackingEnabled,
      'performance_threshold': performanceThreshold,
      'tracing_enabled_for_users': tracingEnabledForUsers,
      'max_local_entries': maxLocalEntries,
      'sync_interval_seconds': syncIntervalSeconds,
    };
  }
}
