import 'package:flutter_library/core/logging/domain/entities/performance_metric.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PerformanceMetric', () {
    final startTime = DateTime(2025, 10, 31, 10, 30, 0);
    final endTime = DateTime(2025, 10, 31, 10, 30, 1);

    test('should create instance with required fields', () {
      final metric = PerformanceMetric(
        id: '123',
        operation: 'fetch_books',
        startTime: startTime,
        endTime: endTime,
        durationMs: 1000.0,
      );

      expect(metric.id, '123');
      expect(metric.operation, 'fetch_books');
      expect(metric.feature, null);
      expect(metric.startTime, startTime);
      expect(metric.endTime, endTime);
      expect(metric.durationMs, 1000.0);
      expect(metric.metadata, null);
      expect(metric.success, true);
    });

    test('should create instance with all fields', () {
      final metric = PerformanceMetric(
        id: '123',
        operation: 'api_call',
        feature: 'books',
        startTime: startTime,
        endTime: endTime,
        durationMs: 250.5,
        metadata: {'endpoint': '/books', 'method': 'GET'},
        success: false,
      );

      expect(metric.id, '123');
      expect(metric.operation, 'api_call');
      expect(metric.feature, 'books');
      expect(metric.startTime, startTime);
      expect(metric.endTime, endTime);
      expect(metric.durationMs, 250.5);
      expect(metric.metadata, {'endpoint': '/books', 'method': 'GET'});
      expect(metric.success, false);
    });

    test('should support equality', () {
      final metric1 = PerformanceMetric(
        id: '123',
        operation: 'test',
        startTime: startTime,
        endTime: endTime,
        durationMs: 100.0,
      );

      final metric2 = PerformanceMetric(
        id: '123',
        operation: 'test',
        startTime: startTime,
        endTime: endTime,
        durationMs: 100.0,
      );

      final metric3 = PerformanceMetric(
        id: '456',
        operation: 'test',
        startTime: startTime,
        endTime: endTime,
        durationMs: 100.0,
      );

      expect(metric1, equals(metric2));
      expect(metric1, isNot(equals(metric3)));
    });
  });
}
