import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/core/logging/data/models/log_entry_model.dart';
import 'package:flutter_library/core/logging/domain/entities/log_entry.dart';
import 'package:flutter_library/core/logging/domain/entities/log_level.dart';

void main() {
  group('LogEntryModel', () {
    final timestamp = DateTime(2024, 1, 1, 12, 0, 0);
    final testEntity = LogEntry(
      id: 'test-id',
      timestamp: timestamp,
      level: LogLevel.error,
      message: 'Test error message',
      feature: 'test-feature',
      action: 'test-action',
      metadata: {'key': 'value'},
      stackTrace: 'Stack trace here',
      userId: 'user-123',
      sessionId: 'session-456',
      performanceMetric: 123.45,
    );

    final testJson = {
      'id': 'test-id',
      'timestamp': '2024-01-01T12:00:00.000',
      'level': 'error',
      'message': 'Test error message',
      'feature': 'test-feature',
      'action': 'test-action',
      'metadata': {'key': 'value'},
      'stack_trace': 'Stack trace here',
      'user_id': 'user-123',
      'session_id': 'session-456',
      'performance_metric': 123.45,
    };

    group('fromEntity', () {
      test('should create model from entity with all fields', () {
        final model = LogEntryModel.fromEntity(testEntity);

        expect(model.id, equals('test-id'));
        expect(model.timestamp, equals('2024-01-01T12:00:00.000'));
        expect(model.level, equals('error'));
        expect(model.message, equals('Test error message'));
        expect(model.feature, equals('test-feature'));
        expect(model.action, equals('test-action'));
        expect(model.metadata, equals({'key': 'value'}));
        expect(model.stackTrace, equals('Stack trace here'));
        expect(model.userId, equals('user-123'));
        expect(model.sessionId, equals('session-456'));
        expect(model.performanceMetric, equals(123.45));
      });

      test('should create model from entity with minimal fields', () {
        final minimalEntity = LogEntry(
          id: 'min-id',
          timestamp: timestamp,
          level: LogLevel.info,
          message: 'Minimal message',
        );

        final model = LogEntryModel.fromEntity(minimalEntity);

        expect(model.id, equals('min-id'));
        expect(model.timestamp, equals('2024-01-01T12:00:00.000'));
        expect(model.level, equals('info'));
        expect(model.message, equals('Minimal message'));
        expect(model.feature, isNull);
        expect(model.action, isNull);
        expect(model.metadata, isNull);
        expect(model.stackTrace, isNull);
        expect(model.userId, isNull);
        expect(model.sessionId, isNull);
        expect(model.performanceMetric, isNull);
      });

      test('should handle all log levels', () {
        for (final level in LogLevel.values) {
          final entity = LogEntry(
            id: 'test',
            timestamp: timestamp,
            level: level,
            message: 'Test',
          );

          final model = LogEntryModel.fromEntity(entity);
          expect(model.level, equals(level.name));
        }
      });
    });

    group('fromJson', () {
      test('should create model from json with all fields', () {
        final model = LogEntryModel.fromJson(testJson);

        expect(model.id, equals('test-id'));
        expect(model.timestamp, equals('2024-01-01T12:00:00.000'));
        expect(model.level, equals('error'));
        expect(model.message, equals('Test error message'));
        expect(model.feature, equals('test-feature'));
        expect(model.action, equals('test-action'));
        expect(model.metadata, equals({'key': 'value'}));
        expect(model.stackTrace, equals('Stack trace here'));
        expect(model.userId, equals('user-123'));
        expect(model.sessionId, equals('session-456'));
        expect(model.performanceMetric, equals(123.45));
      });

      test('should create model from json with minimal fields', () {
        final minimalJson = {
          'id': 'min-id',
          'timestamp': '2024-01-01T12:00:00.000',
          'level': 'info',
          'message': 'Minimal message',
        };

        final model = LogEntryModel.fromJson(minimalJson);

        expect(model.id, equals('min-id'));
        expect(model.message, equals('Minimal message'));
        expect(model.feature, isNull);
        expect(model.stackTrace, isNull);
      });

      test('should handle integer performance metric', () {
        final json = {
          ...testJson,
          'performance_metric': 100, // integer instead of double
        };

        final model = LogEntryModel.fromJson(json);
        expect(model.performanceMetric, equals(100.0));
      });
    });

    group('toJson', () {
      test('should convert model to json with all fields', () {
        final model = LogEntryModel.fromEntity(testEntity);
        final json = model.toJson();

        expect(json['id'], equals('test-id'));
        expect(json['timestamp'], equals('2024-01-01T12:00:00.000'));
        expect(json['level'], equals('error'));
        expect(json['message'], equals('Test error message'));
        expect(json['feature'], equals('test-feature'));
        expect(json['action'], equals('test-action'));
        expect(json['metadata'], equals({'key': 'value'}));
        expect(json['stack_trace'], equals('Stack trace here'));
        expect(json['user_id'], equals('user-123'));
        expect(json['session_id'], equals('session-456'));
        expect(json['performance_metric'], equals(123.45));
      });

      test('should omit null fields from json', () {
        final model = LogEntryModel(
          id: 'test',
          timestamp: '2024-01-01T12:00:00.000',
          level: 'info',
          message: 'Test',
        );

        final json = model.toJson();

        expect(json.containsKey('feature'), isFalse);
        expect(json.containsKey('action'), isFalse);
        expect(json.containsKey('metadata'), isFalse);
        expect(json.containsKey('stack_trace'), isFalse);
        expect(json.containsKey('user_id'), isFalse);
        expect(json.containsKey('session_id'), isFalse);
        expect(json.containsKey('performance_metric'), isFalse);
      });
    });

    group('toEntity', () {
      test('should convert model to entity with all fields', () {
        final model = LogEntryModel.fromJson(testJson);
        final entity = model.toEntity();

        expect(entity.id, equals('test-id'));
        expect(entity.timestamp, equals(DateTime.parse('2024-01-01T12:00:00.000')));
        expect(entity.level, equals(LogLevel.error));
        expect(entity.message, equals('Test error message'));
        expect(entity.feature, equals('test-feature'));
        expect(entity.action, equals('test-action'));
        expect(entity.metadata, equals({'key': 'value'}));
        expect(entity.stackTrace, equals('Stack trace here'));
        expect(entity.userId, equals('user-123'));
        expect(entity.sessionId, equals('session-456'));
        expect(entity.performanceMetric, equals(123.45));
      });

      test('should handle all log levels in string form', () {
        for (final level in LogLevel.values) {
          final model = LogEntryModel(
            id: 'test',
            timestamp: '2024-01-01T12:00:00.000',
            level: level.name,
            message: 'Test',
          );

          final entity = model.toEntity();
          expect(entity.level, equals(level));
        }
      });
    });

    group('round-trip conversions', () {
      test('should maintain data through entity -> model -> entity', () {
        final model = LogEntryModel.fromEntity(testEntity);
        final entity = model.toEntity();

        expect(entity.id, equals(testEntity.id));
        expect(entity.timestamp, equals(testEntity.timestamp));
        expect(entity.level, equals(testEntity.level));
        expect(entity.message, equals(testEntity.message));
        expect(entity.feature, equals(testEntity.feature));
        expect(entity.action, equals(testEntity.action));
        expect(entity.metadata, equals(testEntity.metadata));
        expect(entity.stackTrace, equals(testEntity.stackTrace));
        expect(entity.userId, equals(testEntity.userId));
        expect(entity.sessionId, equals(testEntity.sessionId));
        expect(entity.performanceMetric, equals(testEntity.performanceMetric));
      });

      test('should maintain data through json -> model -> json', () {
        final model = LogEntryModel.fromJson(testJson);
        final json = model.toJson();

        expect(json['id'], equals(testJson['id']));
        expect(json['timestamp'], equals(testJson['timestamp']));
        expect(json['level'], equals(testJson['level']));
        expect(json['message'], equals(testJson['message']));
        expect(json['feature'], equals(testJson['feature']));
        expect(json['action'], equals(testJson['action']));
        expect(json['metadata'], equals(testJson['metadata']));
        expect(json['stack_trace'], equals(testJson['stack_trace']));
        expect(json['user_id'], equals(testJson['user_id']));
        expect(json['session_id'], equals(testJson['session_id']));
        expect(json['performance_metric'], equals(testJson['performance_metric']));
      });
    });
  });
}
