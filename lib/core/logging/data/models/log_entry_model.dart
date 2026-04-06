import '../../domain/entities/log_entry.dart';
import '../../domain/entities/log_level.dart';

class LogEntryModel {
  final String id;
  final String timestamp;
  final String level;
  final String message;
  final String? feature;
  final String? action;
  final Map<String, dynamic>? metadata;
  final String? stackTrace;
  final String? userId;
  final String? sessionId;
  final double? performanceMetric;

  const LogEntryModel({
    required this.id,
    required this.timestamp,
    required this.level,
    required this.message,
    this.feature,
    this.action,
    this.metadata,
    this.stackTrace,
    this.userId,
    this.sessionId,
    this.performanceMetric,
  });

  factory LogEntryModel.fromEntity(LogEntry entity) {
    return LogEntryModel(
      id: entity.id,
      timestamp: entity.timestamp.toIso8601String(),
      level: entity.level.name,
      message: entity.message,
      feature: entity.feature,
      action: entity.action,
      metadata: entity.metadata,
      stackTrace: entity.stackTrace,
      userId: entity.userId,
      sessionId: entity.sessionId,
      performanceMetric: entity.performanceMetric,
    );
  }

  factory LogEntryModel.fromJson(Map<String, dynamic> json) {
    return LogEntryModel(
      id: json['id'] as String,
      timestamp: json['timestamp'] as String,
      level: json['level'] as String,
      message: json['message'] as String,
      feature: json['feature'] as String?,
      action: json['action'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      stackTrace: json['stack_trace'] as String?,
      userId: json['user_id'] as String?,
      sessionId: json['session_id'] as String?,
      performanceMetric: (json['performance_metric'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp,
      'level': level,
      'message': message,
      if (feature != null) 'feature': feature,
      if (action != null) 'action': action,
      if (metadata != null) 'metadata': metadata,
      if (stackTrace != null) 'stack_trace': stackTrace,
      if (userId != null) 'user_id': userId,
      if (sessionId != null) 'session_id': sessionId,
      if (performanceMetric != null) 'performance_metric': performanceMetric,
    };
  }

  LogEntry toEntity() {
    return LogEntry(
      id: id,
      timestamp: DateTime.parse(timestamp),
      level: LogLevel.fromString(level),
      message: message,
      feature: feature,
      action: action,
      metadata: metadata,
      stackTrace: stackTrace,
      userId: userId,
      sessionId: sessionId,
      performanceMetric: performanceMetric,
    );
  }
}
