import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:flutter_library/features/notifications/data/datasources/notifications_remote_datasource_impl.dart';
import 'package:flutter_library/features/notifications/data/models/notification_model.dart';

class MockDio extends Mock implements Dio {}

void main() {
  group('NotificationsRemoteDataSourceImpl', () {
    late NotificationsRemoteDataSourceImpl dataSource;
    late MockDio mockDio;

    setUp(() {
      mockDio = MockDio();
      dataSource = NotificationsRemoteDataSourceImpl(dio: mockDio);
    });

    group('getNotifications', () {
      test('should return list of NotificationModel when request is successful', () async {
        // Act
        final result = await dataSource.getNotifications();

        // Assert
        expect(result, isA<List<NotificationModel>>());
        
        // Verify each item is a proper NotificationModel
        for (final notification in result) {
          expect(notification, isA<NotificationModel>());
          expect(notification.id, isNotEmpty);
          expect(notification.title, isNotEmpty);
          expect(notification.message, isNotEmpty);
          expect(notification.timestamp, isA<DateTime>());
        }
      });

      test('should have reasonable execution time with network delay', () async {
        // Act & Assert
        final stopwatch = Stopwatch()..start();
        
        await dataSource.getNotifications();
        
        stopwatch.stop();
        
        // Should complete within reasonable time (allowing for 500ms delay + overhead)
        expect(stopwatch.elapsedMilliseconds, lessThan(800));
        expect(stopwatch.elapsedMilliseconds, greaterThan(400)); // Should take at least 500ms due to delay
      });

      test('should return notifications sorted by creation date', () async {
        // Act
        final result = await dataSource.getNotifications();

        // Assert
        if (result.length > 1) {
          for (int i = 0; i < result.length - 1; i++) {
            // Notifications should be sorted by creation date (newest first)
            expect(
              result[i].timestamp.isAfter(result[i + 1].timestamp) || 
              result[i].timestamp.isAtSameMomentAs(result[i + 1].timestamp),
              isTrue,
              reason: 'Notifications should be sorted by creation date (newest first)',
            );
          }
        }
      });

      test('should return consistent data structure across multiple calls', () async {
        // Act
        final result1 = await dataSource.getNotifications();
        final result2 = await dataSource.getNotifications();

        // Assert
        expect(result1.length, equals(result2.length));
        
        for (int i = 0; i < result1.length; i++) {
          expect(result1[i].id, equals(result2[i].id));
          expect(result1[i].title, equals(result2[i].title));
          expect(result1[i].message, equals(result2[i].message));
        }
      });
    });

    group('markAsRead', () {
      test('should mark notification as read successfully', () async {
        // Arrange
        const notificationId = 'test-notification-id';

        // Act & Assert - Should not throw exception
        expect(
          () => dataSource.markAsRead(notificationId),
          returnsNormally,
        );
      });

      test('should handle empty notification ID gracefully', () async {
        // Act & Assert
        expect(
          () => dataSource.markAsRead(''),
          returnsNormally,
        );
      });

      test('should handle special characters in notification ID', () async {
        // Arrange
        const notificationId = '!@#\$%^&*()';

        // Act & Assert
        expect(
          () => dataSource.markAsRead(notificationId),
          returnsNormally,
        );
      });

      test('should have reasonable execution time', () async {
        // Arrange
        const notificationId = 'test-notification-id';

        // Act & Assert
        final stopwatch = Stopwatch()..start();
        
        await dataSource.markAsRead(notificationId);
        
        stopwatch.stop();
        
        // Should complete within reasonable time (allowing for 500ms delay + overhead)
        expect(stopwatch.elapsedMilliseconds, lessThan(600));
        expect(stopwatch.elapsedMilliseconds, greaterThan(400));
      });
    });

    group('deleteNotification', () {
      test('should delete notification successfully', () async {
        // Arrange
        const notificationId = 'test-notification-id';

        // Act & Assert - Should not throw exception
        expect(
          () => dataSource.deleteNotification(notificationId),
          returnsNormally,
        );
      });

      test('should handle nonexistent notification ID gracefully', () async {
        // Arrange
        const notificationId = 'nonexistent-notification-id';

        // Act & Assert
        expect(
          () => dataSource.deleteNotification(notificationId),
          returnsNormally,
        );
      });

      test('should handle unicode characters in notification ID', () async {
        // Arrange
        const notificationId = '🚀👍🎉';

        // Act & Assert
        expect(
          () => dataSource.deleteNotification(notificationId),
          returnsNormally,
        );
      });

      test('should have reasonable execution time', () async {
        // Arrange
        const notificationId = 'test-notification-id';

        // Act & Assert
        final stopwatch = Stopwatch()..start();
        
        await dataSource.deleteNotification(notificationId);
        
        stopwatch.stop();
        
        // Should complete within reasonable time (allowing for 500ms delay + overhead)
        expect(stopwatch.elapsedMilliseconds, lessThan(600));
        expect(stopwatch.elapsedMilliseconds, greaterThan(400));
      });
    });

    group('markAllAsRead', () {
      test('should mark all notifications as read successfully', () async {
        // Act & Assert - Should not throw exception
        expect(
          () => dataSource.markAllAsRead(),
          returnsNormally,
        );
      });

      test('should have reasonable execution time', () async {
        // Act & Assert
        final stopwatch = Stopwatch()..start();
        
        await dataSource.markAllAsRead();
        
        stopwatch.stop();
        
        // Should complete within reasonable time (allowing for 400ms delay + overhead)
        expect(stopwatch.elapsedMilliseconds, lessThan(700));
        expect(stopwatch.elapsedMilliseconds, greaterThan(350));
      });

      test('should handle rapid successive calls gracefully', () async {
        // Act & Assert - Should handle multiple rapid calls without issues
        final futures = <Future<void>>[];
        for (int i = 0; i < 3; i++) {
          futures.add(dataSource.markAllAsRead());
        }
        
        expect(
          () => Future.wait(futures),
          returnsNormally,
        );
      });
    });

    group('getUnreadCount', () {
      test('should return unread notification count', () async {
        // Act
        final result = await dataSource.getUnreadCount();

        // Assert
        expect(result, isA<int>());
        expect(result, greaterThanOrEqualTo(0));
      });

      test('should have fast execution time', () async {
        // Act & Assert
        final stopwatch = Stopwatch()..start();
        
        await dataSource.getUnreadCount();
        
        stopwatch.stop();
        
        // Should complete within reasonable time (allowing for 200ms delay + overhead)
        expect(stopwatch.elapsedMilliseconds, lessThan(400));
        expect(stopwatch.elapsedMilliseconds, greaterThan(150));
      });

      test('should return consistent count across multiple calls', () async {
        // Act
        final count1 = await dataSource.getUnreadCount();
        final count2 = await dataSource.getUnreadCount();

        // Assert
        expect(count1, equals(count2));
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle very long notification IDs', () async {
        // Arrange
        final longNotificationId = 'a' * 1000;

        // Act & Assert
        expect(
          () => dataSource.markAsRead(longNotificationId),
          returnsNormally,
        );
        
        expect(
          () => dataSource.deleteNotification(longNotificationId),
          returnsNormally,
        );
      });

      test('should handle null-like notification IDs gracefully', () async {
        // Arrange
        const nullLikeIds = ['null', 'undefined', 'NULL', ''];

        for (final id in nullLikeIds) {
          // Act & Assert
          expect(
            () => dataSource.markAsRead(id),
            returnsNormally,
            reason: 'Should handle $id gracefully',
          );
          
          expect(
            () => dataSource.deleteNotification(id),
            returnsNormally,
            reason: 'Should handle $id gracefully',
          );
        }
      });

      test('should handle rapid successive operations on same notification', () async {
        // Arrange
        const notificationId = 'rapid-test-notification';

        // Act & Assert - Should handle rapid operations without issues
        final futures = <Future<void>>[];
        futures.add(dataSource.markAsRead(notificationId));
        futures.add(dataSource.deleteNotification(notificationId));
        futures.add(dataSource.markAsRead(notificationId)); // Mark as read after delete
        
        expect(
          () => Future.wait(futures),
          returnsNormally,
        );
      });

      test('should handle concurrent getNotifications calls', () async {
        // Act
        final future1 = dataSource.getNotifications();
        final future2 = dataSource.getNotifications();
        final future3 = dataSource.getUnreadCount();
        
        final results = await Future.wait([future1, future2, future3]);

        // Assert
        expect(results.length, equals(3));
        expect(results[0], isA<List<NotificationModel>>());
        expect(results[1], isA<List<NotificationModel>>());
        expect(results[2], isA<int>());
        
        // Both notification lists should be identical
        final list1 = results[0] as List<NotificationModel>;
        final list2 = results[1] as List<NotificationModel>;
        expect(list1.length, equals(list2.length));
      });

      test('should maintain data integrity after operations', () async {
        // Act - Get initial state
        final initialNotifications = await dataSource.getNotifications();

        // Perform some operations
        if (initialNotifications.isNotEmpty) {
          await dataSource.markAsRead(initialNotifications.first.id);
        }
        await dataSource.markAllAsRead();

        // Get final state
        final finalNotifications = await dataSource.getNotifications();
        final finalUnreadCount = await dataSource.getUnreadCount();

        // Assert - Data should remain consistent
        expect(finalNotifications, isA<List<NotificationModel>>());
        expect(finalUnreadCount, isA<int>());
        expect(finalUnreadCount, greaterThanOrEqualTo(0));
        
        // Should have same or fewer notifications (none should be added by our operations)
        expect(finalNotifications.length, lessThanOrEqualTo(initialNotifications.length));
      });
    });

    group('Data Validation', () {
      test('should return notifications with valid data structure', () async {
        // Act
        final notifications = await dataSource.getNotifications();

        // Assert
        for (final notification in notifications) {
          expect(notification.id, isNotEmpty);
          expect(notification.title, isNotEmpty);
          expect(notification.message, isNotEmpty);
          expect(notification.timestamp, isA<DateTime>());
          expect(notification.isRead, isA<bool>());
          
          // Timestamp should be a reasonable date (not in the far future)
          expect(notification.timestamp.isBefore(DateTime.now().add(const Duration(days: 1))), true);
          
          // Timestamp should not be too far in the past (within 10 years)
          expect(notification.timestamp.isAfter(DateTime.now().subtract(const Duration(days: 3650))), true);
        }
      });

      test('should return unique notification IDs', () async {
        // Act
        final notifications = await dataSource.getNotifications();

        // Assert
        final ids = notifications.map((n) => n.id).toList();
        final uniqueIds = ids.toSet();
        
        expect(uniqueIds.length, equals(ids.length), 
            reason: 'All notification IDs should be unique');
      });

      test('should have consistent unread count with notification list', () async {
        // Act
        final notifications = await dataSource.getNotifications();
        final unreadCount = await dataSource.getUnreadCount();

        // Assert
        final actualUnreadCount = notifications.where((n) => !n.isRead).length;
        expect(unreadCount, equals(actualUnreadCount),
            reason: 'Unread count should match the actual number of unread notifications');
      });
    });
  });
}
