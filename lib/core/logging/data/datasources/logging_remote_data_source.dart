import '../models/audit_event_model.dart';
import '../models/log_config_model.dart';
import '../models/log_entry_model.dart';

/// Remote data source for logging (API calls)
abstract class LoggingRemoteDataSource {
  /// Fetch logging configuration from server
  Future<LogConfigModel> fetchConfig();
  
  /// Send log entries to server
  Future<void> sendLogs(List<LogEntryModel> entries);
  
  /// Send audit events to server
  Future<void> sendAuditEvents(List<AuditEventModel> events);
}
