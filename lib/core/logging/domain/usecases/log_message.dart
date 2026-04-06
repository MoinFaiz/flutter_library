import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/log_entry.dart';
import '../entities/log_level.dart';
import '../repositories/logging_repository.dart';

class LogMessageParams {
  final LogLevel level;
  final String message;
  final String? feature;
  final String? action;
  final Map<String, dynamic>? metadata;
  final String? stackTrace;
  final String? userId;
  final String? sessionId;

  const LogMessageParams({
    required this.level,
    required this.message,
    this.feature,
    this.action,
    this.metadata,
    this.stackTrace,
    this.userId,
    this.sessionId,
  });
}

/// Use case to log a message
class LogMessage implements UseCase<void, LogMessageParams> {
  final LoggingRepository repository;

  LogMessage(this.repository);

  @override
  Future<Either<Failure, void>> call(LogMessageParams params) async {
    // Get current config
    final configResult = await repository.getConfig();
    
    return configResult.fold(
      (failure) => Left(failure),
      (config) async {
        // Check if logging is enabled
        if (!config.enabled) {
          return const Right(null);
        }

        // Check if this log level should be logged
        final effectiveLevel = config.getLevelForFeature(params.feature);
        if (!params.level.shouldLog(effectiveLevel)) {
          return const Right(null);
        }

        // Create log entry
        final entry = LogEntry(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          timestamp: DateTime.now(),
          level: params.level,
          message: params.message,
          feature: params.feature,
          action: params.action,
          metadata: params.metadata,
          stackTrace: params.stackTrace,
          userId: params.userId,
          sessionId: params.sessionId,
        );

        // Save locally if enabled
        if (config.localLoggingEnabled) {
          await repository.saveLogEntry(entry);
        }

        return const Right(null);
      },
    );
  }
}
