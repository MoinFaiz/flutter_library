import '../models/audit_event_model.dart';
import '../models/log_config_model.dart';
import '../models/log_entry_model.dart';
import '../models/performance_metric_model.dart';

/// Local data source for logging (uses shared preferences and local storage)
abstract class LoggingLocalDataSource {
  /// Get cached logging configuration
  Future<LogConfigModel?> getCachedConfig();
  
  /// Cache logging configuration
  Future<void> cacheConfig(LogConfigModel config);
  
  /// Save log entry to local storage
  Future<void> saveLogEntry(LogEntryModel entry);
  
  /// Get local log entries
  Future<List<LogEntryModel>> getLocalLogs({
    int? limit,
    DateTime? since,
  });
  
  /// Clear all local logs
  Future<void> clearLogs();
  
  /// Save performance metric
  Future<void> savePerformanceMetric(PerformanceMetricModel metric);
  
  /// Get performance metrics
  Future<List<PerformanceMetricModel>> getPerformanceMetrics({
    int? limit,
    DateTime? since,
  });
  
  /// Save audit event
  Future<void> saveAuditEvent(AuditEventModel event);
  
  /// Get audit events
  Future<List<AuditEventModel>> getAuditEvents({
    int? limit,
    DateTime? since,
  });
  
  /// Clear old entries to maintain max limit
  Future<void> rotateLogEntries(int maxEntries);
}
