import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/notifications/domain/entities/notification_data.dart';

void main() {
  group('NotificationData Tests', () {
    group('BookRequestData', () {
      test('should create BookRequestData with required fields', () {
        final bookRequestData = BookRequestData(
          bookId: 'book_1',
          bookTitle: 'Test Book',
          requesterId: 'user_1',
          requesterName: 'John Doe',
          requesterEmail: 'john@example.com',
          requestType: 'rent',
        );

        expect(bookRequestData.bookId, equals('book_1'));
        expect(bookRequestData.bookTitle, equals('Test Book'));
        expect(bookRequestData.requesterId, equals('user_1'));
        expect(bookRequestData.requesterName, equals('John Doe'));
        expect(bookRequestData.requesterEmail, equals('john@example.com'));
        expect(bookRequestData.requestType, equals('rent'));
        expect(bookRequestData.status, equals('pending')); // default value
        expect(bookRequestData.pickupDate, isNull);
        expect(bookRequestData.pickupLocation, isNull);
        expect(bookRequestData.offerPrice, isNull);
        expect(bookRequestData.requestMessage, isNull);
      });

      test('should create BookRequestData with all fields', () {
        final pickupDate = DateTime(2023, 12, 25);
        final bookRequestData = BookRequestData(
          bookId: 'book_1',
          bookTitle: 'Test Book',
          requesterId: 'user_1',
          requesterName: 'John Doe',
          requesterEmail: 'john@example.com',
          requestType: 'buy',
          pickupDate: pickupDate,
          pickupLocation: 'Library Main Branch',
          offerPrice: 25.99,
          requestMessage: 'Urgent request',
          status: 'accepted',
        );

        expect(bookRequestData.bookId, equals('book_1'));
        expect(bookRequestData.bookTitle, equals('Test Book'));
        expect(bookRequestData.requesterId, equals('user_1'));
        expect(bookRequestData.requesterName, equals('John Doe'));
        expect(bookRequestData.requesterEmail, equals('john@example.com'));
        expect(bookRequestData.requestType, equals('buy'));
        expect(bookRequestData.pickupDate, equals(pickupDate));
        expect(bookRequestData.pickupLocation, equals('Library Main Branch'));
        expect(bookRequestData.offerPrice, equals(25.99));
        expect(bookRequestData.requestMessage, equals('Urgent request'));
        expect(bookRequestData.status, equals('accepted'));
      });

      test('should support value equality', () {
        final pickupDate = DateTime(2023, 12, 25);
        
        final bookRequestData1 = BookRequestData(
          bookId: 'book_1',
          bookTitle: 'Test Book',
          requesterId: 'user_1',
          requesterName: 'John Doe',
          requesterEmail: 'john@example.com',
          requestType: 'rent',
          pickupDate: pickupDate,
          offerPrice: 25.99,
        );

        final bookRequestData2 = BookRequestData(
          bookId: 'book_1',
          bookTitle: 'Test Book',
          requesterId: 'user_1',
          requesterName: 'John Doe',
          requesterEmail: 'john@example.com',
          requestType: 'rent',
          pickupDate: pickupDate,
          offerPrice: 25.99,
        );

        expect(bookRequestData1, equals(bookRequestData2));
      });

      test('should not be equal when properties differ', () {
        final bookRequestData1 = BookRequestData(
          bookId: 'book_1',
          bookTitle: 'Test Book',
          requesterId: 'user_1',
          requesterName: 'John Doe',
          requesterEmail: 'john@example.com',
          requestType: 'rent',
        );

        final bookRequestData2 = BookRequestData(
          bookId: 'book_2', // Different book ID
          bookTitle: 'Test Book',
          requesterId: 'user_1',
          requesterName: 'John Doe',
          requesterEmail: 'john@example.com',
          requestType: 'rent',
        );

        expect(bookRequestData1, isNot(equals(bookRequestData2)));
      });

      test('should have correct props', () {
        final pickupDate = DateTime(2023, 12, 25);
        final bookRequestData = BookRequestData(
          bookId: 'book_1',
          bookTitle: 'Test Book',
          requesterId: 'user_1',
          requesterName: 'John Doe',
          requesterEmail: 'john@example.com',
          requestType: 'rent',
          pickupDate: pickupDate,
          pickupLocation: 'Library',
          offerPrice: 25.99,
          requestMessage: 'Message',
          status: 'pending',
        );

        expect(bookRequestData.props, equals([
          'book_1',
          'Test Book',
          'user_1',
          'John Doe',
          'john@example.com',
          'rent',
          pickupDate,
          'Library',
          25.99,
          'Message',
          'pending',
        ]));
      });
    });

    group('BookReminderData', () {
      test('should create BookReminderData correctly', () {
        final dueDate = DateTime(2023, 12, 31);
        final reminderData = BookReminderData(
          bookId: 'book_1',
          bookTitle: 'Test Book',
          dueDate: dueDate,
        );

        expect(reminderData.bookId, equals('book_1'));
        expect(reminderData.bookTitle, equals('Test Book'));
        expect(reminderData.dueDate, equals(dueDate));
      });

      test('should support value equality', () {
        final dueDate = DateTime(2023, 12, 31);
        
        final reminderData1 = BookReminderData(
          bookId: 'book_1',
          bookTitle: 'Test Book',
          dueDate: dueDate,
        );

        final reminderData2 = BookReminderData(
          bookId: 'book_1',
          bookTitle: 'Test Book',
          dueDate: dueDate,
        );

        expect(reminderData1, equals(reminderData2));
      });

      test('should not be equal when properties differ', () {
        final dueDate1 = DateTime(2023, 12, 31);
        final dueDate2 = DateTime(2024, 1, 1);
        
        final reminderData1 = BookReminderData(
          bookId: 'book_1',
          bookTitle: 'Test Book',
          dueDate: dueDate1,
        );

        final reminderData2 = BookReminderData(
          bookId: 'book_1',
          bookTitle: 'Test Book',
          dueDate: dueDate2,
        );

        expect(reminderData1, isNot(equals(reminderData2)));
      });

      test('should have correct props', () {
        final dueDate = DateTime(2023, 12, 31);
        final reminderData = BookReminderData(
          bookId: 'book_1',
          bookTitle: 'Test Book',
          dueDate: dueDate,
        );

        expect(reminderData.props, equals(['book_1', 'Test Book', dueDate]));
      });
    });

    group('SystemNotificationData', () {
      test('should create SystemNotificationData correctly', () {
        const systemData = SystemNotificationData();
        
        expect(systemData, isA<NotificationData>());
        expect(systemData.props, isEmpty);
      });

      test('should support value equality', () {
        const systemData1 = SystemNotificationData();
        const systemData2 = SystemNotificationData();

        expect(systemData1, equals(systemData2));
      });

      test('should have empty props', () {
        const systemData = SystemNotificationData();
        expect(systemData.props, isEmpty);
      });
    });

    group('BookStatusData', () {
      test('should create BookStatusData correctly', () {
        const statusData = BookStatusData(
          bookId: 'book_1',
          bookTitle: 'Test Book',
          status: 'returned',
        );

        expect(statusData.bookId, equals('book_1'));
        expect(statusData.bookTitle, equals('Test Book'));
        expect(statusData.status, equals('returned'));
      });

      test('should support value equality', () {
        const statusData1 = BookStatusData(
          bookId: 'book_1',
          bookTitle: 'Test Book',
          status: 'overdue',
        );

        const statusData2 = BookStatusData(
          bookId: 'book_1',
          bookTitle: 'Test Book',
          status: 'overdue',
        );

        expect(statusData1, equals(statusData2));
      });

      test('should not be equal when properties differ', () {
        const statusData1 = BookStatusData(
          bookId: 'book_1',
          bookTitle: 'Test Book',
          status: 'returned',
        );

        const statusData2 = BookStatusData(
          bookId: 'book_1',
          bookTitle: 'Test Book',
          status: 'overdue',
        );

        expect(statusData1, isNot(equals(statusData2)));
      });

      test('should have correct props', () {
        const statusData = BookStatusData(
          bookId: 'book_1',
          bookTitle: 'Test Book',
          status: 'returned',
        );

        expect(statusData.props, equals(['book_1', 'Test Book', 'returned']));
      });

      test('should handle different status values', () {
        const statuses = ['returned', 'overdue', 'renewed', 'cancelled'];
        
        for (final status in statuses) {
          final statusData = BookStatusData(
            bookId: 'book_1',
            bookTitle: 'Test Book',
            status: status,
          );
          
          expect(statusData.status, equals(status));
        }
      });
    });

    group('Edge Cases', () {
      test('should handle empty strings', () {
        const bookRequestData = BookRequestData(
          bookId: '',
          bookTitle: '',
          requesterId: '',
          requesterName: '',
          requesterEmail: '',
          requestType: '',
        );

        expect(bookRequestData.bookId, equals(''));
        expect(bookRequestData.bookTitle, equals(''));
        expect(bookRequestData.requesterId, equals(''));
        expect(bookRequestData.requesterName, equals(''));
        expect(bookRequestData.requesterEmail, equals(''));
        expect(bookRequestData.requestType, equals(''));
      });

      test('should handle very long strings', () {
        final longString = 'a' * 1000;
        final bookRequestData = BookRequestData(
          bookId: longString,
          bookTitle: longString,
          requesterId: longString,
          requesterName: longString,
          requesterEmail: longString,
          requestType: longString,
        );

        expect(bookRequestData.bookId, equals(longString));
        expect(bookRequestData.bookTitle, equals(longString));
      });

      test('should handle special characters', () {
        const specialChars = 'àáâãäåæçèéêëìíîïñòóôõöùúûüýÿ@#\$%^&*()';
        const bookRequestData = BookRequestData(
          bookId: specialChars,
          bookTitle: specialChars,
          requesterId: specialChars,
          requesterName: specialChars,
          requesterEmail: specialChars,
          requestType: specialChars,
        );

        expect(bookRequestData.bookId, equals(specialChars));
        expect(bookRequestData.bookTitle, equals(specialChars));
      });

      test('should handle extreme dates', () {
        final extremeDate = DateTime(2100, 12, 31);
        final reminderData = BookReminderData(
          bookId: 'book_1',
          bookTitle: 'Test Book',
          dueDate: extremeDate,
        );

        expect(reminderData.dueDate, equals(extremeDate));
      });

      test('should handle zero and negative prices', () {
        const zeroPrice = BookRequestData(
          bookId: 'book_1',
          bookTitle: 'Test Book',
          requesterId: 'user_1',
          requesterName: 'John Doe',
          requesterEmail: 'john@example.com',
          requestType: 'buy',
          offerPrice: 0.0,
        );

        const negativePrice = BookRequestData(
          bookId: 'book_1',
          bookTitle: 'Test Book',
          requesterId: 'user_1',
          requesterName: 'John Doe',
          requesterEmail: 'john@example.com',
          requestType: 'buy',
          offerPrice: -10.5,
        );

        expect(zeroPrice.offerPrice, equals(0.0));
        expect(negativePrice.offerPrice, equals(-10.5));
      });
    });
  });
}
