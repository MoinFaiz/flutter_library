import 'package:flutter_library/core/logging/domain/entities/log_entry.dart';
import 'package:flutter_library/core/logging/domain/entities/log_level.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LogEntry', () {
    final timestamp = DateTime(2025, 10, 31, 10, 30, 0);

    test('should create instance with required fields', () {
      final entry = LogEntry(
        id: '123',
        timestamp: timestamp,
        level: LogLevel.info,
        message: 'Test message',
      );

      expect(entry.id, '123');
      expect(entry.timestamp, timestamp);
      expect(entry.level, LogLevel.info);
      expect(entry.message, 'Test message');
      expect(entry.feature, null);
      expect(entry.action, null);
      expect(entry.metadata, null);
      expect(entry.stackTrace, null);
      expect(entry.userId, null);
      expect(entry.sessionId, null);
      expect(entry.performanceMetric, null);
    });

    test('should create instance with all fields', () {
      final entry = LogEntry(
        id: '123',
        timestamp: timestamp,
        level: LogLevel.error,
        message: 'Error occurred',
        feature: 'books',
        action: 'search',
        metadata: {'query': 'flutter'},
        stackTrace: 'Stack trace here',
        userId: 'user123',
        sessionId: 'session456',
        performanceMetric: 150.5,
      );

      expect(entry.id, '123');
      expect(entry.timestamp, timestamp);
      expect(entry.level, LogLevel.error);
      expect(entry.message, 'Error occurred');
      expect(entry.feature, 'books');
      expect(entry.action, 'search');
      expect(entry.metadata, {'query': 'flutter'});
      expect(entry.stackTrace, 'Stack trace here');
      expect(entry.userId, 'user123');
      expect(entry.sessionId, 'session456');
      expect(entry.performanceMetric, 150.5);
    });

    test('should support equality', () {
      final entry1 = LogEntry(
        id: '123',
        timestamp: timestamp,
        level: LogLevel.info,
        message: 'Test',
      );

      final entry2 = LogEntry(
        id: '123',
        timestamp: timestamp,
        level: LogLevel.info,
        message: 'Test',
      );

      final entry3 = LogEntry(
        id: '456',
        timestamp: timestamp,
        level: LogLevel.info,
        message: 'Test',
      );

      expect(entry1, equals(entry2));
      expect(entry1, isNot(equals(entry3)));
    });

    test('should support copyWith', () {
      final original = LogEntry(
        id: '123',
        timestamp: timestamp,
        level: LogLevel.info,
        message: 'Original',
        feature: 'books',
      );

      final copied = original.copyWith(
        message: 'Updated',
        action: 'search',
      );

      expect(copied.id, '123');
      expect(copied.timestamp, timestamp);
      expect(copied.level, LogLevel.info);
      expect(copied.message, 'Updated');
      expect(copied.feature, 'books');
      expect(copied.action, 'search');
    });

    test('copyWith should preserve original values when not specified', () {
      final original = LogEntry(
        id: '123',
        timestamp: timestamp,
        level: LogLevel.error,
        message: 'Error',
        feature: 'cart',
        userId: 'user123',
      );

      final copied = original.copyWith(message: 'New error');

      expect(copied.id, '123');
      expect(copied.level, LogLevel.error);
      expect(copied.feature, 'cart');
      expect(copied.userId, 'user123');
    });
  });
}
