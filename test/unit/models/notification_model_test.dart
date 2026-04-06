import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/notifications/data/models/notification_model.dart';
import 'package:flutter_library/features/notifications/domain/entities/notification.dart';
import 'package:flutter_library/features/notifications/domain/entities/notification_data.dart';

void main() {
  group('NotificationModel Tests', () {
    final testDateTime = DateTime(2023, 6, 1, 12, 0, 0);
    
    final testNotificationModel = NotificationModel(
      id: 'test-notification-id',
      title: 'Test Notification Title',
      message: 'Test notification message content',
      timestamp: testDateTime,
      type: NotificationType.information,
      isRead: false,
      data: null,
    );

    group('Model Inheritance', () {
      test('should be a subclass of AppNotification entity', () {
        expect(testNotificationModel, isA<AppNotification>());
      });

      test('should have correct properties from parent entity', () {
        expect(testNotificationModel.id, equals('test-notification-id'));
        expect(testNotificationModel.title, equals('Test Notification Title'));
        expect(testNotificationModel.message, equals('Test notification message content'));
        expect(testNotificationModel.timestamp, equals(testDateTime));
        expect(testNotificationModel.type, equals(NotificationType.information));
        expect(testNotificationModel.isRead, isFalse);
        expect(testNotificationModel.data, isNull);
      });
    });

    group('fromJson', () {
      test('should return a valid NotificationModel from complete JSON', () {
        // Arrange
        final json = {
          'id': 'json-notification-id',
          'title': 'JSON Notification Title',
          'message': 'JSON notification message',
          'timestamp': '2023-06-01T12:00:00.000Z',
          'type': 'information',
          'isRead': true,
          'data': null,
        };

        // Act
        final result = NotificationModel.fromJson(json);

        // Assert
        expect(result.id, equals('json-notification-id'));
        expect(result.title, equals('JSON Notification Title'));
        expect(result.message, equals('JSON notification message'));
        expect(result.timestamp, equals(DateTime.parse('2023-06-01T12:00:00.000Z')));
        expect(result.type, equals(NotificationType.information));
        expect(result.isRead, isTrue);
        expect(result.data, isNull);
      });

      test('should handle minimal JSON with defaults', () {
        // Arrange
        final json = {
          'id': 'minimal-notification-id',
          'title': 'Minimal Notification',
          'message': 'Minimal message',
          'timestamp': '2023-06-01T12:00:00.000Z',
          'type': 'information',
        };

        // Act
        final result = NotificationModel.fromJson(json);

        // Assert
        expect(result.id, equals('minimal-notification-id'));
        expect(result.title, equals('Minimal Notification'));
        expect(result.message, equals('Minimal message'));
        expect(result.type, equals(NotificationType.information));
        expect(result.isRead, isFalse); // Default value
        expect(result.data, isNull);
      });

      test('should handle all notification types', () {
        for (final notificationType in NotificationType.values) {
          // Arrange
          final json = {
            'id': 'type-test-notification',
            'title': 'Type Test Notification',
            'message': 'Testing ${notificationType.name}',
            'timestamp': '2023-06-01T12:00:00.000Z',
            'type': notificationType.name,
          };

          // Act
          final result = NotificationModel.fromJson(json);

          // Assert
          expect(result.type, equals(notificationType));
        }
      });

      test('should default to information type for unknown type', () {
        // Arrange
        final json = {
          'id': 'unknown-type-notification',
          'title': 'Unknown Type Notification',
          'message': 'Unknown type message',
          'timestamp': '2023-06-01T12:00:00.000Z',
          'type': 'unknown_type',
        };

        // Act
        final result = NotificationModel.fromJson(json);

        // Assert
        expect(result.type, equals(NotificationType.information));
      });

      test('should handle invalid timestamp gracefully', () {
        // Arrange
        final json = {
          'id': 'invalid-timestamp-notification',
          'title': 'Invalid Timestamp Notification',
          'message': 'Invalid timestamp message',
          'timestamp': 'invalid-timestamp',
          'type': 'information',
        };

        // Act & Assert
        expect(() => NotificationModel.fromJson(json), throwsFormatException);
      });
    });

    group('toJson', () {
      test('should return a valid JSON map', () {
        // Act
        final result = testNotificationModel.toJson();

        // Assert
        expect(result['id'], equals('test-notification-id'));
        expect(result['title'], equals('Test Notification Title'));
        expect(result['message'], equals('Test notification message content'));
        expect(result['timestamp'], equals(testDateTime.toIso8601String()));
        expect(result['type'], equals('information'));
        expect(result['isRead'], isFalse);
        expect(result['data'], isNull);
      });

      test('should handle notification with data', () {
        // Arrange
        final notificationWithData = NotificationModel(
          id: 'data-notification',
          title: 'Data Notification',
          message: 'Notification with data',
          timestamp: testDateTime,
          type: NotificationType.bookRequest,
          isRead: true,
          data: BookRequestData(
            bookId: 'book-123',
            bookTitle: 'Test Book',
            requesterId: 'user-123',
            requesterName: 'Test User',
            requesterEmail: 'test@example.com',
            requestType: 'borrow',
          ),
        );

        // Act
        final result = notificationWithData.toJson();

        // Assert
        expect(result['id'], equals('data-notification'));
        expect(result['type'], equals('bookRequest'));
        expect(result['isRead'], isTrue);
        expect(result['data'], isNotNull);
        expect(result['data'], isA<Map<String, dynamic>>());
      });
    });

    group('copyWith', () {
      test('should return NotificationModel with updated values', () {
        // Arrange
        final newDateTime = DateTime(2023, 7, 1, 15, 30, 0);

        // Act
        final result = testNotificationModel.copyWith(
          id: 'updated-id',
          title: 'Updated Title',
          message: 'Updated message',
          timestamp: newDateTime,
          type: NotificationType.bookRequest,
          isRead: true,
        );

        // Assert
        expect(result.id, equals('updated-id'));
        expect(result.title, equals('Updated Title'));
        expect(result.message, equals('Updated message'));
        expect(result.timestamp, equals(newDateTime));
        expect(result.type, equals(NotificationType.bookRequest));
        expect(result.isRead, isTrue);
        expect(result.data, isNull); // Original data preserved
      });

      test('should return NotificationModel with original values when no parameters provided', () {
        // Act
        final result = testNotificationModel.copyWith();

        // Assert
        expect(result.id, equals(testNotificationModel.id));
        expect(result.title, equals(testNotificationModel.title));
        expect(result.message, equals(testNotificationModel.message));
        expect(result.timestamp, equals(testNotificationModel.timestamp));
        expect(result.type, equals(testNotificationModel.type));
        expect(result.isRead, equals(testNotificationModel.isRead));
        expect(result.data, equals(testNotificationModel.data));
      });

      test('should update data correctly', () {
        // Arrange
        final newData = BookRequestData(
          bookId: 'new-book-123',
          bookTitle: 'New Test Book',
          requesterId: 'new-user-123',
          requesterName: 'New Test User',
          requesterEmail: 'newtest@example.com',
          requestType: 'purchase',
        );

        // Act
        final result = testNotificationModel.copyWith(data: newData);

        // Assert
        expect(result.data, equals(newData));
        expect(result.id, equals(testNotificationModel.id)); // Other fields unchanged
      });
    });

    group('JSON Serialization Round Trip', () {
      test('should maintain data integrity through JSON round trip', () {
        // Act
        final json = testNotificationModel.toJson();
        final reconstructed = NotificationModel.fromJson(json);

        // Assert
        expect(reconstructed.id, equals(testNotificationModel.id));
        expect(reconstructed.title, equals(testNotificationModel.title));
        expect(reconstructed.message, equals(testNotificationModel.message));
        expect(reconstructed.timestamp, equals(testNotificationModel.timestamp));
        expect(reconstructed.type, equals(testNotificationModel.type));
        expect(reconstructed.isRead, equals(testNotificationModel.isRead));
        expect(reconstructed.data, equals(testNotificationModel.data));
      });
    });

    group('Edge Cases', () {
      test('should handle empty strings', () {
        // Arrange
        final json = {
          'id': '',
          'title': '',
          'message': '',
          'timestamp': '2023-06-01T12:00:00.000Z',
          'type': 'information',
        };

        // Act
        final result = NotificationModel.fromJson(json);

        // Assert
        expect(result.id, isEmpty);
        expect(result.title, isEmpty);
        expect(result.message, isEmpty);
      });

      test('should handle special characters in strings', () {
        // Arrange
        final json = {
          'id': 'special-chars-notification',
          'title': 'Title with éññôñs & symbols!@#\$%^&*()',
          'message': 'Message with unicode: 你好世界 🔔 📱',
          'timestamp': '2023-06-01T12:00:00.000Z',
          'type': 'information',
        };

        // Act
        final result = NotificationModel.fromJson(json);

        // Assert
        expect(result.title, equals('Title with éññôñs & symbols!@#\$%^&*()'));
        expect(result.message, equals('Message with unicode: 你好世界 🔔 📱'));
      });
    });
  });

  group('BookRequestNotificationModel Tests', () {
    final testDateTime = DateTime(2023, 6, 1, 12, 0, 0);
    final testBookRequestData = BookRequestData(
      bookId: 'book-123',
      bookTitle: 'Test Book Title',
      requesterId: 'user-456',
      requesterName: 'John Doe',
      requesterEmail: 'john.doe@example.com',
      requestType: 'borrow',
    );
    
    final testBookRequestNotificationModel = BookRequestNotificationModel(
      id: 'book-request-notification-id',
      title: 'Book Request Notification',
      message: 'John Doe wants to borrow "Test Book Title"',
      timestamp: testDateTime,
      type: NotificationType.bookRequest,
      isRead: false,
      bookRequestData: testBookRequestData,
    );

    group('Model Inheritance', () {
      test('should be a subclass of NotificationModel', () {
        expect(testBookRequestNotificationModel, isA<NotificationModel>());
      });

      test('should implement BookRequestNotification', () {
        expect(testBookRequestNotificationModel, isA<BookRequestNotification>());
      });

      test('should have correct bookData property', () {
        expect(testBookRequestNotificationModel.bookData, equals(testBookRequestData));
        expect(testBookRequestNotificationModel.bookData?.bookId, equals('book-123'));
        expect(testBookRequestNotificationModel.bookData?.bookTitle, equals('Test Book Title'));
        expect(testBookRequestNotificationModel.bookData?.requesterId, equals('user-456'));
        expect(testBookRequestNotificationModel.bookData?.requesterName, equals('John Doe'));
      });
    });

    group('fromJson', () {
      test('should return a valid BookRequestNotificationModel from complete JSON', () {
        // Arrange
        final json = {
          'id': 'json-book-request-id',
          'title': 'JSON Book Request',
          'message': 'JSON book request message',
          'timestamp': '2023-06-01T12:00:00.000Z',
          'type': 'bookRequest',
          'isRead': true,
          'data': {
            'bookId': 'json-book-123',
            'bookTitle': 'JSON Book Title',
            'requesterId': 'json-user-456',
            'requesterName': 'Jane Doe',
            'requesterEmail': 'jane.doe@example.com',
            'requestType': 'borrow',
          },
        };

        // Act
        final result = BookRequestNotificationModel.fromJson(json);

        // Assert
        expect(result.id, equals('json-book-request-id'));
        expect(result.title, equals('JSON Book Request'));
        expect(result.message, equals('JSON book request message'));
        expect(result.type, equals(NotificationType.bookRequest));
        expect(result.isRead, isTrue);
        expect(result.bookData?.bookId, equals('json-book-123'));
        expect(result.bookData?.bookTitle, equals('JSON Book Title'));
        expect(result.bookData?.requesterId, equals('json-user-456'));
        expect(result.bookData?.requesterName, equals('Jane Doe'));
      });

      test('should handle JSON without book data', () {
        // Arrange
        final json = {
          'id': 'no-data-book-request',
          'title': 'No Data Book Request',
          'message': 'No data message',
          'timestamp': '2023-06-01T12:00:00.000Z',
          'type': 'bookRequest',
          'data': null,
        };

        // Act
        final result = BookRequestNotificationModel.fromJson(json);

        // Assert
        expect(result.bookData, isNull);
        expect(result.type, equals(NotificationType.bookRequest));
      });

      test('should default to bookRequest type for unknown type', () {
        // Arrange
        final json = {
          'id': 'unknown-type-book-request',
          'title': 'Unknown Type Book Request',
          'message': 'Unknown type message',
          'timestamp': '2023-06-01T12:00:00.000Z',
          'type': 'unknown_type',
        };

        // Act
        final result = BookRequestNotificationModel.fromJson(json);

        // Assert
        expect(result.type, equals(NotificationType.bookRequest));
      });
    });

    group('toJson', () {
      test('should return a valid JSON map with book request data', () {
        // Act
        final result = testBookRequestNotificationModel.toJson();

        // Assert
        expect(result['id'], equals('book-request-notification-id'));
        expect(result['title'], equals('Book Request Notification'));
        expect(result['message'], equals('John Doe wants to borrow "Test Book Title"'));
        expect(result['timestamp'], equals(testDateTime.toIso8601String()));
        expect(result['type'], equals('bookRequest'));
        expect(result['isRead'], isFalse);
        expect(result['data'], isNotNull);
        expect(result['data'], isA<Map<String, dynamic>>());
        
        final data = result['data'] as Map<String, dynamic>;
        expect(data['bookId'], equals('book-123'));
        expect(data['bookTitle'], equals('Test Book Title'));
        expect(data['requesterId'], equals('user-456'));
        expect(data['requesterName'], equals('John Doe'));
      });
    });

    group('copyWith', () {
      test('should return BookRequestNotificationModel with updated values', () {
        // Arrange
        final newDateTime = DateTime(2023, 7, 1, 15, 30, 0);
        final newBookRequestData = BookRequestData(
          bookId: 'new-book-789',
          bookTitle: 'New Book Title',
          requesterId: 'new-user-789',
          requesterName: 'New User',
          requesterEmail: 'newuser@example.com',
          requestType: 'purchase',
        );

        // Act
        final result = testBookRequestNotificationModel.copyWith(
          id: 'updated-book-request-id',
          title: 'Updated Book Request',
          timestamp: newDateTime,
          isRead: true,
          data: newBookRequestData,
        );

        // Assert
        expect(result.id, equals('updated-book-request-id'));
        expect(result.title, equals('Updated Book Request'));
        expect(result.timestamp, equals(newDateTime));
        expect(result.isRead, isTrue);
        expect(result.bookData, equals(newBookRequestData));
        expect(result.bookData?.bookId, equals('new-book-789'));
      });

      test('should preserve original book data when data not provided in copyWith', () {
        // Act
        final result = testBookRequestNotificationModel.copyWith(
          title: 'Updated Title Only',
        );

        // Assert
        expect(result.title, equals('Updated Title Only'));
        expect(result.bookData, equals(testBookRequestData));
        expect(result.bookData?.bookId, equals('book-123'));
      });
    });

    group('JSON Serialization Round Trip', () {
      test('should maintain data integrity through JSON round trip', () {
        // Act
        final json = testBookRequestNotificationModel.toJson();
        final reconstructed = BookRequestNotificationModel.fromJson(json);

        // Assert
        expect(reconstructed.id, equals(testBookRequestNotificationModel.id));
        expect(reconstructed.title, equals(testBookRequestNotificationModel.title));
        expect(reconstructed.message, equals(testBookRequestNotificationModel.message));
        expect(reconstructed.timestamp, equals(testBookRequestNotificationModel.timestamp));
        expect(reconstructed.type, equals(testBookRequestNotificationModel.type));
        expect(reconstructed.isRead, equals(testBookRequestNotificationModel.isRead));
        expect(reconstructed.bookData?.bookId, equals(testBookRequestNotificationModel.bookData?.bookId));
        expect(reconstructed.bookData?.bookTitle, equals(testBookRequestNotificationModel.bookData?.bookTitle));
        expect(reconstructed.bookData?.requesterId, equals(testBookRequestNotificationModel.bookData?.requesterId));
        expect(reconstructed.bookData?.requesterName, equals(testBookRequestNotificationModel.bookData?.requesterName));
      });
    });
  });
}
