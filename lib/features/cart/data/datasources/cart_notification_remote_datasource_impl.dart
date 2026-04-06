import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_library/core/error/exceptions.dart';
import 'package:flutter_library/features/cart/data/datasources/cart_notification_remote_datasource.dart';
import 'package:flutter_library/features/cart/data/models/cart_notification_model.dart';

class CartNotificationRemoteDataSourceImpl implements CartNotificationRemoteDataSource {
  final Dio dio;
  final StreamController<List<CartNotificationModel>> _notificationController = 
      StreamController<List<CartNotificationModel>>.broadcast();

  CartNotificationRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<CartNotificationModel>> getNotifications() async {
    try {
      final response = await dio.get('/cart/notifications');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] as List<dynamic>;
        final notifications = data
            .map((json) => CartNotificationModel.fromJson(json as Map<String, dynamic>))
            .toList();
        
        // Update stream with latest notifications
        _notificationController.add(notifications);
        
        return notifications;
      } else {
        throw ServerException('Failed to fetch notifications');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await dio.get('/cart/notifications/unread-count');
      
      if (response.statusCode == 200) {
        return response.data['count'] as int;
      } else {
        throw ServerException('Failed to fetch unread count');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      final response = await dio.post(
        '/cart/notifications/$notificationId/read',
      );
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException('Failed to mark notification as read');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      final response = await dio.post(
        '/cart/notifications/read-all',
      );
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException('Failed to mark all as read');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      final response = await dio.delete(
        '/cart/notifications/$notificationId',
      );
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException('Failed to delete notification');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Stream<List<CartNotificationModel>> watchNotifications() {
    return _notificationController.stream;
  }

  void dispose() {
    _notificationController.close();
  }
}
