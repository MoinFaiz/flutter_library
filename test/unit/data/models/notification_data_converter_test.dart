import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/notifications/data/models/notification_data_converter.dart';
import 'package:flutter_library/features/notifications/domain/entities/notification.dart';
import 'package:flutter_library/features/notifications/domain/entities/notification_data.dart';

void main() {
  group('NotificationDataConverter Tests', () {
    group('fromJson', () {
      group('BookRequest Type', () {
        test('should convert complete JSON to BookRequestData', () {
          final json = {
            'bookId': 'book_1',
            'bookTitle': 'Test Book',
            'requesterId': 'user_1',
            'requesterName': 'John Doe',
            'requesterEmail': 'john@example.com',
            'requestType': 'rent',
            'pickupDate': '2023-12-25T10:00:00.000Z',
            'pickupLocation': 'Library Main Branch',
            'offerPrice': 25.99,
            'requestMessage': 'Urgent request',
            'status': 'pending',
          };

          final result = NotificationDataConverter.fromJson(json, NotificationType.bookRequest);

          expect(result, isA<BookRequestData>());
          final bookRequestData = result as BookRequestData;
          expect(bookRequestData.bookId, equals('book_1'));
          expect(bookRequestData.bookTitle, equals('Test Book'));
          expect(bookRequestData.requesterId, equals('user_1'));
          expect(bookRequestData.requesterName, equals('John Doe'));
          expect(bookRequestData.requesterEmail, equals('john@example.com'));
          expect(bookRequestData.requestType, equals('rent'));
          expect(bookRequestData.pickupDate, equals(DateTime.parse('2023-12-25T10:00:00.000Z')));
          expect(bookRequestData.pickupLocation, equals('Library Main Branch'));
          expect(bookRequestData.offerPrice, equals(25.99));
          expect(bookRequestData.requestMessage, equals('Urgent request'));
          expect(bookRequestData.status, equals('pending'));
        });

        test('should convert minimal JSON to BookRequestData with defaults', () {
          final json = {
            'bookId': 'book_1',
            'bookTitle': 'Test Book',
            'requesterId': 'user_1',
            'requesterName': 'John Doe',
            'requesterEmail': 'john@example.com',
            'requestType': 'buy',
          };

          final result = NotificationDataConverter.fromJson(json, NotificationType.bookRequest);

          expect(result, isA<BookRequestData>());
          final bookRequestData = result as BookRequestData;
          expect(bookRequestData.bookId, equals('book_1'));
          expect(bookRequestData.bookTitle, equals('Test Book'));
          expect(bookRequestData.requesterId, equals('user_1'));
          expect(bookRequestData.requesterName, equals('John Doe'));
          expect(bookRequestData.requesterEmail, equals('john@example.com'));
          expect(bookRequestData.requestType, equals('buy'));
          expect(bookRequestData.pickupDate, isNull);
          expect(bookRequestData.pickupLocation, isNull);
          expect(bookRequestData.offerPrice, isNull);
          expect(bookRequestData.requestMessage, isNull);
          expect(bookRequestData.status, equals('pending')); // default
        });

        test('should handle null pickupDate gracefully', () {
          final json = {
            'bookId': 'book_1',
            'bookTitle': 'Test Book',
            'requesterId': 'user_1',
            'requesterName': 'John Doe',
            'requesterEmail': 'john@example.com',
            'requestType': 'rent',
            'pickupDate': null,
          };

          final result = NotificationDataConverter.fromJson(json, NotificationType.bookRequest);

          expect(result, isA<BookRequestData>());
          final bookRequestData = result as BookRequestData;
          expect(bookRequestData.pickupDate, isNull);
        });

        test('should handle integer offerPrice', () {
          final json = {
            'bookId': 'book_1',
            'bookTitle': 'Test Book',
            'requesterId': 'user_1',
            'requesterName': 'John Doe',
            'requesterEmail': 'john@example.com',
            'requestType': 'buy',
            'offerPrice': 25, // integer instead of double
          };

          final result = NotificationDataConverter.fromJson(json, NotificationType.bookRequest);

          expect(result, isA<BookRequestData>());
          final bookRequestData = result as BookRequestData;
          expect(bookRequestData.offerPrice, equals(25.0));
        });
      });

      group('Reminder Type', () {
        test('should convert JSON to BookReminderData', () {
          final json = {
            'bookId': 'book_1',
            'bookTitle': 'Test Book',
            'dueDate': '2023-12-31T23:59:59.000Z',
          };

          final result = NotificationDataConverter.fromJson(json, NotificationType.reminder);

          expect(result, isA<BookReminderData>());
          final reminderData = result as BookReminderData;
          expect(reminderData.bookId, equals('book_1'));
          expect(reminderData.bookTitle, equals('Test Book'));
          expect(reminderData.dueDate, equals(DateTime.parse('2023-12-31T23:59:59.000Z')));
        });
      });

      group('BookReturned Type', () {
        test('should convert JSON to BookStatusData', () {
          final json = {
            'bookId': 'book_1',
            'bookTitle': 'Test Book',
            'status': 'returned',
          };

          final result = NotificationDataConverter.fromJson(json, NotificationType.bookReturned);

          expect(result, isA<BookStatusData>());
          final statusData = result as BookStatusData;
          expect(statusData.bookId, equals('book_1'));
          expect(statusData.bookTitle, equals('Test Book'));
          expect(statusData.status, equals('returned'));
        });
      });

      group('Overdue Type', () {
        test('should convert JSON to BookStatusData', () {
          final json = {
            'bookId': 'book_1',
            'bookTitle': 'Test Book',
            'status': 'overdue',
          };

          final result = NotificationDataConverter.fromJson(json, NotificationType.overdue);

          expect(result, isA<BookStatusData>());
          final statusData = result as BookStatusData;
          expect(statusData.bookId, equals('book_1'));
          expect(statusData.bookTitle, equals('Test Book'));
          expect(statusData.status, equals('overdue'));
        });
      });

      group('Default/System Type', () {
        test('should return SystemNotificationData for unknown types', () {
          final json = {'someKey': 'someValue'};

          final result = NotificationDataConverter.fromJson(json, NotificationType.systemUpdate);

          expect(result, isA<SystemNotificationData>());
        });
      });

      group('Error Cases', () {
        test('should return null for null JSON', () {
          final result = NotificationDataConverter.fromJson(null, NotificationType.bookRequest);
          expect(result, isNull);
        });

        test('should handle empty JSON gracefully for bookRequest', () {
          expect(
            () => NotificationDataConverter.fromJson({}, NotificationType.bookRequest),
            throwsA(isA<TypeError>()),
          );
        });

        test('should handle malformed date strings', () {
          final json = {
            'bookId': 'book_1',
            'bookTitle': 'Test Book',
            'dueDate': 'invalid-date',
          };

          expect(
            () => NotificationDataConverter.fromJson(json, NotificationType.reminder),
            throwsA(isA<FormatException>()),
          );
        });
      });
    });

    group('toJson', () {
      group('BookRequestData', () {
        test('should convert complete BookRequestData to JSON', () {
          final pickupDate = DateTime.parse('2023-12-25T10:00:00.000Z');
          final bookRequestData = BookRequestData(
            bookId: 'book_1',
            bookTitle: 'Test Book',
            requesterId: 'user_1',
            requesterName: 'John Doe',
            requesterEmail: 'john@example.com',
            requestType: 'rent',
            pickupDate: pickupDate,
            pickupLocation: 'Library Main Branch',
            offerPrice: 25.99,
            requestMessage: 'Urgent request',
            status: 'pending',
          );

          final result = NotificationDataConverter.toJson(bookRequestData);

          expect(result, isNotNull);
          expect(result!['bookId'], equals('book_1'));
          expect(result['bookTitle'], equals('Test Book'));
          expect(result['requesterId'], equals('user_1'));
          expect(result['requesterName'], equals('John Doe'));
          expect(result['requesterEmail'], equals('john@example.com'));
          expect(result['requestType'], equals('rent'));
          expect(result['pickupDate'], equals('2023-12-25T10:00:00.000Z'));
          expect(result['pickupLocation'], equals('Library Main Branch'));
          expect(result['offerPrice'], equals(25.99));
          expect(result['requestMessage'], equals('Urgent request'));
          expect(result['status'], equals('pending'));
        });

        test('should convert minimal BookRequestData to JSON', () {
          const bookRequestData = BookRequestData(
            bookId: 'book_1',
            bookTitle: 'Test Book',
            requesterId: 'user_1',
            requesterName: 'John Doe',
            requesterEmail: 'john@example.com',
            requestType: 'buy',
          );

          final result = NotificationDataConverter.toJson(bookRequestData);

          expect(result, isNotNull);
          expect(result!['bookId'], equals('book_1'));
          expect(result['bookTitle'], equals('Test Book'));
          expect(result['requesterId'], equals('user_1'));
          expect(result['requesterName'], equals('John Doe'));
          expect(result['requesterEmail'], equals('john@example.com'));
          expect(result['requestType'], equals('buy'));
          expect(result['pickupDate'], isNull);
          expect(result['pickupLocation'], isNull);
          expect(result['offerPrice'], isNull);
          expect(result['requestMessage'], isNull);
          expect(result['status'], equals('pending'));
        });
      });

      group('BookReminderData', () {
        test('should convert BookReminderData to JSON', () {
          final dueDate = DateTime.parse('2023-12-31T23:59:59.000Z');
          final reminderData = BookReminderData(
            bookId: 'book_1',
            bookTitle: 'Test Book',
            dueDate: dueDate,
          );

          final result = NotificationDataConverter.toJson(reminderData);

          expect(result, isNotNull);
          expect(result!['bookId'], equals('book_1'));
          expect(result['bookTitle'], equals('Test Book'));
          expect(result['dueDate'], equals('2023-12-31T23:59:59.000Z'));
        });
      });

      group('BookStatusData', () {
        test('should convert BookStatusData to JSON', () {
          const statusData = BookStatusData(
            bookId: 'book_1',
            bookTitle: 'Test Book',
            status: 'returned',
          );

          final result = NotificationDataConverter.toJson(statusData);

          expect(result, isNotNull);
          expect(result!['bookId'], equals('book_1'));
          expect(result['bookTitle'], equals('Test Book'));
          expect(result['status'], equals('returned'));
        });
      });

      group('SystemNotificationData', () {
        test('should convert SystemNotificationData to empty JSON', () {
          const systemData = SystemNotificationData();

          final result = NotificationDataConverter.toJson(systemData);

          expect(result, isNotNull);
          expect(result, isEmpty);
        });
      });

      group('Error Cases', () {
        test('should return null for null data', () {
          final result = NotificationDataConverter.toJson(null);
          expect(result, isNull);
        });
      });
    });

    group('Round Trip Conversion', () {
      test('should maintain data integrity for BookRequestData', () {
        final originalData = BookRequestData(
          bookId: 'book_1',
          bookTitle: 'Test Book',
          requesterId: 'user_1',
          requesterName: 'John Doe',
          requesterEmail: 'john@example.com',
          requestType: 'rent',
          pickupDate: DateTime.parse('2023-12-25T10:00:00.000Z'),
          pickupLocation: 'Library',
          offerPrice: 25.99,
          requestMessage: 'Message',
          status: 'pending',
        );

        final json = NotificationDataConverter.toJson(originalData);
        final convertedData = NotificationDataConverter.fromJson(json, NotificationType.bookRequest);

        expect(convertedData, equals(originalData));
      });

      test('should maintain data integrity for BookReminderData', () {
        final originalData = BookReminderData(
          bookId: 'book_1',
          bookTitle: 'Test Book',
          dueDate: DateTime.parse('2023-12-31T23:59:59.000Z'),
        );

        final json = NotificationDataConverter.toJson(originalData);
        final convertedData = NotificationDataConverter.fromJson(json, NotificationType.reminder);

        expect(convertedData, equals(originalData));
      });

      test('should maintain data integrity for BookStatusData', () {
        const originalData = BookStatusData(
          bookId: 'book_1',
          bookTitle: 'Test Book',
          status: 'returned',
        );

        final json = NotificationDataConverter.toJson(originalData);
        final convertedData = NotificationDataConverter.fromJson(json, NotificationType.bookReturned);

        expect(convertedData, equals(originalData));
      });

      test('should maintain data integrity for SystemNotificationData', () {
        const originalData = SystemNotificationData();

        final json = NotificationDataConverter.toJson(originalData);
        final convertedData = NotificationDataConverter.fromJson(json, NotificationType.systemUpdate);

        expect(convertedData, equals(originalData));
      });
    });

    group('Edge Cases', () {
      test('should handle special characters in strings', () {
        const specialTitle = 'Book with àáâãäåæçèéêëìíîïñòóôõöùúûüýÿ & @#\$%^&*()';
        const bookRequestData = BookRequestData(
          bookId: 'book_1',
          bookTitle: specialTitle,
          requesterId: 'user_1',
          requesterName: 'John Doe',
          requesterEmail: 'john@example.com',
          requestType: 'rent',
        );

        final json = NotificationDataConverter.toJson(bookRequestData);
        final convertedData = NotificationDataConverter.fromJson(json, NotificationType.bookRequest);

        expect((convertedData as BookRequestData).bookTitle, equals(specialTitle));
      });

      test('should handle very large numbers', () {
        const bookRequestData = BookRequestData(
          bookId: 'book_1',
          bookTitle: 'Test Book',
          requesterId: 'user_1',
          requesterName: 'John Doe',
          requesterEmail: 'john@example.com',
          requestType: 'buy',
          offerPrice: 999999999.99,
        );

        final json = NotificationDataConverter.toJson(bookRequestData);
        final convertedData = NotificationDataConverter.fromJson(json, NotificationType.bookRequest);

        expect((convertedData as BookRequestData).offerPrice, equals(999999999.99));
      });

      test('should handle zero values', () {
        const bookRequestData = BookRequestData(
          bookId: 'book_1',
          bookTitle: 'Test Book',
          requesterId: 'user_1',
          requesterName: 'John Doe',
          requesterEmail: 'john@example.com',
          requestType: 'buy',
          offerPrice: 0.0,
        );

        final json = NotificationDataConverter.toJson(bookRequestData);
        final convertedData = NotificationDataConverter.fromJson(json, NotificationType.bookRequest);

        expect((convertedData as BookRequestData).offerPrice, equals(0.0));
      });

      test('should handle extreme dates', () {
        final extremeDate = DateTime(2100, 12, 31, 23, 59, 59);
        final reminderData = BookReminderData(
          bookId: 'book_1',
          bookTitle: 'Test Book',
          dueDate: extremeDate,
        );

        final json = NotificationDataConverter.toJson(reminderData);
        final convertedData = NotificationDataConverter.fromJson(json, NotificationType.reminder);

        expect((convertedData as BookReminderData).dueDate, equals(extremeDate));
      });
    });
  });
}
