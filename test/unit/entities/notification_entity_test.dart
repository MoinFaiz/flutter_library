import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/notifications/domain/entities/notification.dart';
import 'package:flutter_library/features/notifications/domain/entities/notification_data.dart';

void main() {
  group('AppNotification Entity Tests', () {
    final mockNotification = AppNotification(
      id: 'notif_1',
      title: 'New Book Available',
      message: 'A new book "The Great Adventure" is now available for rent.',
      timestamp: DateTime(2023, 6, 1, 10, 30),
      type: NotificationType.newBook,
      isRead: false,
    );

    group('Constructor and Properties', () {
      test('should create AppNotification with all required properties', () {
        expect(mockNotification.id, 'notif_1');
        expect(mockNotification.title, 'New Book Available');
        expect(mockNotification.message, 'A new book "The Great Adventure" is now available for rent.');
        expect(mockNotification.timestamp, DateTime(2023, 6, 1, 10, 30));
        expect(mockNotification.type, NotificationType.newBook);
        expect(mockNotification.isRead, false);
        expect(mockNotification.data, isNull);
      });

      test('should create AppNotification with cart notification types', () {
        final cartRequestSent = AppNotification(
          id: 'cart_1',
          title: 'Request Sent',
          message: 'Your cart request has been sent',
          timestamp: DateTime(2023, 6, 1, 10, 30),
          type: NotificationType.cartRequestSent,
          isRead: false,
        );

        final cartRequestReceived = AppNotification(
          id: 'cart_2',
          title: 'New Request',
          message: 'You have received a cart request',
          timestamp: DateTime(2023, 6, 1, 10, 30),
          type: NotificationType.cartRequestReceived,
          isRead: false,
        );

        final cartRequestAccepted = AppNotification(
          id: 'cart_3',
          title: 'Request Accepted',
          message: 'Your cart request has been accepted',
          timestamp: DateTime(2023, 6, 1, 10, 30),
          type: NotificationType.cartRequestAccepted,
          isRead: false,
        );

        final cartRequestRejected = AppNotification(
          id: 'cart_4',
          title: 'Request Rejected',
          message: 'Your cart request has been rejected',
          timestamp: DateTime(2023, 6, 1, 10, 30),
          type: NotificationType.cartRequestRejected,
          isRead: false,
        );

        expect(cartRequestSent.type, NotificationType.cartRequestSent);
        expect(cartRequestReceived.type, NotificationType.cartRequestReceived);
        expect(cartRequestAccepted.type, NotificationType.cartRequestAccepted);
        expect(cartRequestRejected.type, NotificationType.cartRequestRejected);
      });

      test('should create AppNotification with notification data', () {
        final bookRequestData = BookRequestData(
          bookId: 'book_123',
          bookTitle: 'Test Book',
          requesterId: 'user_456',
          requesterName: 'John Doe',
          requesterEmail: 'john@example.com',
          requestType: 'rent',
          offerPrice: 15.99,
          requestMessage: 'I would like to rent this book.',
        );

        final notificationWithData = AppNotification(
          id: 'notif_2',
          title: 'Book Request',
          message: 'John Doe wants to rent your book.',
          timestamp: DateTime(2023, 6, 2, 14, 15),
          type: NotificationType.bookRequest,
          isRead: true,
          data: bookRequestData,
        );

        expect(notificationWithData.data, bookRequestData);
        expect(notificationWithData.isRead, true);
      });
    });

    group('copyWith Method', () {
      test('should create new instance with updated properties', () {
        final updatedNotification = mockNotification.copyWith(
          title: 'Updated Title',
          isRead: true,
          type: NotificationType.reminder,
        );

        expect(updatedNotification.title, 'Updated Title');
        expect(updatedNotification.isRead, true);
        expect(updatedNotification.type, NotificationType.reminder);
        // Other properties should remain unchanged
        expect(updatedNotification.id, mockNotification.id);
        expect(updatedNotification.message, mockNotification.message);
        expect(updatedNotification.timestamp, mockNotification.timestamp);
      });

      test('should return identical instance when no parameters provided', () {
        final copiedNotification = mockNotification.copyWith();
        
        expect(copiedNotification.id, mockNotification.id);
        expect(copiedNotification.title, mockNotification.title);
        expect(copiedNotification.isRead, mockNotification.isRead);
        expect(copiedNotification.type, mockNotification.type);
      });
    });

    group('Equatable Implementation', () {
      test('should be equal when all properties are identical', () {
        final notification1 = AppNotification(
          id: 'notif_1',
          title: 'Test Title',
          message: 'Test message',
          timestamp: DateTime(2023, 1, 1),
          type: NotificationType.information,
          isRead: false,
        );

        final notification2 = AppNotification(
          id: 'notif_1',
          title: 'Test Title',
          message: 'Test message',
          timestamp: DateTime(2023, 1, 1),
          type: NotificationType.information,
          isRead: false,
        );

        expect(notification1, equals(notification2));
        expect(notification1.hashCode, equals(notification2.hashCode));
      });

      test('should not be equal when properties differ', () {
        final notification1 = mockNotification;
        final notification2 = mockNotification.copyWith(isRead: true);

        expect(notification1, isNot(equals(notification2)));
        expect(notification1.hashCode, isNot(equals(notification2.hashCode)));
      });
    });
  });

  group('BookRequestNotification Entity Tests', () {
    final bookRequestData = BookRequestData(
      bookId: 'book_789',
      bookTitle: 'Adventure Novel',
      requesterId: 'user_123',
      requesterName: 'Jane Smith',
      requesterEmail: 'jane.smith@example.com',
      requestType: 'buy',
      pickupDate: DateTime(2023, 6, 10),
      pickupLocation: 'Central Library',
      offerPrice: 25.99,
      requestMessage: 'Would love to purchase this book.',
      status: 'pending',
    );

    final bookRequestNotification = BookRequestNotification(
      id: 'book_req_1',
      title: 'Book Purchase Request',
      message: 'Jane Smith wants to buy your book "Adventure Novel".',
      timestamp: DateTime(2023, 6, 5, 16, 45),
      type: NotificationType.bookRequest,
      isRead: false,
      bookRequestData: bookRequestData,
    );

    group('Constructor and Properties', () {
      test('should create BookRequestNotification with book data', () {
        expect(bookRequestNotification.id, 'book_req_1');
        expect(bookRequestNotification.title, 'Book Purchase Request');
        expect(bookRequestNotification.type, NotificationType.bookRequest);
        expect(bookRequestNotification.bookData, bookRequestData);
        expect(bookRequestNotification.data, bookRequestData);
      });

      test('should create BookRequestNotification without book data', () {
        final simpleBookRequest = BookRequestNotification(
          id: 'book_req_2',
          title: 'Simple Request',
          message: 'Simple message',
          timestamp: DateTime(2023, 6, 6),
          type: NotificationType.bookRequest,
        );

        expect(simpleBookRequest.bookData, isNull);
        expect(simpleBookRequest.data, isNull);
      });
    });

    group('Typed Data Access', () {
      test('bookData should return correctly typed BookRequestData', () {
        final data = bookRequestNotification.bookData;
        expect(data, isA<BookRequestData>());
        expect(data?.bookId, 'book_789');
        expect(data?.requesterName, 'Jane Smith');
        expect(data?.requestType, 'buy');
        expect(data?.offerPrice, 25.99);
      });

      test('bookData should return null when no data present', () {
        final notificationWithoutData = BookRequestNotification(
          id: 'empty_req',
          title: 'Empty Request',
          message: 'No data',
          timestamp: DateTime(2023, 6, 7),
          type: NotificationType.bookRequest,
        );

        expect(notificationWithoutData.bookData, isNull);
      });
    });

    group('copyWith Method', () {
      test('should create new instance with updated properties', () {
        final updatedNotification = bookRequestNotification.copyWith(
          title: 'Updated Book Request',
          isRead: true,
        );

        expect(updatedNotification.title, 'Updated Book Request');
        expect(updatedNotification.isRead, true);
        expect(updatedNotification.bookData, bookRequestData);
        // Other properties should remain unchanged
        expect(updatedNotification.id, bookRequestNotification.id);
        expect(updatedNotification.type, bookRequestNotification.type);
      });

      test('should allow updating book request data', () {
        final newBookData = BookRequestData(
          bookId: 'book_999',
          bookTitle: 'New Book',
          requesterId: 'user_999',
          requesterName: 'New User',
          requesterEmail: 'new@example.com',
          requestType: 'rent',
        );

        final updatedNotification = bookRequestNotification.copyWith(
          data: newBookData,
        );

        expect(updatedNotification.bookData, newBookData);
        expect(updatedNotification.bookData?.bookId, 'book_999');
        expect(updatedNotification.bookData?.requesterName, 'New User');
      });
    });
  });

  group('NotificationData Entity Tests', () {
    final bookRequestData = BookRequestData(
      bookId: 'book_456',
      bookTitle: 'Science Fiction Novel',
      requesterId: 'user_789',
      requesterName: 'Bob Wilson',
      requesterEmail: 'bob.wilson@example.com',
      requestType: 'borrow',
      pickupDate: DateTime(2023, 6, 15),
      pickupLocation: 'University Library',
      requestMessage: 'Need this for research project.',
      status: 'accepted',
    );

    group('BookRequestData Properties', () {
      test('should create BookRequestData with all properties', () {
        expect(bookRequestData.bookId, 'book_456');
        expect(bookRequestData.bookTitle, 'Science Fiction Novel');
        expect(bookRequestData.requesterId, 'user_789');
        expect(bookRequestData.requesterName, 'Bob Wilson');
        expect(bookRequestData.requesterEmail, 'bob.wilson@example.com');
        expect(bookRequestData.requestType, 'borrow');
        expect(bookRequestData.pickupDate, DateTime(2023, 6, 15));
        expect(bookRequestData.pickupLocation, 'University Library');
        expect(bookRequestData.requestMessage, 'Need this for research project.');
        expect(bookRequestData.status, 'accepted');
      });

      test('should create BookRequestData with minimal properties', () {
        final minimalData = BookRequestData(
          bookId: 'book_minimal',
          bookTitle: 'Minimal Book',
          requesterId: 'user_minimal',
          requesterName: 'Minimal User',
          requesterEmail: 'minimal@example.com',
          requestType: 'rent',
        );

        expect(minimalData.bookId, 'book_minimal');
        expect(minimalData.status, 'pending'); // Default value
        expect(minimalData.pickupDate, isNull);
        expect(minimalData.pickupLocation, isNull);
        expect(minimalData.offerPrice, isNull);
        expect(minimalData.requestMessage, isNull);
      });
    });

    group('Equatable Implementation', () {
      test('should be equal when all properties are identical', () {
        final data1 = BookRequestData(
          bookId: 'book_1',
          bookTitle: 'Test Book',
          requesterId: 'user_1',
          requesterName: 'Test User',
          requesterEmail: 'test@example.com',
          requestType: 'rent',
          offerPrice: 10.99,
          status: 'pending',
        );

        final data2 = BookRequestData(
          bookId: 'book_1',
          bookTitle: 'Test Book',
          requesterId: 'user_1',
          requesterName: 'Test User',
          requesterEmail: 'test@example.com',
          requestType: 'rent',
          offerPrice: 10.99,
          status: 'pending',
        );

        expect(data1, equals(data2));
        expect(data1.hashCode, equals(data2.hashCode));
      });

      test('should not be equal when properties differ', () {
        final data1 = bookRequestData;
        final data2 = BookRequestData(
          bookId: bookRequestData.bookId,
          bookTitle: bookRequestData.bookTitle,
          requesterId: bookRequestData.requesterId,
          requesterName: bookRequestData.requesterName,
          requesterEmail: bookRequestData.requesterEmail,
          requestType: bookRequestData.requestType,
          status: 'rejected', // Different status
        );

        expect(data1, isNot(equals(data2)));
        expect(data1.hashCode, isNot(equals(data2.hashCode)));
      });
    });
  });

  group('Notification Enums Tests', () {
    group('NotificationType Enum', () {
      test('should have all expected notification types', () {
        expect(NotificationType.values, containsAll([
          NotificationType.information,
          NotificationType.reminder,
          NotificationType.bookRequest,
          NotificationType.bookReturned,
          NotificationType.newBook,
          NotificationType.overdue,
          NotificationType.systemUpdate,
          NotificationType.cartRequestSent,
          NotificationType.cartRequestReceived,
          NotificationType.cartRequestAccepted,
          NotificationType.cartRequestRejected,
        ]));
        expect(NotificationType.values.length, 11);
      });
    });

    group('RequestType Enum', () {
      test('should have all expected request types', () {
        expect(RequestType.values, containsAll([
          RequestType.rent,
          RequestType.buy,
          RequestType.borrow,
        ]));
        expect(RequestType.values.length, 3);
      });
    });

    group('RequestStatus Enum', () {
      test('should have all expected request statuses', () {
        expect(RequestStatus.values, containsAll([
          RequestStatus.pending,
          RequestStatus.accepted,
          RequestStatus.rejected,
          RequestStatus.completed,
          RequestStatus.cancelled,
        ]));
        expect(RequestStatus.values.length, 5);
      });
    });
  });
}
