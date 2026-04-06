import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_library/features/notifications/data/models/notification_model.dart';

abstract class NotificationsLocalDataSource {
  /// Get cached notifications
  Future<List<NotificationModel>> getCachedNotifications();

  /// Cache notifications
  Future<void> cacheNotifications(List<NotificationModel> notifications);

  /// Mark notification as read in cache
  Future<void> markAsReadInCache(String notificationId);

  /// Remove notification from cache
  Future<void> removeNotificationFromCache(String notificationId);

  /// Clear all cached notifications
  Future<void> clearCache();
}

class NotificationsLocalDataSourceImpl implements NotificationsLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _cachedNotificationsKey = 'CACHED_NOTIFICATIONS';

  NotificationsLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<NotificationModel>> getCachedNotifications() async {
    final jsonString = sharedPreferences.getString(_cachedNotificationsKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) {
        // Check if it's a book request notification
        if (json['type'] == 'bookRequest') {
          return BookRequestNotificationModel.fromJson(json);
        }
        return NotificationModel.fromJson(json);
      }).cast<NotificationModel>().toList();
    }
    return [];
  }

  @override
  Future<void> cacheNotifications(List<NotificationModel> notifications) async {
    final jsonList = notifications.map((notification) => notification.toJson()).toList();
    await sharedPreferences.setString(_cachedNotificationsKey, json.encode(jsonList));
  }

  @override
  Future<void> markAsReadInCache(String notificationId) async {
    final notifications = await getCachedNotifications();
    final updatedNotifications = notifications.map((notification) {
      if (notification.id == notificationId) {
        return notification.copyWith(isRead: true);
      }
      return notification;
    }).toList();
    await cacheNotifications(updatedNotifications);
  }

  @override
  Future<void> removeNotificationFromCache(String notificationId) async {
    final notifications = await getCachedNotifications();
    final updatedNotifications = notifications.where((notification) => notification.id != notificationId).toList();
    await cacheNotifications(updatedNotifications);
  }

  @override
  Future<void> clearCache() async {
    await sharedPreferences.remove(_cachedNotificationsKey);
  }
}
