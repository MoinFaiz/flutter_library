/// Represents the severity level of a log entry
enum LogLevel {
  /// No logging at all - completely disabled
  none(0),
  
  /// Only critical errors that prevent app functionality
  error(1),
  
  /// Warnings and errors
  warning(2),
  
  /// General app flow information (default)
  info(3),
  
  /// Detailed debugging information
  debug(4),
  
  /// Very detailed execution traces
  trace(5);

  const LogLevel(this.value);
  
  final int value;

  /// Check if this level should log based on configured level
  bool shouldLog(LogLevel configuredLevel) {
    return value <= configuredLevel.value;
  }

  static LogLevel fromString(String level) {
    return LogLevel.values.firstWhere(
      (e) => e.name.toLowerCase() == level.toLowerCase(),
      orElse: () => LogLevel.info,
    );
  }
}
