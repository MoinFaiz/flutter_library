import 'package:flutter/foundation.dart';
import '../domain/entities/log_config.dart';
import '../domain/entities/log_level.dart';
import '../domain/usecases/log_message.dart';
import '../domain/usecases/track_audit_event.dart';
import '../domain/usecases/track_performance.dart';
import '../domain/repositories/logging_repository.dart';

/// Main logger service for the application
/// 
/// Provides convenient methods for logging at different levels
/// and integrates with the logging use cases
class AppLogger {
  final LogMessage _logMessage;
  final TrackAuditEvent _trackAuditEvent;
  final TrackPerformance _trackPerformance;
  final LoggingRepository _repository;

  String? _sessionId;
  String? _userId;

  AppLogger({
    required LogMessage logMessage,
    required TrackAuditEvent trackAuditEvent,
    required TrackPerformance trackPerformance,
    required LoggingRepository repository,
  })  : _logMessage = logMessage,
        _trackAuditEvent = trackAuditEvent,
        _trackPerformance = trackPerformance,
        _repository = repository {
    _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Set the current user ID for logging
  void setUserId(String? userId) {
    _userId = userId;
  }

  /// Set the current session ID
  void setSessionId(String? sessionId) {
    _sessionId = sessionId;
  }

  /// Log a trace message (most detailed)
  Future<void> trace(
    String message, {
    String? feature,
    String? action,
    Map<String, dynamic>? metadata,
  }) async {
    await _log(
      level: LogLevel.trace,
      message: message,
      feature: feature,
      action: action,
      metadata: metadata,
    );
  }

  /// Log a debug message
  Future<void> debug(
    String message, {
    String? feature,
    String? action,
    Map<String, dynamic>? metadata,
  }) async {
    await _log(
      level: LogLevel.debug,
      message: message,
      feature: feature,
      action: action,
      metadata: metadata,
    );
  }

  /// Log an info message
  Future<void> info(
    String message, {
    String? feature,
    String? action,
    Map<String, dynamic>? metadata,
  }) async {
    await _log(
      level: LogLevel.info,
      message: message,
      feature: feature,
      action: action,
      metadata: metadata,
    );
  }

  /// Log a warning message
  Future<void> warning(
    String message, {
    String? feature,
    String? action,
    Map<String, dynamic>? metadata,
  }) async {
    await _log(
      level: LogLevel.warning,
      message: message,
      feature: feature,
      action: action,
      metadata: metadata,
    );
  }

  /// Log an error message
  Future<void> error(
    String message, {
    String? feature,
    String? action,
    Map<String, dynamic>? metadata,
    Object? error,
    StackTrace? stackTrace,
  }) async {
    // Also print to console in debug mode
    if (kDebugMode) {
      debugPrint('ERROR: $message');
      if (error != null) debugPrint('Error: $error');
      if (stackTrace != null) debugPrint('StackTrace: $stackTrace');
    }

    await _log(
      level: LogLevel.error,
      message: message,
      feature: feature,
      action: action,
      metadata: {
        ...?metadata,
        if (error != null) 'error': error.toString(),
      },
      stackTrace: stackTrace?.toString(),
    );
  }

  /// Track a user action for audit purposes
  Future<void> audit({
    required String feature,
    required String action,
    Map<String, dynamic>? parameters,
    bool success = true,
  }) async {
    await _trackAuditEvent(TrackAuditEventParams(
      feature: feature,
      action: action,
      parameters: parameters,
      success: success,
      userId: _userId,
      sessionId: _sessionId,
    ));
  }

  /// Track performance of an operation
  /// Returns a PerformanceTracker that should be stopped when done
  PerformanceTracker trackPerformance({
    required String operation,
    String? feature,
    Map<String, dynamic>? metadata,
  }) {
    return PerformanceTracker(
      operation: operation,
      feature: feature,
      metadata: metadata,
      logger: this,
    );
  }

  /// Execute a function and track its performance
  Future<T> trackPerformanceAsync<T>({
    required String operation,
    String? feature,
    required Future<T> Function() fn,
    Map<String, dynamic>? metadata,
  }) async {
    final startTime = DateTime.now();
    bool success = true;
    
    try {
      return await fn();
    } catch (e) {
      success = false;
      rethrow;
    } finally {
      final endTime = DateTime.now();
      await _trackPerformance(TrackPerformanceParams(
        operation: operation,
        feature: feature,
        startTime: startTime,
        endTime: endTime,
        metadata: metadata,
        success: success,
      ));
    }
  }

  /// Execute a synchronous function and track its performance
  T trackPerformanceSync<T>({
    required String operation,
    String? feature,
    required T Function() fn,
    Map<String, dynamic>? metadata,
  }) {
    final startTime = DateTime.now();
    bool success = true;
    
    try {
      return fn();
    } catch (e) {
      success = false;
      rethrow;
    } finally {
      final endTime = DateTime.now();
      // Fire and forget - don't await
      _trackPerformance(TrackPerformanceParams(
        operation: operation,
        feature: feature,
        startTime: startTime,
        endTime: endTime,
        metadata: metadata,
        success: success,
      ));
    }
  }

  Future<void> _log({
    required LogLevel level,
    required String message,
    String? feature,
    String? action,
    Map<String, dynamic>? metadata,
    String? stackTrace,
  }) async {
    // Also print to console in debug mode for visibility
    if (kDebugMode && level.value <= LogLevel.warning.value) {
      debugPrint('[${level.name.toUpperCase()}] $message');
    }

    await _logMessage(LogMessageParams(
      level: level,
      message: message,
      feature: feature,
      action: action,
      metadata: metadata,
      stackTrace: stackTrace,
      userId: _userId,
      sessionId: _sessionId,
    ));
  }

  /// Get current logging configuration
  Future<LogConfig?> getConfig() async {
    final result = await _repository.getConfig();
    return result.fold(
      (_) => null,
      (config) => config,
    );
  }
}

/// Helper class to track performance of an operation
class PerformanceTracker {
  final String operation;
  final String? feature;
  final Map<String, dynamic>? metadata;
  final AppLogger logger;
  final DateTime startTime;

  PerformanceTracker({
    required this.operation,
    this.feature,
    this.metadata,
    required this.logger,
  }) : startTime = DateTime.now();

  /// Stop tracking and log the performance
  Future<void> stop({bool success = true}) async {
    final endTime = DateTime.now();
    await logger._trackPerformance(TrackPerformanceParams(
      operation: operation,
      feature: feature,
      startTime: startTime,
      endTime: endTime,
      metadata: metadata,
      success: success,
    ));
  }

  /// Get elapsed time in milliseconds
  double get elapsedMs {
    return DateTime.now().difference(startTime).inMicroseconds / 1000;
  }
}
