import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/performance_metric.dart';
import '../repositories/logging_repository.dart';

class TrackPerformanceParams {
  final String operation;
  final String? feature;
  final DateTime startTime;
  final DateTime endTime;
  final Map<String, dynamic>? metadata;
  final bool success;

  const TrackPerformanceParams({
    required this.operation,
    this.feature,
    required this.startTime,
    required this.endTime,
    this.metadata,
    this.success = true,
  });
}

/// Use case to track performance metrics
class TrackPerformance implements UseCase<void, TrackPerformanceParams> {
  final LoggingRepository repository;

  TrackPerformance(this.repository);

  @override
  Future<Either<Failure, void>> call(TrackPerformanceParams params) async {
    final configResult = await repository.getConfig();
    
    return configResult.fold(
      (failure) => Left(failure),
      (config) async {
        if (!config.enabled || !config.performanceTrackingEnabled) {
          return const Right(null);
        }

        final durationMs = params.endTime.difference(params.startTime).inMicroseconds / 1000;
        
        // Only track if duration exceeds threshold
        if (durationMs < config.performanceThreshold) {
          return const Right(null);
        }

        final metric = PerformanceMetric(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          operation: params.operation,
          feature: params.feature,
          startTime: params.startTime,
          endTime: params.endTime,
          durationMs: durationMs,
          metadata: params.metadata,
          success: params.success,
        );

        return repository.savePerformanceMetric(metric);
      },
    );
  }
}
