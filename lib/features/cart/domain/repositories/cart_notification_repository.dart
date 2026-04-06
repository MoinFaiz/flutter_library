import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_notification.dart';

abstract class CartNotificationRepository {
  /// Get all notifications for the current user
  Future<Either<Failure, List<CartNotification>>> getNotifications();

  /// Get unread notification count
  Future<Either<Failure, int>> getUnreadCount();

  /// Mark a notification as read
  Future<Either<Failure, void>> markAsRead(String notificationId);

  /// Mark all notifications as read
  Future<Either<Failure, void>> markAllAsRead();

  /// Delete a notification
  Future<Either<Failure, void>> deleteNotification(String notificationId);

  /// Listen to notification updates (Stream)
  Stream<List<CartNotification>> watchNotifications();
}
