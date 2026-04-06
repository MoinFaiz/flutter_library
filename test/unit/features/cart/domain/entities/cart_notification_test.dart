import 'package:flutter_library/features/cart/domain/entities/cart_item.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_notification.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationType', () {
    test('should have correct number of types', () {
      expect(NotificationType.values.length, 4);
    });

    test('should contain all required types', () {
      expect(NotificationType.values, contains(NotificationType.requestSent));
      expect(NotificationType.values, contains(NotificationType.requestReceived));
      expect(NotificationType.values, contains(NotificationType.requestAccepted));
      expect(NotificationType.values, contains(NotificationType.requestRejected));
    });
  });

  group('CartNotification', () {
    final now = DateTime(2025, 10, 31, 12, 0);
    
    final testNotification = CartNotification(
      id: '1',
      requestId: 'req1',
      bookId: 'book1',
      bookTitle: 'Test Book',
      bookAuthor: 'Test Author',
      bookImageUrl: 'https://example.com/image.jpg',
      type: NotificationType.requestReceived,
      requestType: CartItemType.rent,
      message: 'You have a new rental request',
      isRead: false,
      createdAt: now,
      actionUserId: 'user1',
      actionUserName: 'John Doe',
    );

    test('should create instance with required and optional parameters', () {
      expect(testNotification.id, '1');
      expect(testNotification.requestId, 'req1');
      expect(testNotification.bookId, 'book1');
      expect(testNotification.bookTitle, 'Test Book');
      expect(testNotification.bookAuthor, 'Test Author');
      expect(testNotification.bookImageUrl, 'https://example.com/image.jpg');
      expect(testNotification.type, NotificationType.requestReceived);
      expect(testNotification.requestType, CartItemType.rent);
      expect(testNotification.message, 'You have a new rental request');
      expect(testNotification.isRead, false);
      expect(testNotification.createdAt, now);
      expect(testNotification.actionUserId, 'user1');
      expect(testNotification.actionUserName, 'John Doe');
    });

    test('should create instance without optional parameters', () {
      final notification = CartNotification(
        id: '1',
        requestId: 'req1',
        bookId: 'book1',
        bookTitle: 'Test Book',
        bookAuthor: 'Test Author',
        bookImageUrl: 'https://example.com/image.jpg',
        type: NotificationType.requestSent,
        requestType: CartItemType.purchase,
        message: 'Request sent',
        isRead: true,
        createdAt: now,
      );

      expect(notification.actionUserId, null);
      expect(notification.actionUserName, null);
    });

    test('isRequestSent should return true for requestSent type', () {
      final notification = testNotification.copyWith(type: NotificationType.requestSent);
      expect(notification.isRequestSent, true);
      expect(notification.isRequestReceived, false);
      expect(notification.isRequestAccepted, false);
      expect(notification.isRequestRejected, false);
    });

    test('isRequestReceived should return true for requestReceived type', () {
      expect(testNotification.isRequestReceived, true);
      expect(testNotification.isRequestSent, false);
      expect(testNotification.isRequestAccepted, false);
      expect(testNotification.isRequestRejected, false);
    });

    test('isRequestAccepted should return true for requestAccepted type', () {
      final notification = testNotification.copyWith(type: NotificationType.requestAccepted);
      expect(notification.isRequestAccepted, true);
      expect(notification.isRequestSent, false);
      expect(notification.isRequestReceived, false);
      expect(notification.isRequestRejected, false);
    });

    test('isRequestRejected should return true for requestRejected type', () {
      final notification = testNotification.copyWith(type: NotificationType.requestRejected);
      expect(notification.isRequestRejected, true);
      expect(notification.isRequestSent, false);
      expect(notification.isRequestReceived, false);
      expect(notification.isRequestAccepted, false);
    });

    test('requiresAction should return true only for requestReceived type', () {
      expect(testNotification.requiresAction, true);
      
      final sentNotification = testNotification.copyWith(type: NotificationType.requestSent);
      expect(sentNotification.requiresAction, false);
      
      final acceptedNotification = testNotification.copyWith(type: NotificationType.requestAccepted);
      expect(acceptedNotification.requiresAction, false);
      
      final rejectedNotification = testNotification.copyWith(type: NotificationType.requestRejected);
      expect(rejectedNotification.requiresAction, false);
    });

    test('copyWith should create new instance with updated values', () {
      final updated = testNotification.copyWith(
        id: '2',
        bookTitle: 'Updated Book',
        isRead: true,
        type: NotificationType.requestAccepted,
      );

      expect(updated.id, '2');
      expect(updated.bookTitle, 'Updated Book');
      expect(updated.isRead, true);
      expect(updated.type, NotificationType.requestAccepted);
      // Other values should remain unchanged
      expect(updated.requestId, 'req1');
      expect(updated.bookAuthor, 'Test Author');
    });

    test('copyWith should preserve original values when parameters are null', () {
      final updated = testNotification.copyWith();
      expect(updated, testNotification);
    });

    test('copyWith should update optional nullable fields', () {
      final notification = testNotification.copyWith(
        actionUserId: 'newUser',
        actionUserName: 'Jane Doe',
      );

      expect(notification.actionUserId, 'newUser');
      expect(notification.actionUserName, 'Jane Doe');
    });

    test('should support value equality', () {
      final notification1 = CartNotification(
        id: '1',
        requestId: 'req1',
        bookId: 'book1',
        bookTitle: 'Test Book',
        bookAuthor: 'Test Author',
        bookImageUrl: 'https://example.com/image.jpg',
        type: NotificationType.requestReceived,
        requestType: CartItemType.rent,
        message: 'Test message',
        isRead: false,
        createdAt: now,
      );

      final notification2 = CartNotification(
        id: '1',
        requestId: 'req1',
        bookId: 'book1',
        bookTitle: 'Test Book',
        bookAuthor: 'Test Author',
        bookImageUrl: 'https://example.com/image.jpg',
        type: NotificationType.requestReceived,
        requestType: CartItemType.rent,
        message: 'Test message',
        isRead: false,
        createdAt: now,
      );

      expect(notification1, notification2);
    });

    test('should not be equal if any property differs', () {
      final notification1 = testNotification;
      final notification2 = testNotification.copyWith(id: '2');

      expect(notification1, isNot(notification2));
    });

    test('should include all properties in props', () {
      expect(testNotification.props.length, 13);
      expect(testNotification.props, contains('1'));
      expect(testNotification.props, contains('req1'));
      expect(testNotification.props, contains('book1'));
      expect(testNotification.props, contains('Test Book'));
      expect(testNotification.props, contains('Test Author'));
      expect(testNotification.props, contains(NotificationType.requestReceived));
      expect(testNotification.props, contains(CartItemType.rent));
      expect(testNotification.props, contains(false));
      expect(testNotification.props, contains(now));
    });

    test('should handle different request types', () {
      final rentalNotification = testNotification.copyWith(requestType: CartItemType.rent);
      expect(rentalNotification.requestType, CartItemType.rent);

      final purchaseNotification = testNotification.copyWith(requestType: CartItemType.purchase);
      expect(purchaseNotification.requestType, CartItemType.purchase);
    });

    test('should handle empty strings', () {
      final notification = CartNotification(
        id: '',
        requestId: '',
        bookId: '',
        bookTitle: '',
        bookAuthor: '',
        bookImageUrl: '',
        type: NotificationType.requestSent,
        requestType: CartItemType.rent,
        message: '',
        isRead: false,
        createdAt: now,
      );

      expect(notification.id, '');
      expect(notification.bookTitle, '');
      expect(notification.message, '');
    });

    test('should handle special characters in strings', () {
      final notification = CartNotification(
        id: '1',
        requestId: 'req-1',
        bookId: 'book_1',
        bookTitle: 'Test @ Book #1',
        bookAuthor: 'O\'Brien',
        bookImageUrl: 'https://example.com/image?size=large&format=jpg',
        type: NotificationType.requestReceived,
        requestType: CartItemType.rent,
        message: 'User "John" sent a request!',
        isRead: false,
        createdAt: now,
      );

      expect(notification.bookTitle, 'Test @ Book #1');
      expect(notification.bookAuthor, 'O\'Brien');
      expect(notification.message, 'User "John" sent a request!');
    });
  });
}
