import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/audit_event.dart';
import '../../domain/entities/log_config.dart';
import '../../domain/entities/log_entry.dart';
import '../../domain/entities/log_level.dart';
import '../../domain/entities/performance_metric.dart';
import '../../domain/repositories/logging_repository.dart';
import '../datasources/logging_local_data_source.dart';
import '../datasources/logging_remote_data_source.dart';
import '../models/audit_event_model.dart';
import '../models/log_entry_model.dart';
import '../models/performance_metric_model.dart';

class LoggingRepositoryImpl implements LoggingRepository {
  final LoggingRemoteDataSource remoteDataSource;
  final LoggingLocalDataSource localDataSource;

  LoggingRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, LogConfig>> getConfig() async {
    try {
      // Try to get cached config first
      final cachedConfig = await localDataSource.getCachedConfig();
      
      if (cachedConfig != null) {
        return Right(_modelToEntity(cachedConfig));
      }
      
      // Return default config if no cache
      return const Right(LogConfig());
    } catch (e) {
      return const Right(LogConfig());
    }
  }

  @override
  Future<Either<Failure, LogConfig>> fetchRemoteConfig() async {
    try {
      final configModel = await remoteDataSource.fetchConfig();
      
      // Cache the config
      await localDataSource.cacheConfig(configModel);
      
      return Right(_modelToEntity(configModel));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      // Return cached or default config on failure
      final cachedConfig = await localDataSource.getCachedConfig();
      if (cachedConfig != null) {
        return Right(_modelToEntity(cachedConfig));
      }
      return const Right(LogConfig());
    }
  }

  @override
  Future<Either<Failure, void>> saveLogEntry(LogEntry entry) async {
    try {
      final model = LogEntryModel.fromEntity(entry);
      await localDataSource.saveLogEntry(model);
      
      // Rotate logs if needed
      final config = await localDataSource.getCachedConfig();
      if (config != null) {
        await localDataSource.rotateLogEntries(config.maxLocalEntries);
      }
      
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<LogEntry>>> getLocalLogs({
    int? limit,
    DateTime? since,
  }) async {
    try {
      final models = await localDataSource.getLocalLogs(
        limit: limit,
        since: since,
      );
      
      return Right(models.map((m) => m.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> syncLogsToServer(List<LogEntry> entries) async {
    try {
      final models = entries.map((e) => LogEntryModel.fromEntity(e)).toList();
      await remoteDataSource.sendLogs(models);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> clearLocalLogs() async {
    try {
      await localDataSource.clearLogs();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> savePerformanceMetric(
    PerformanceMetric metric,
  ) async {
    try {
      final model = PerformanceMetricModel.fromEntity(metric);
      await localDataSource.savePerformanceMetric(model);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<PerformanceMetric>>> getPerformanceMetrics({
    int? limit,
    DateTime? since,
  }) async {
    try {
      final models = await localDataSource.getPerformanceMetrics(
        limit: limit,
        since: since,
      );
      
      return Right(models.map((m) => m.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> saveAuditEvent(AuditEvent event) async {
    try {
      final model = AuditEventModel.fromEntity(event);
      await localDataSource.saveAuditEvent(model);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<AuditEvent>>> getAuditEvents({
    int? limit,
    DateTime? since,
  }) async {
    try {
      final models = await localDataSource.getAuditEvents(
        limit: limit,
        since: since,
      );
      
      return Right(models.map((m) => m.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> syncAuditEventsToServer(
    List<AuditEvent> events,
  ) async {
    try {
      final models = events.map((e) => AuditEventModel.fromEntity(e)).toList();
      await remoteDataSource.sendAuditEvents(models);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    }
  }

  LogConfig _modelToEntity(dynamic model) {
    final featureLevels = <String, LogLevel>{};
    model.featureLevels.forEach((key, value) {
      featureLevels[key] = LogLevel.fromString(value);
    });

    return LogConfig(
      enabled: model.enabled,
      globalLevel: LogLevel.fromString(model.globalLevel),
      featureLevels: featureLevels,
      remoteLoggingEnabled: model.remoteLoggingEnabled,
      localLoggingEnabled: model.localLoggingEnabled,
      performanceTrackingEnabled: model.performanceTrackingEnabled,
      auditTrackingEnabled: model.auditTrackingEnabled,
      performanceThreshold: model.performanceThreshold,
      tracingEnabledForUsers: model.tracingEnabledForUsers,
      maxLocalEntries: model.maxLocalEntries,
      syncIntervalSeconds: model.syncIntervalSeconds,
    );
  }
}
