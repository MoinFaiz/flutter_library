import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_library/features/notifications/data/datasources/notifications_local_datasource.dart';
import 'package:flutter_library/features/notifications/data/models/notification_model.dart';
import 'package:flutter_library/features/notifications/domain/entities/notification.dart';
import 'package:flutter_library/features/notifications/domain/entities/notification_data.dart';

void main() {
  group('NotificationsLocalDataSource Tests', () {
    late NotificationsLocalDataSourceImpl dataSource;

    setUpAll(() {
      SharedPreferences.setMockInitialValues({});
    });

    setUp(() async {
      final sharedPreferences = await SharedPreferences.getInstance();
      await sharedPreferences.clear();
      dataSource = NotificationsLocalDataSourceImpl(
        sharedPreferences: sharedPreferences,
      );
    });

    final mockNotification1 = NotificationModel(
      id: 'notification_1',
      title: 'New Book Available',
      message: 'A new book has been added to the library',
      type: NotificationType.newBook,
      isRead: false,
      timestamp: DateTime.now(),
    );

    final mockNotification2 = NotificationModel(
      id: 'notification_2',
      title: 'Book Request Approved',
      message: 'Your book request has been approved',
      type: NotificationType.information,
      isRead: true,
      timestamp: DateTime.now(),
    );

    final mockBookRequestNotification = BookRequestNotificationModel(
      id: 'notification_3',
      title: 'Book Request',
      message: 'Someone wants to borrow your book',
      type: NotificationType.bookRequest,
      isRead: false,
      timestamp: DateTime.now(),
      bookRequestData: BookRequestData(
        bookId: 'book_123',
        bookTitle: 'Test Book',
        requesterId: 'user_123',
        requesterName: 'John Doe',
        requesterEmail: 'john.doe@example.com',
        requestType: 'borrow',
        status: 'pending',
      ),
    );

    group('getCachedNotifications', () {
      test('should return empty list when no notifications are cached', () async {
        // Act
        final result = await dataSource.getCachedNotifications();

        // Assert
        expect(result, isEmpty);
      });

      test('should return cached notifications when they exist', () async {
        // Arrange
        await dataSource.cacheNotifications([mockNotification1, mockNotification2]);

        // Act
        final result = await dataSource.getCachedNotifications();

        // Assert
        expect(result, hasLength(2));
        expect(result[0].id, equals(mockNotification1.id));
        expect(result[1].id, equals(mockNotification2.id));
      });

      test('should return BookRequestNotificationModel for bookRequest type', () async {
        // Arrange
        await dataSource.cacheNotifications([mockBookRequestNotification]);

        // Act
        final result = await dataSource.getCachedNotifications();

        // Assert
        expect(result, hasLength(1));
        expect(result[0], isA<BookRequestNotificationModel>());
        final bookRequestNotification = result[0] as BookRequestNotificationModel;
        expect(bookRequestNotification.bookData?.bookId, equals('book_123'));
        expect(bookRequestNotification.bookData?.bookTitle, equals('Test Book'));
        expect(bookRequestNotification.bookData?.requesterName, equals('John Doe'));
      });

      test('should handle mixed notification types', () async {
        // Arrange
        await dataSource.cacheNotifications([
          mockNotification1,
          mockBookRequestNotification,
          mockNotification2,
        ]);

        // Act
        final result = await dataSource.getCachedNotifications();

        // Assert
        expect(result, hasLength(3));
        expect(result[0], isA<NotificationModel>());
        expect(result[1], isA<BookRequestNotificationModel>());
        expect(result[2], isA<NotificationModel>());
      });
    });

    group('cacheNotifications', () {
      test('should save notifications to cache', () async {
        // Arrange
        final notificationsList = [mockNotification1, mockNotification2];

        // Act
        await dataSource.cacheNotifications(notificationsList);
        final result = await dataSource.getCachedNotifications();

        // Assert
        expect(result, hasLength(2));
        expect(result[0].id, equals(mockNotification1.id));
        expect(result[1].id, equals(mockNotification2.id));
      });

      test('should save empty list to cache', () async {
        // Act
        await dataSource.cacheNotifications([]);
        final result = await dataSource.getCachedNotifications();

        // Assert
        expect(result, isEmpty);
      });

      test('should overwrite existing cache', () async {
        // Arrange
        await dataSource.cacheNotifications([mockNotification1]);
        
        // Act
        await dataSource.cacheNotifications([mockNotification2]);
        final result = await dataSource.getCachedNotifications();

        // Assert
        expect(result, hasLength(1));
        expect(result[0].id, equals(mockNotification2.id));
      });

      test('should handle BookRequestNotificationModel correctly', () async {
        // Act
        await dataSource.cacheNotifications([mockBookRequestNotification]);
        final result = await dataSource.getCachedNotifications();

        // Assert
        expect(result, hasLength(1));
        expect(result[0], isA<BookRequestNotificationModel>());
        final bookRequest = result[0] as BookRequestNotificationModel;
        expect(bookRequest.bookData?.bookId, equals('book_123'));
      });
    });

    group('markAsReadInCache', () {
      test('should mark specific notification as read', () async {
        // Arrange
        await dataSource.cacheNotifications([mockNotification1, mockNotification2]);

        // Act
        await dataSource.markAsReadInCache('notification_1');
        final result = await dataSource.getCachedNotifications();

        // Assert
        expect(result, hasLength(2));
        final notification1 = result.firstWhere((n) => n.id == 'notification_1');
        final notification2 = result.firstWhere((n) => n.id == 'notification_2');
        expect(notification1.isRead, isTrue);
        expect(notification2.isRead, isTrue); // This was already read
      });

      test('should do nothing when notification not found', () async {
        // Arrange
        await dataSource.cacheNotifications([mockNotification1, mockNotification2]);

        // Act
        await dataSource.markAsReadInCache('non_existent_id');
        final result = await dataSource.getCachedNotifications();

        // Assert
        expect(result, hasLength(2));
        expect(result[0].isRead, isFalse);
        expect(result[1].isRead, isTrue);
      });

      test('should handle empty cache', () async {
        // Act & Assert - should not throw
        await expectLater(
          dataSource.markAsReadInCache('notification_1'),
          completes,
        );
        
        final result = await dataSource.getCachedNotifications();
        expect(result, isEmpty);
      });
    });

    group('removeNotificationFromCache', () {
      test('should remove specific notification from cache', () async {
        // Arrange
        await dataSource.cacheNotifications([mockNotification1, mockNotification2]);

        // Act
        await dataSource.removeNotificationFromCache('notification_1');
        final result = await dataSource.getCachedNotifications();

        // Assert
        expect(result, hasLength(1));
        expect(result[0].id, equals('notification_2'));
      });

      test('should do nothing when notification not found', () async {
        // Arrange
        await dataSource.cacheNotifications([mockNotification1, mockNotification2]);

        // Act
        await dataSource.removeNotificationFromCache('non_existent_id');
        final result = await dataSource.getCachedNotifications();

        // Assert
        expect(result, hasLength(2));
      });

      test('should handle empty cache', () async {
        // Act & Assert - should not throw
        await expectLater(
          dataSource.removeNotificationFromCache('notification_1'),
          completes,
        );
        
        final result = await dataSource.getCachedNotifications();
        expect(result, isEmpty);
      });

      test('should remove all notifications with matching ID', () async {
        // Arrange
        final duplicateIdNotification = NotificationModel(
          id: 'notification_1', // Same ID as mockNotification1
          title: 'Duplicate Notification',
          message: 'This has the same ID',
          type: NotificationType.reminder,
          isRead: false,
          timestamp: DateTime.now(),
        );
        
        await dataSource.cacheNotifications([
          mockNotification1,
          mockNotification2,
          duplicateIdNotification,
        ]);

        // Act
        await dataSource.removeNotificationFromCache('notification_1');
        final result = await dataSource.getCachedNotifications();

        // Assert
        expect(result, hasLength(1));
        expect(result[0].id, equals('notification_2'));
      });
    });

    group('clearCache', () {
      test('should remove all cached notifications', () async {
        // Arrange
        await dataSource.cacheNotifications([mockNotification1, mockNotification2]);

        // Act
        await dataSource.clearCache();
        final result = await dataSource.getCachedNotifications();

        // Assert
        expect(result, isEmpty);
      });

      test('should work when cache is already empty', () async {
        // Act & Assert - should not throw
        await expectLater(dataSource.clearCache(), completes);
        
        final result = await dataSource.getCachedNotifications();
        expect(result, isEmpty);
      });
    });

    group('Integration Tests', () {
      test('should handle complete notification lifecycle', () async {
        // 1. Start with empty cache
        var result = await dataSource.getCachedNotifications();
        expect(result, isEmpty);

        // 2. Cache notifications
        await dataSource.cacheNotifications([mockNotification1, mockNotification2]);
        result = await dataSource.getCachedNotifications();
        expect(result, hasLength(2));

        // 3. Mark as read
        await dataSource.markAsReadInCache('notification_1');
        result = await dataSource.getCachedNotifications();
        expect(result, hasLength(2));
        expect(result.firstWhere((n) => n.id == 'notification_1').isRead, isTrue);

        // 4. Remove notification
        await dataSource.removeNotificationFromCache('notification_1');
        result = await dataSource.getCachedNotifications();
        expect(result, hasLength(1));
        expect(result[0].id, equals('notification_2'));

        // 5. Clear cache
        await dataSource.clearCache();
        result = await dataSource.getCachedNotifications();
        expect(result, isEmpty);
      });

      test('should handle book request notifications lifecycle', () async {
        // 1. Cache book request notification
        await dataSource.cacheNotifications([mockBookRequestNotification]);
        var result = await dataSource.getCachedNotifications();
        expect(result, hasLength(1));
        expect(result[0], isA<BookRequestNotificationModel>());

        // 2. Mark as read
        await dataSource.markAsReadInCache('notification_3');
        result = await dataSource.getCachedNotifications();
        expect(result[0].isRead, isTrue);

        // 3. Verify book request data is preserved
        final bookRequest = result[0] as BookRequestNotificationModel;
        expect(bookRequest.bookData?.bookId, equals('book_123'));
        expect(bookRequest.bookData?.bookTitle, equals('Test Book'));
        expect(bookRequest.bookData?.requestType, equals('borrow'));
        expect(bookRequest.bookData?.status, equals('pending'));
      });

      test('should handle cache persistence across multiple operations', () async {
        // 1. Cache mixed notifications
        await dataSource.cacheNotifications([
          mockNotification1,
          mockBookRequestNotification,
          mockNotification2,
        ]);

        // 2. Perform various operations
        await dataSource.markAsReadInCache('notification_1');
        await dataSource.removeNotificationFromCache('notification_2');
        
        var result = await dataSource.getCachedNotifications();
        expect(result, hasLength(2));
        
        // 3. Verify state
        final remaining = result.map((n) => n.id).toList();
        expect(remaining, containsAll(['notification_1', 'notification_3']));
        expect(result.firstWhere((n) => n.id == 'notification_1').isRead, isTrue);
        expect(result.firstWhere((n) => n.id == 'notification_3'), isA<BookRequestNotificationModel>());
      });
    });
  });
}
