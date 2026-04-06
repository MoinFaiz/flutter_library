import '../../domain/entities/performance_metric.dart';

class PerformanceMetricModel {
  final String id;
  final String operation;
  final String? feature;
  final String startTime;
  final String endTime;
  final double durationMs;
  final Map<String, dynamic>? metadata;
  final bool success;

  const PerformanceMetricModel({
    required this.id,
    required this.operation,
    this.feature,
    required this.startTime,
    required this.endTime,
    required this.durationMs,
    this.metadata,
    required this.success,
  });

  factory PerformanceMetricModel.fromEntity(PerformanceMetric entity) {
    return PerformanceMetricModel(
      id: entity.id,
      operation: entity.operation,
      feature: entity.feature,
      startTime: entity.startTime.toIso8601String(),
      endTime: entity.endTime.toIso8601String(),
      durationMs: entity.durationMs,
      metadata: entity.metadata,
      success: entity.success,
    );
  }

  factory PerformanceMetricModel.fromJson(Map<String, dynamic> json) {
    return PerformanceMetricModel(
      id: json['id'] as String,
      operation: json['operation'] as String,
      feature: json['feature'] as String?,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      durationMs: (json['duration_ms'] as num).toDouble(),
      metadata: json['metadata'] as Map<String, dynamic>?,
      success: json['success'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'operation': operation,
      if (feature != null) 'feature': feature,
      'start_time': startTime,
      'end_time': endTime,
      'duration_ms': durationMs,
      if (metadata != null) 'metadata': metadata,
      'success': success,
    };
  }

  PerformanceMetric toEntity() {
    return PerformanceMetric(
      id: id,
      operation: operation,
      feature: feature,
      startTime: DateTime.parse(startTime),
      endTime: DateTime.parse(endTime),
      durationMs: durationMs,
      metadata: metadata,
      success: success,
    );
  }
}
