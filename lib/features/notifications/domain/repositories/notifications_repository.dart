import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/notifications/domain/entities/notification.dart';

/// Abstract repository for notifications
abstract class NotificationsRepository {
  /// Get all notifications for the current user
  Future<Either<Failure, List<AppNotification>>> getNotifications();

  /// Get unread notifications count
  Future<Either<Failure, int>> getUnreadCount();

  /// Mark a notification as read
  Future<Either<Failure, void>> markAsRead(String notificationId);

  /// Mark all notifications as read
  Future<Either<Failure, void>> markAllAsRead();

  /// Delete a notification
  Future<Either<Failure, void>> deleteNotification(String notificationId);

  /// Accept a book request
  Future<Either<Failure, void>> acceptBookRequest(String notificationId);

  /// Reject a book request
  Future<Either<Failure, void>> rejectBookRequest(String notificationId, String? reason);

  /// Subscribe to real-time notification updates
  Stream<List<AppNotification>> watchNotifications();
}
