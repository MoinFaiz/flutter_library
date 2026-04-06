import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/core/logging/data/models/performance_metric_model.dart';
import 'package:flutter_library/core/logging/domain/entities/performance_metric.dart';

void main() {
  group('PerformanceMetricModel', () {
    final startTime = DateTime(2024, 1, 1, 12, 0, 0);
    final endTime = DateTime(2024, 1, 1, 12, 0, 1, 500);

    final testEntity = PerformanceMetric(
      id: 'perf-123',
      operation: 'fetchData',
      feature: 'books',
      startTime: startTime,
      endTime: endTime,
      durationMs: 1500.0,
      metadata: {'source': 'cache', 'items': 10},
      success: true,
    );

    final testJson = {
      'id': 'perf-123',
      'operation': 'fetchData',
      'feature': 'books',
      'start_time': '2024-01-01T12:00:00.000',
      'end_time': '2024-01-01T12:00:01.500',
      'duration_ms': 1500.0,
      'metadata': {'source': 'cache', 'items': 10},
      'success': true,
    };

    group('fromEntity', () {
      test('should create model from entity with all fields', () {
        final model = PerformanceMetricModel.fromEntity(testEntity);

        expect(model.id, equals('perf-123'));
        expect(model.operation, equals('fetchData'));
        expect(model.feature, equals('books'));
        expect(model.startTime, equals('2024-01-01T12:00:00.000'));
        expect(model.endTime, equals('2024-01-01T12:00:01.500'));
        expect(model.durationMs, equals(1500.0));
        expect(model.metadata, equals({'source': 'cache', 'items': 10}));
        expect(model.success, isTrue);
      });

      test('should create model from entity with minimal fields', () {
        final minimalEntity = PerformanceMetric(
          id: 'min-id',
          operation: 'test',
          startTime: startTime,
          endTime: endTime,
          durationMs: 100.0,
          success: true,
        );

        final model = PerformanceMetricModel.fromEntity(minimalEntity);

        expect(model.id, equals('min-id'));
        expect(model.operation, equals('test'));
        expect(model.feature, isNull);
        expect(model.metadata, isNull);
        expect(model.durationMs, equals(100.0));
      });

      test('should handle failed operation', () {
        final failedEntity = PerformanceMetric(
          id: 'fail-id',
          operation: 'upload',
          startTime: startTime,
          endTime: endTime,
          durationMs: 5000.0,
          success: false,
        );

        final model = PerformanceMetricModel.fromEntity(failedEntity);
        expect(model.success, isFalse);
      });
    });

    group('fromJson', () {
      test('should create model from json with all fields', () {
        final model = PerformanceMetricModel.fromJson(testJson);

        expect(model.id, equals('perf-123'));
        expect(model.operation, equals('fetchData'));
        expect(model.feature, equals('books'));
        expect(model.startTime, equals('2024-01-01T12:00:00.000'));
        expect(model.endTime, equals('2024-01-01T12:00:01.500'));
        expect(model.durationMs, equals(1500.0));
        expect(model.metadata, equals({'source': 'cache', 'items': 10}));
        expect(model.success, isTrue);
      });

      test('should create model from json with minimal fields', () {
        final minimalJson = {
          'id': 'min-id',
          'operation': 'test',
          'start_time': '2024-01-01T12:00:00.000',
          'end_time': '2024-01-01T12:00:01.000',
          'duration_ms': 1000.0,
        };

        final model = PerformanceMetricModel.fromJson(minimalJson);

        expect(model.id, equals('min-id'));
        expect(model.operation, equals('test'));
        expect(model.feature, isNull);
        expect(model.metadata, isNull);
        expect(model.success, isTrue); // defaults to true
      });

      test('should handle integer duration', () {
        final json = {
          ...testJson,
          'duration_ms': 1500, // integer
        };

        final model = PerformanceMetricModel.fromJson(json);
        expect(model.durationMs, equals(1500.0));
      });

      test('should default success to true when missing', () {
        final json = Map<String, dynamic>.from(testJson)..remove('success');

        final model = PerformanceMetricModel.fromJson(json);
        expect(model.success, isTrue);
      });
    });

    group('toJson', () {
      test('should convert model to json with all fields', () {
        final model = PerformanceMetricModel.fromEntity(testEntity);
        final json = model.toJson();

        expect(json['id'], equals('perf-123'));
        expect(json['operation'], equals('fetchData'));
        expect(json['feature'], equals('books'));
        expect(json['start_time'], equals('2024-01-01T12:00:00.000'));
        expect(json['end_time'], equals('2024-01-01T12:00:01.500'));
        expect(json['duration_ms'], equals(1500.0));
        expect(json['metadata'], equals({'source': 'cache', 'items': 10}));
        expect(json['success'], isTrue);
      });

      test('should omit null feature and metadata', () {
        final model = PerformanceMetricModel(
          id: 'test',
          operation: 'test',
          startTime: '2024-01-01T12:00:00.000',
          endTime: '2024-01-01T12:00:01.000',
          durationMs: 1000.0,
          success: true,
        );

        final json = model.toJson();

        expect(json.containsKey('feature'), isFalse);
        expect(json.containsKey('metadata'), isFalse);
        expect(json.containsKey('id'), isTrue);
        expect(json.containsKey('success'), isTrue);
      });
    });

    group('toEntity', () {
      test('should convert model to entity with all fields', () {
        final model = PerformanceMetricModel.fromJson(testJson);
        final entity = model.toEntity();

        expect(entity.id, equals('perf-123'));
        expect(entity.operation, equals('fetchData'));
        expect(entity.feature, equals('books'));
        expect(entity.startTime, equals(DateTime.parse('2024-01-01T12:00:00.000')));
        expect(entity.endTime, equals(DateTime.parse('2024-01-01T12:00:01.500')));
        expect(entity.durationMs, equals(1500.0));
        expect(entity.metadata, equals({'source': 'cache', 'items': 10}));
        expect(entity.success, isTrue);
      });

      test('should handle minimal fields', () {
        final model = PerformanceMetricModel(
          id: 'min-id',
          operation: 'test',
          startTime: '2024-01-01T12:00:00.000',
          endTime: '2024-01-01T12:00:01.000',
          durationMs: 1000.0,
          success: false,
        );

        final entity = model.toEntity();

        expect(entity.id, equals('min-id'));
        expect(entity.feature, isNull);
        expect(entity.metadata, isNull);
        expect(entity.success, isFalse);
      });
    });

    group('round-trip conversions', () {
      test('should maintain data through entity -> model -> entity', () {
        final model = PerformanceMetricModel.fromEntity(testEntity);
        final entity = model.toEntity();

        expect(entity.id, equals(testEntity.id));
        expect(entity.operation, equals(testEntity.operation));
        expect(entity.feature, equals(testEntity.feature));
        expect(entity.startTime, equals(testEntity.startTime));
        expect(entity.endTime, equals(testEntity.endTime));
        expect(entity.durationMs, equals(testEntity.durationMs));
        expect(entity.metadata, equals(testEntity.metadata));
        expect(entity.success, equals(testEntity.success));
      });

      test('should maintain data through json -> model -> json', () {
        final model = PerformanceMetricModel.fromJson(testJson);
        final json = model.toJson();

        expect(json['id'], equals(testJson['id']));
        expect(json['operation'], equals(testJson['operation']));
        expect(json['feature'], equals(testJson['feature']));
        expect(json['start_time'], equals(testJson['start_time']));
        expect(json['end_time'], equals(testJson['end_time']));
        expect(json['duration_ms'], equals(testJson['duration_ms']));
        expect(json['metadata'], equals(testJson['metadata']));
        expect(json['success'], equals(testJson['success']));
      });
    });

    group('performance scenarios', () {
      test('should handle fast operations', () {
        final fastEntity = PerformanceMetric(
          id: 'fast',
          operation: 'cache-hit',
          startTime: startTime,
          endTime: startTime.add(const Duration(milliseconds: 10)),
          durationMs: 10.0,
          success: true,
        );

        final model = PerformanceMetricModel.fromEntity(fastEntity);
        expect(model.durationMs, equals(10.0));
      });

      test('should handle slow operations', () {
        final slowEntity = PerformanceMetric(
          id: 'slow',
          operation: 'network-request',
          startTime: startTime,
          endTime: startTime.add(const Duration(seconds: 30)),
          durationMs: 30000.0,
          success: true,
        );

        final model = PerformanceMetricModel.fromEntity(slowEntity);
        expect(model.durationMs, equals(30000.0));
      });

      test('should handle operation with rich metadata', () {
        final entity = PerformanceMetric(
          id: 'meta',
          operation: 'api-call',
          feature: 'search',
          startTime: startTime,
          endTime: endTime,
          durationMs: 1500.0,
          metadata: {
            'endpoint': '/api/search',
            'query': 'flutter',
            'results': 42,
            'cached': false,
            'timestamp': '2024-01-01T12:00:00Z',
          },
          success: true,
        );

        final model = PerformanceMetricModel.fromEntity(entity);
        final json = model.toJson();
        final entityAgain = model.toEntity();

        expect(entityAgain.metadata?['endpoint'], equals('/api/search'));
        expect(entityAgain.metadata?['results'], equals(42));
        expect(json['metadata']['cached'], equals(false));
      });
    });
  });
}
