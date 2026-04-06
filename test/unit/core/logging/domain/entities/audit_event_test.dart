import 'package:flutter_library/core/logging/domain/entities/audit_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuditEvent', () {
    final timestamp = DateTime(2025, 10, 31, 10, 30, 0);

    test('should create instance with required fields', () {
      final event = AuditEvent(
        id: '123',
        timestamp: timestamp,
        feature: 'books',
        action: 'search',
      );

      expect(event.id, '123');
      expect(event.timestamp, timestamp);
      expect(event.userId, null);
      expect(event.sessionId, null);
      expect(event.feature, 'books');
      expect(event.action, 'search');
      expect(event.parameters, null);
      expect(event.success, true);
    });

    test('should create instance with all fields', () {
      final event = AuditEvent(
        id: '123',
        timestamp: timestamp,
        userId: 'user123',
        sessionId: 'session456',
        feature: 'cart',
        action: 'checkout',
        parameters: {'total': 99.99, 'items': 3},
        success: false,
      );

      expect(event.id, '123');
      expect(event.timestamp, timestamp);
      expect(event.userId, 'user123');
      expect(event.sessionId, 'session456');
      expect(event.feature, 'cart');
      expect(event.action, 'checkout');
      expect(event.parameters, {'total': 99.99, 'items': 3});
      expect(event.success, false);
    });

    test('should support equality', () {
      final event1 = AuditEvent(
        id: '123',
        timestamp: timestamp,
        feature: 'books',
        action: 'search',
      );

      final event2 = AuditEvent(
        id: '123',
        timestamp: timestamp,
        feature: 'books',
        action: 'search',
      );

      final event3 = AuditEvent(
        id: '456',
        timestamp: timestamp,
        feature: 'books',
        action: 'search',
      );

      expect(event1, equals(event2));
      expect(event1, isNot(equals(event3)));
    });
  });
}
