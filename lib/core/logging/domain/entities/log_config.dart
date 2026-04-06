import 'package:equatable/equatable.dart';
import 'log_level.dart';

/// Configuration for logging system
class LogConfig extends Equatable {
  /// Global logging enabled/disabled
  final bool enabled;
  
  /// Global log level
  final LogLevel globalLevel;
  
  /// Feature-specific log levels (overrides global)
  final Map<String, LogLevel> featureLevels;
  
  /// Whether to send logs to server
  final bool remoteLoggingEnabled;
  
  /// Whether to store logs locally
  final bool localLoggingEnabled;
  
  /// Whether performance tracking is enabled
  final bool performanceTrackingEnabled;
  
  /// Whether audit tracking is enabled
  final bool auditTrackingEnabled;
  
  /// Minimum execution time (ms) to log performance
  final double performanceThreshold;
  
  /// User IDs to enable tracing for (empty = all users)
  final List<String> tracingEnabledForUsers;
  
  /// Maximum local log entries before rotation
  final int maxLocalEntries;
  
  /// How often to sync logs to server (in seconds)
  final int syncIntervalSeconds;

  const LogConfig({
    this.enabled = true,
    this.globalLevel = LogLevel.info,
    this.featureLevels = const {},
    this.remoteLoggingEnabled = true,
    this.localLoggingEnabled = true,
    this.performanceTrackingEnabled = true,
    this.auditTrackingEnabled = true,
    this.performanceThreshold = 100.0, // 100ms
    this.tracingEnabledForUsers = const [],
    this.maxLocalEntries = 1000,
    this.syncIntervalSeconds = 300, // 5 minutes
  });

  /// Get effective log level for a feature
  LogLevel getLevelForFeature(String? feature) {
    if (!enabled) return LogLevel.none;
    if (feature == null) return globalLevel;
    return featureLevels[feature] ?? globalLevel;
  }

  /// Check if tracing is enabled for a specific user
  bool isTracingEnabledForUser(String? userId) {
    if (!enabled) return false;
    if (tracingEnabledForUsers.isEmpty) return true;
    if (userId == null) return false;
    return tracingEnabledForUsers.contains(userId);
  }

  LogConfig copyWith({
    bool? enabled,
    LogLevel? globalLevel,
    Map<String, LogLevel>? featureLevels,
    bool? remoteLoggingEnabled,
    bool? localLoggingEnabled,
    bool? performanceTrackingEnabled,
    bool? auditTrackingEnabled,
    double? performanceThreshold,
    List<String>? tracingEnabledForUsers,
    int? maxLocalEntries,
    int? syncIntervalSeconds,
  }) {
    return LogConfig(
      enabled: enabled ?? this.enabled,
      globalLevel: globalLevel ?? this.globalLevel,
      featureLevels: featureLevels ?? this.featureLevels,
      remoteLoggingEnabled: remoteLoggingEnabled ?? this.remoteLoggingEnabled,
      localLoggingEnabled: localLoggingEnabled ?? this.localLoggingEnabled,
      performanceTrackingEnabled: performanceTrackingEnabled ?? this.performanceTrackingEnabled,
      auditTrackingEnabled: auditTrackingEnabled ?? this.auditTrackingEnabled,
      performanceThreshold: performanceThreshold ?? this.performanceThreshold,
      tracingEnabledForUsers: tracingEnabledForUsers ?? this.tracingEnabledForUsers,
      maxLocalEntries: maxLocalEntries ?? this.maxLocalEntries,
      syncIntervalSeconds: syncIntervalSeconds ?? this.syncIntervalSeconds,
    );
  }

  @override
  List<Object?> get props => [
        enabled,
        globalLevel,
        featureLevels,
        remoteLoggingEnabled,
        localLoggingEnabled,
        performanceTrackingEnabled,
        auditTrackingEnabled,
        performanceThreshold,
        tracingEnabledForUsers,
        maxLocalEntries,
        syncIntervalSeconds,
      ];
}
