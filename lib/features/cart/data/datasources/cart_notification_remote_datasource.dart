import 'package:flutter_library/features/cart/data/models/cart_notification_model.dart';

abstract class CartNotificationRemoteDataSource {
  Future<List<CartNotificationModel>> getNotifications();
  Future<int> getUnreadCount();
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String notificationId);
  Stream<List<CartNotificationModel>> watchNotifications();
}
