import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/notifications/domain/entities/notification_data.dart';

void main() {
  group('CartNotificationData Tests', () {
    test('should create CartNotificationData with required fields', () {
      const data = CartNotificationData(
        requestId: 'req123',
        bookId: 'book456',
        bookTitle: 'Test Book',
        bookAuthor: 'Test Author',
        bookImageUrl: 'https://example.com/book.jpg',
        requestType: 'rent',
      );

      expect(data.requestId, 'req123');
      expect(data.bookId, 'book456');
      expect(data.bookTitle, 'Test Book');
      expect(data.bookAuthor, 'Test Author');
      expect(data.bookImageUrl, 'https://example.com/book.jpg');
      expect(data.requestType, 'rent');
      expect(data.actionUserId, isNull);
      expect(data.actionUserName, isNull);
      expect(data.rentalPeriodInDays, isNull);
    });

    test('should create CartNotificationData with optional fields', () {
      const data = CartNotificationData(
        requestId: 'req123',
        bookId: 'book456',
        bookTitle: 'Test Book',
        bookAuthor: 'Test Author',
        bookImageUrl: 'https://example.com/book.jpg',
        requestType: 'purchase',
        actionUserId: 'user789',
        actionUserName: 'John Doe',
        rentalPeriodInDays: 14,
      );

      expect(data.actionUserId, 'user789');
      expect(data.actionUserName, 'John Doe');
      expect(data.rentalPeriodInDays, 14);
      expect(data.requestType, 'purchase');
    });

    test('should support equality comparison', () {
      const data1 = CartNotificationData(
        requestId: 'req123',
        bookId: 'book456',
        bookTitle: 'Test Book',
        bookAuthor: 'Test Author',
        bookImageUrl: 'https://example.com/book.jpg',
        requestType: 'rent',
      );

      const data2 = CartNotificationData(
        requestId: 'req123',
        bookId: 'book456',
        bookTitle: 'Test Book',
        bookAuthor: 'Test Author',
        bookImageUrl: 'https://example.com/book.jpg',
        requestType: 'rent',
      );

      expect(data1, equals(data2));
    });

    test('should have different hashCodes for different data', () {
      const data1 = CartNotificationData(
        requestId: 'req123',
        bookId: 'book456',
        bookTitle: 'Test Book',
        bookAuthor: 'Test Author',
        bookImageUrl: 'https://example.com/book.jpg',
        requestType: 'rent',
      );

      const data2 = CartNotificationData(
        requestId: 'req999',
        bookId: 'book456',
        bookTitle: 'Test Book',
        bookAuthor: 'Test Author',
        bookImageUrl: 'https://example.com/book.jpg',
        requestType: 'rent',
      );

      expect(data1.hashCode, isNot(equals(data2.hashCode)));
    });

    test('should support props for equatable', () {
      const data = CartNotificationData(
        requestId: 'req123',
        bookId: 'book456',
        bookTitle: 'Test Book',
        bookAuthor: 'Test Author',
        bookImageUrl: 'https://example.com/book.jpg',
        requestType: 'rent',
        actionUserId: 'user789',
        actionUserName: 'John Doe',
        rentalPeriodInDays: 14,
      );

      expect(data.props, [
        'req123',
        'book456',
        'Test Book',
        'Test Author',
        'https://example.com/book.jpg',
        'rent',
        'user789',
        'John Doe',
        14,
      ]);
    });

    test('should handle rent request type', () {
      const data = CartNotificationData(
        requestId: 'req123',
        bookId: 'book456',
        bookTitle: 'Test Book',
        bookAuthor: 'Test Author',
        bookImageUrl: 'https://example.com/book.jpg',
        requestType: 'rent',
        rentalPeriodInDays: 7,
      );

      expect(data.requestType, 'rent');
      expect(data.rentalPeriodInDays, 7);
    });

    test('should handle purchase request type', () {
      const data = CartNotificationData(
        requestId: 'req123',
        bookId: 'book456',
        bookTitle: 'Test Book',
        bookAuthor: 'Test Author',
        bookImageUrl: 'https://example.com/book.jpg',
        requestType: 'purchase',
      );

      expect(data.requestType, 'purchase');
      expect(data.rentalPeriodInDays, isNull);
    });
  });
}
