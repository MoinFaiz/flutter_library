import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/audit_event.dart';
import '../entities/log_config.dart';
import '../entities/log_entry.dart';
import '../entities/performance_metric.dart';

/// Repository for logging operations
abstract class LoggingRepository {
  /// Get current logging configuration
  Future<Either<Failure, LogConfig>> getConfig();
  
  /// Update logging configuration from remote
  Future<Either<Failure, LogConfig>> fetchRemoteConfig();
  
  /// Save log entry locally
  Future<Either<Failure, void>> saveLogEntry(LogEntry entry);
  
  /// Get local log entries
  Future<Either<Failure, List<LogEntry>>> getLocalLogs({
    int? limit,
    DateTime? since,
  });
  
  /// Send logs to server
  Future<Either<Failure, void>> syncLogsToServer(List<LogEntry> entries);
  
  /// Clear local logs
  Future<Either<Failure, void>> clearLocalLogs();
  
  /// Save performance metric
  Future<Either<Failure, void>> savePerformanceMetric(PerformanceMetric metric);
  
  /// Get performance metrics
  Future<Either<Failure, List<PerformanceMetric>>> getPerformanceMetrics({
    int? limit,
    DateTime? since,
  });
  
  /// Save audit event
  Future<Either<Failure, void>> saveAuditEvent(AuditEvent event);
  
  /// Get audit events
  Future<Either<Failure, List<AuditEvent>>> getAuditEvents({
    int? limit,
    DateTime? since,
  });
  
  /// Sync audit events to server
  Future<Either<Failure, void>> syncAuditEventsToServer(List<AuditEvent> events);
}
