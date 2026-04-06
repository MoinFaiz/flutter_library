import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_library/features/cart/data/models/cart_notification_model.dart';

abstract class CartNotificationLocalDataSource {
  Future<List<CartNotificationModel>> getCachedNotifications();
  Future<void> cacheNotifications(List<CartNotificationModel> notifications);
  Future<int> getCachedUnreadCount();
  Future<void> cacheUnreadCount(int count);
  Future<void> clearCache();
}

class CartNotificationLocalDataSourceImpl implements CartNotificationLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String notificationsCacheKey = 'CART_NOTIFICATIONS_CACHE';
  static const String unreadCountCacheKey = 'CART_NOTIFICATIONS_UNREAD_COUNT';

  CartNotificationLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<CartNotificationModel>> getCachedNotifications() async {
    final jsonString = sharedPreferences.getString(notificationsCacheKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => CartNotificationModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<void> cacheNotifications(List<CartNotificationModel> notifications) async {
    final jsonList = notifications.map((notification) => notification.toJson()).toList();
    await sharedPreferences.setString(notificationsCacheKey, json.encode(jsonList));
  }

  @override
  Future<int> getCachedUnreadCount() async {
    return sharedPreferences.getInt(unreadCountCacheKey) ?? 0;
  }

  @override
  Future<void> cacheUnreadCount(int count) async {
    await sharedPreferences.setInt(unreadCountCacheKey, count);
  }

  @override
  Future<void> clearCache() async {
    await sharedPreferences.remove(notificationsCacheKey);
    await sharedPreferences.remove(unreadCountCacheKey);
  }
}
