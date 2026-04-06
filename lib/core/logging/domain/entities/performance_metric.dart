import 'package:equatable/equatable.dart';

/// Represents a performance measurement
class PerformanceMetric extends Equatable {
  final String id;
  final String operation;
  final String? feature;
  final DateTime startTime;
  final DateTime endTime;
  final double durationMs;
  final Map<String, dynamic>? metadata;
  final bool success;

  const PerformanceMetric({
    required this.id,
    required this.operation,
    this.feature,
    required this.startTime,
    required this.endTime,
    required this.durationMs,
    this.metadata,
    this.success = true,
  });

  @override
  List<Object?> get props => [
        id,
        operation,
        feature,
        startTime,
        endTime,
        durationMs,
        metadata,
        success,
      ];
}
