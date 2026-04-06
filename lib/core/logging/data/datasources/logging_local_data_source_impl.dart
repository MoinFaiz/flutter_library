import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/audit_event_model.dart';
import '../models/log_config_model.dart';
import '../models/log_entry_model.dart';
import '../models/performance_metric_model.dart';
import 'logging_local_data_source.dart';

const String _configKey = 'logging_config';
const String _logsKey = 'log_entries';
const String _performanceKey = 'performance_metrics';
const String _auditKey = 'audit_events';

class LoggingLocalDataSourceImpl implements LoggingLocalDataSource {
  final SharedPreferences sharedPreferences;

  LoggingLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<LogConfigModel?> getCachedConfig() async {
    final jsonString = sharedPreferences.getString(_configKey);
    if (jsonString != null) {
      return LogConfigModel.fromJson(json.decode(jsonString));
    }
    return null;
  }

  @override
  Future<void> cacheConfig(LogConfigModel config) async {
    await sharedPreferences.setString(
      _configKey,
      json.encode(config.toJson()),
    );
  }

  @override
  Future<void> saveLogEntry(LogEntryModel entry) async {
    final logs = await getLocalLogs();
    logs.add(entry);
    
    final jsonList = logs.map((e) => e.toJson()).toList();
    await sharedPreferences.setString(_logsKey, json.encode(jsonList));
  }

  @override
  Future<List<LogEntryModel>> getLocalLogs({int? limit, DateTime? since}) async {
    final jsonString = sharedPreferences.getString(_logsKey);
    if (jsonString == null) return [];

    final jsonList = json.decode(jsonString) as List;
    var logs = jsonList
        .map((e) => LogEntryModel.fromJson(e as Map<String, dynamic>))
        .toList();

    // Filter by date if provided
    if (since != null) {
      logs = logs.where((log) {
        final logTime = DateTime.parse(log.timestamp);
        return logTime.isAfter(since);
      }).toList();
    }

    // Apply limit if provided
    if (limit != null && logs.length > limit) {
      logs = logs.sublist(logs.length - limit);
    }

    return logs;
  }

  @override
  Future<void> clearLogs() async {
    await sharedPreferences.remove(_logsKey);
  }

  @override
  Future<void> savePerformanceMetric(PerformanceMetricModel metric) async {
    final metrics = await getPerformanceMetrics();
    metrics.add(metric);
    
    final jsonList = metrics.map((e) => e.toJson()).toList();
    await sharedPreferences.setString(_performanceKey, json.encode(jsonList));
  }

  @override
  Future<List<PerformanceMetricModel>> getPerformanceMetrics({
    int? limit,
    DateTime? since,
  }) async {
    final jsonString = sharedPreferences.getString(_performanceKey);
    if (jsonString == null) return [];

    final jsonList = json.decode(jsonString) as List;
    var metrics = jsonList
        .map((e) => PerformanceMetricModel.fromJson(e as Map<String, dynamic>))
        .toList();

    if (since != null) {
      metrics = metrics.where((metric) {
        final metricTime = DateTime.parse(metric.startTime);
        return metricTime.isAfter(since);
      }).toList();
    }

    if (limit != null && metrics.length > limit) {
      metrics = metrics.sublist(metrics.length - limit);
    }

    return metrics;
  }

  @override
  Future<void> saveAuditEvent(AuditEventModel event) async {
    final events = await getAuditEvents();
    events.add(event);
    
    final jsonList = events.map((e) => e.toJson()).toList();
    await sharedPreferences.setString(_auditKey, json.encode(jsonList));
  }

  @override
  Future<List<AuditEventModel>> getAuditEvents({
    int? limit,
    DateTime? since,
  }) async {
    final jsonString = sharedPreferences.getString(_auditKey);
    if (jsonString == null) return [];

    final jsonList = json.decode(jsonString) as List;
    var events = jsonList
        .map((e) => AuditEventModel.fromJson(e as Map<String, dynamic>))
        .toList();

    if (since != null) {
      events = events.where((event) {
        final eventTime = DateTime.parse(event.timestamp);
        return eventTime.isAfter(since);
      }).toList();
    }

    if (limit != null && events.length > limit) {
      events = events.sublist(events.length - limit);
    }

    return events;
  }

  @override
  Future<void> rotateLogEntries(int maxEntries) async {
    final logs = await getLocalLogs();
    
    if (logs.length > maxEntries) {
      // Keep only the most recent entries
      final trimmedLogs = logs.sublist(logs.length - maxEntries);
      final jsonList = trimmedLogs.map((e) => e.toJson()).toList();
      await sharedPreferences.setString(_logsKey, json.encode(jsonList));
    }
  }
}
