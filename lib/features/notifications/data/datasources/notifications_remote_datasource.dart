import 'package:flutter_library/features/notifications/data/models/notification_model.dart';

abstract class NotificationsRemoteDataSource {
  /// Get all notifications from server
  Future<List<NotificationModel>> getNotifications();

  /// Get unread notifications count
  Future<int> getUnreadCount();

  /// Mark notification as read
  Future<void> markAsRead(String notificationId);

  /// Mark all notifications as read
  Future<void> markAllAsRead();

  /// Delete a notification
  Future<void> deleteNotification(String notificationId);

  /// Accept a book request
  Future<void> acceptBookRequest(String notificationId);

  /// Reject a book request
  Future<void> rejectBookRequest(String notificationId, String? reason);
}
