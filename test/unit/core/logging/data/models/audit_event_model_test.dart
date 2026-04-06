import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/core/logging/data/models/audit_event_model.dart';
import 'package:flutter_library/core/logging/domain/entities/audit_event.dart';

void main() {
  group('AuditEventModel', () {
    final timestamp = DateTime(2024, 1, 1, 12, 0, 0);

    final testEntity = AuditEvent(
      id: 'audit-123',
      timestamp: timestamp,
      userId: 'user-456',
      sessionId: 'session-789',
      feature: 'books',
      action: 'add_to_favorites',
      parameters: {'book_id': '12345', 'book_title': 'Flutter Guide'},
      success: true,
    );

    final testJson = {
      'id': 'audit-123',
      'timestamp': '2024-01-01T12:00:00.000',
      'user_id': 'user-456',
      'session_id': 'session-789',
      'feature': 'books',
      'action': 'add_to_favorites',
      'parameters': {'book_id': '12345', 'book_title': 'Flutter Guide'},
      'success': true,
    };

    group('fromEntity', () {
      test('should create model from entity with all fields', () {
        final model = AuditEventModel.fromEntity(testEntity);

        expect(model.id, equals('audit-123'));
        expect(model.timestamp, equals('2024-01-01T12:00:00.000'));
        expect(model.userId, equals('user-456'));
        expect(model.sessionId, equals('session-789'));
        expect(model.feature, equals('books'));
        expect(model.action, equals('add_to_favorites'));
        expect(model.parameters, equals({'book_id': '12345', 'book_title': 'Flutter Guide'}));
        expect(model.success, isTrue);
      });

      test('should create model from entity with minimal fields', () {
        final minimalEntity = AuditEvent(
          id: 'min-id',
          timestamp: timestamp,
          feature: 'test',
          action: 'test_action',
          success: true,
        );

        final model = AuditEventModel.fromEntity(minimalEntity);

        expect(model.id, equals('min-id'));
        expect(model.feature, equals('test'));
        expect(model.action, equals('test_action'));
        expect(model.userId, isNull);
        expect(model.sessionId, isNull);
        expect(model.parameters, isNull);
        expect(model.success, isTrue);
      });

      test('should handle failed action', () {
        final failedEntity = AuditEvent(
          id: 'fail-id',
          timestamp: timestamp,
          feature: 'payment',
          action: 'process_payment',
          success: false,
        );

        final model = AuditEventModel.fromEntity(failedEntity);
        expect(model.success, isFalse);
      });
    });

    group('fromJson', () {
      test('should create model from json with all fields', () {
        final model = AuditEventModel.fromJson(testJson);

        expect(model.id, equals('audit-123'));
        expect(model.timestamp, equals('2024-01-01T12:00:00.000'));
        expect(model.userId, equals('user-456'));
        expect(model.sessionId, equals('session-789'));
        expect(model.feature, equals('books'));
        expect(model.action, equals('add_to_favorites'));
        expect(model.parameters, equals({'book_id': '12345', 'book_title': 'Flutter Guide'}));
        expect(model.success, isTrue);
      });

      test('should create model from json with minimal fields', () {
        final minimalJson = {
          'id': 'min-id',
          'timestamp': '2024-01-01T12:00:00.000',
          'feature': 'test',
          'action': 'test_action',
        };

        final model = AuditEventModel.fromJson(minimalJson);

        expect(model.id, equals('min-id'));
        expect(model.feature, equals('test'));
        expect(model.action, equals('test_action'));
        expect(model.userId, isNull);
        expect(model.sessionId, isNull);
        expect(model.parameters, isNull);
        expect(model.success, isTrue); // defaults to true
      });

      test('should default success to true when missing', () {
        final json = Map<String, dynamic>.from(testJson)..remove('success');

        final model = AuditEventModel.fromJson(json);
        expect(model.success, isTrue);
      });

      test('should handle explicit success false', () {
        final json = {
          ...testJson,
          'success': false,
        };

        final model = AuditEventModel.fromJson(json);
        expect(model.success, isFalse);
      });
    });

    group('toJson', () {
      test('should convert model to json with all fields', () {
        final model = AuditEventModel.fromEntity(testEntity);
        final json = model.toJson();

        expect(json['id'], equals('audit-123'));
        expect(json['timestamp'], equals('2024-01-01T12:00:00.000'));
        expect(json['user_id'], equals('user-456'));
        expect(json['session_id'], equals('session-789'));
        expect(json['feature'], equals('books'));
        expect(json['action'], equals('add_to_favorites'));
        expect(json['parameters'], equals({'book_id': '12345', 'book_title': 'Flutter Guide'}));
        expect(json['success'], isTrue);
      });

      test('should omit null fields from json', () {
        final model = AuditEventModel(
          id: 'test',
          timestamp: '2024-01-01T12:00:00.000',
          feature: 'test',
          action: 'test_action',
          success: true,
        );

        final json = model.toJson();

        expect(json.containsKey('user_id'), isFalse);
        expect(json.containsKey('session_id'), isFalse);
        expect(json.containsKey('parameters'), isFalse);
        expect(json.containsKey('id'), isTrue);
        expect(json.containsKey('success'), isTrue);
      });
    });

    group('toEntity', () {
      test('should convert model to entity with all fields', () {
        final model = AuditEventModel.fromJson(testJson);
        final entity = model.toEntity();

        expect(entity.id, equals('audit-123'));
        expect(entity.timestamp, equals(DateTime.parse('2024-01-01T12:00:00.000')));
        expect(entity.userId, equals('user-456'));
        expect(entity.sessionId, equals('session-789'));
        expect(entity.feature, equals('books'));
        expect(entity.action, equals('add_to_favorites'));
        expect(entity.parameters, equals({'book_id': '12345', 'book_title': 'Flutter Guide'}));
        expect(entity.success, isTrue);
      });

      test('should handle minimal fields', () {
        final model = AuditEventModel(
          id: 'min-id',
          timestamp: '2024-01-01T12:00:00.000',
          feature: 'test',
          action: 'test_action',
          success: false,
        );

        final entity = model.toEntity();

        expect(entity.id, equals('min-id'));
        expect(entity.userId, isNull);
        expect(entity.sessionId, isNull);
        expect(entity.parameters, isNull);
        expect(entity.success, isFalse);
      });
    });

    group('round-trip conversions', () {
      test('should maintain data through entity -> model -> entity', () {
        final model = AuditEventModel.fromEntity(testEntity);
        final entity = model.toEntity();

        expect(entity.id, equals(testEntity.id));
        expect(entity.timestamp, equals(testEntity.timestamp));
        expect(entity.userId, equals(testEntity.userId));
        expect(entity.sessionId, equals(testEntity.sessionId));
        expect(entity.feature, equals(testEntity.feature));
        expect(entity.action, equals(testEntity.action));
        expect(entity.parameters, equals(testEntity.parameters));
        expect(entity.success, equals(testEntity.success));
      });

      test('should maintain data through json -> model -> json', () {
        final model = AuditEventModel.fromJson(testJson);
        final json = model.toJson();

        expect(json['id'], equals(testJson['id']));
        expect(json['timestamp'], equals(testJson['timestamp']));
        expect(json['user_id'], equals(testJson['user_id']));
        expect(json['session_id'], equals(testJson['session_id']));
        expect(json['feature'], equals(testJson['feature']));
        expect(json['action'], equals(testJson['action']));
        expect(json['parameters'], equals(testJson['parameters']));
        expect(json['success'], equals(testJson['success']));
      });
    });

    group('audit scenarios', () {
      test('should handle user authentication events', () {
        final entity = AuditEvent(
          id: 'auth-1',
          timestamp: timestamp,
          userId: 'user-123',
          sessionId: 'new-session',
          feature: 'authentication',
          action: 'login',
          parameters: {
            'method': 'email',
            'provider': 'local',
          },
          success: true,
        );

        final model = AuditEventModel.fromEntity(entity);
        expect(model.feature, equals('authentication'));
        expect(model.action, equals('login'));
        expect(model.parameters?['method'], equals('email'));
      });

      test('should handle failed operations', () {
        final entity = AuditEvent(
          id: 'fail-1',
          timestamp: timestamp,
          userId: 'user-123',
          feature: 'books',
          action: 'delete',
          parameters: {
            'book_id': '999',
            'error': 'not_found',
          },
          success: false,
        );

        final model = AuditEventModel.fromEntity(entity);
        expect(model.success, isFalse);
        expect(model.parameters?['error'], equals('not_found'));
      });

      test('should handle events without user context', () {
        final entity = AuditEvent(
          id: 'anon-1',
          timestamp: timestamp,
          feature: 'app',
          action: 'startup',
          parameters: {'version': '1.0.0'},
          success: true,
        );

        final model = AuditEventModel.fromEntity(entity);
        expect(model.userId, isNull);
        expect(model.sessionId, isNull);
      });

      test('should handle complex parameters', () {
        final entity = AuditEvent(
          id: 'complex-1',
          timestamp: timestamp,
          userId: 'user-123',
          sessionId: 'session-456',
          feature: 'search',
          action: 'query',
          parameters: {
            'query': 'flutter books',
            'filters': {'category': 'programming', 'price': 'free'},
            'results': 42,
            'page': 1,
            'sort': 'relevance',
          },
          success: true,
        );

        final model = AuditEventModel.fromEntity(entity);
        final json = model.toJson();
        final entityAgain = model.toEntity();

        expect(entityAgain.parameters?['query'], equals('flutter books'));
        expect(entityAgain.parameters?['results'], equals(42));
        expect(json['parameters']['filters']['category'], equals('programming'));
      });

      test('should handle shopping cart events', () {
        final entity = AuditEvent(
          id: 'cart-1',
          timestamp: timestamp,
          userId: 'user-123',
          sessionId: 'session-456',
          feature: 'shopping_cart',
          action: 'add_item',
          parameters: {
            'book_id': '12345',
            'quantity': 1,
            'price': 29.99,
          },
          success: true,
        );

        final model = AuditEventModel.fromEntity(entity);
        expect(model.feature, equals('shopping_cart'));
        expect(model.action, equals('add_item'));
      });
    });
  });
}
