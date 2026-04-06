import 'package:equatable/equatable.dart';
import 'log_level.dart';

/// Represents a single log entry with all metadata
class LogEntry extends Equatable {
  final String id;
  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final String? feature; // e.g., 'books', 'cart', 'favorites'
  final String? action; // e.g., 'search', 'add_to_cart', 'toggle_favorite'
  final Map<String, dynamic>? metadata;
  final String? stackTrace;
  final String? userId;
  final String? sessionId;
  final double? performanceMetric; // execution time in ms

  const LogEntry({
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

  LogEntry copyWith({
    String? id,
    DateTime? timestamp,
    LogLevel? level,
    String? message,
    String? feature,
    String? action,
    Map<String, dynamic>? metadata,
    String? stackTrace,
    String? userId,
    String? sessionId,
    double? performanceMetric,
  }) {
    return LogEntry(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      level: level ?? this.level,
      message: message ?? this.message,
      feature: feature ?? this.feature,
      action: action ?? this.action,
      metadata: metadata ?? this.metadata,
      stackTrace: stackTrace ?? this.stackTrace,
      userId: userId ?? this.userId,
      sessionId: sessionId ?? this.sessionId,
      performanceMetric: performanceMetric ?? this.performanceMetric,
    );
  }

  @override
  List<Object?> get props => [
        id,
        timestamp,
        level,
        message,
        feature,
        action,
        metadata,
        stackTrace,
        userId,
        sessionId,
        performanceMetric,
      ];
}
