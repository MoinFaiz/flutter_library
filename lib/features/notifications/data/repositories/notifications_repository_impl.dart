import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/notifications/domain/entities/notification.dart';
import 'package:flutter_library/features/notifications/domain/entities/notification_data.dart';
import 'package:flutter_library/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:flutter_library/features/notifications/data/datasources/notifications_remote_datasource.dart';
import 'package:flutter_library/features/notifications/data/datasources/notifications_local_datasource.dart';
import 'package:flutter_library/features/notifications/data/models/notification_model.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource remoteDataSource;
  final NotificationsLocalDataSource localDataSource;
  final StreamController<List<AppNotification>> _notificationsController = 
      StreamController<List<AppNotification>>.broadcast();

  NotificationsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<AppNotification>>> getNotifications() async {
    try {
      // Try to get from cache first
      final cachedNotifications = await localDataSource.getCachedNotifications();
      if (cachedNotifications.isNotEmpty) {
        _notificationsController.add(cachedNotifications.cast<AppNotification>());
      }
      
      // Fetch from remote
      final notifications = await remoteDataSource.getNotifications();
      
      // Cache the results
      await localDataSource.cacheNotifications(notifications);
      
      // Update stream
      _notificationsController.add(notifications.cast<AppNotification>());
      
      return Right(notifications.cast<AppNotification>());
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure('Failed to get notifications: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    try {
      final count = await remoteDataSource.getUnreadCount();
      return Right(count);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure('Failed to get unread count: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    try {
      await remoteDataSource.markAsRead(notificationId);
      
      // Update cache
      await localDataSource.markAsReadInCache(notificationId);
      
      // Update stream with latest data
      final cachedNotifications = await localDataSource.getCachedNotifications();
      _notificationsController.add(cachedNotifications.cast<AppNotification>());
      
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure('Failed to mark notification as read: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    try {
      await remoteDataSource.markAllAsRead();
      
      // Update cache - mark all as read
      final cachedNotifications = await localDataSource.getCachedNotifications();
      final updatedNotifications = cachedNotifications.map((notification) => 
          notification.copyWith(isRead: true)).toList();
      await localDataSource.cacheNotifications(updatedNotifications);
      
      // Update stream
      _notificationsController.add(updatedNotifications.cast<AppNotification>());
      
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure('Failed to mark all notifications as read: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNotification(String notificationId) async {
    try {
      await remoteDataSource.deleteNotification(notificationId);
      
      // Remove from cache
      await localDataSource.removeNotificationFromCache(notificationId);
      
      // Update stream
      final cachedNotifications = await localDataSource.getCachedNotifications();
      _notificationsController.add(cachedNotifications.cast<AppNotification>());
      
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure('Failed to delete notification: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> acceptBookRequest(String notificationId) async {
    try {
      await remoteDataSource.acceptBookRequest(notificationId);
      
      // Update the notification status in cache
      final cachedNotifications = await localDataSource.getCachedNotifications();
      final updatedNotifications = cachedNotifications.map((notification) {
        if (notification.id == notificationId && notification is BookRequestNotificationModel) {
          final currentData = notification.bookData;
          if (currentData != null) {
            final updatedData = BookRequestData(
              bookId: currentData.bookId,
              bookTitle: currentData.bookTitle,
              requesterId: currentData.requesterId,
              requesterName: currentData.requesterName,
              requesterEmail: currentData.requesterEmail,
              requestType: currentData.requestType,
              pickupDate: currentData.pickupDate,
              pickupLocation: currentData.pickupLocation,
              offerPrice: currentData.offerPrice,
              requestMessage: currentData.requestMessage,
              status: 'accepted',
            );
            return notification.copyWith(data: updatedData);
          }
        }
        return notification;
      }).toList();
      await localDataSource.cacheNotifications(updatedNotifications);
      
      // Update stream
      _notificationsController.add(updatedNotifications.cast<AppNotification>());
      
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure('Failed to accept book request: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> rejectBookRequest(String notificationId, String? reason) async {
    try {
      await remoteDataSource.rejectBookRequest(notificationId, reason);
      
      // Update the notification status in cache
      final cachedNotifications = await localDataSource.getCachedNotifications();
      final updatedNotifications = cachedNotifications.map((notification) {
        if (notification.id == notificationId && notification is BookRequestNotificationModel) {
          final currentData = notification.bookData;
          if (currentData != null) {
            final updatedData = BookRequestData(
              bookId: currentData.bookId,
              bookTitle: currentData.bookTitle,
              requesterId: currentData.requesterId,
              requesterName: currentData.requesterName,
              requesterEmail: currentData.requesterEmail,
              requestType: currentData.requestType,
              pickupDate: currentData.pickupDate,
              pickupLocation: currentData.pickupLocation,
              offerPrice: currentData.offerPrice,
              requestMessage: currentData.requestMessage,
              status: 'rejected',
            );
            return notification.copyWith(data: updatedData);
          }
        }
        return notification;
      }).toList();
      await localDataSource.cacheNotifications(updatedNotifications);
      
      // Update stream
      _notificationsController.add(updatedNotifications.cast<AppNotification>());
      
      return const Right(null);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnknownFailure('Failed to reject book request: $e'));
    }
  }

  @override
  Stream<List<AppNotification>> watchNotifications() {
    return _notificationsController.stream;
  }

  Failure _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure(message: 'Connection timeout');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 404) {
          return const ServerFailure(message: 'Notifications not found');
        } else if (statusCode == 401) {
          return const ServerFailure(message: 'Unauthorized access');
        }
        return ServerFailure(message: 'Server error: ${e.response?.statusMessage}');
      case DioExceptionType.cancel:
        return const NetworkFailure(message: 'Request cancelled');
      case DioExceptionType.unknown:
        return const NetworkFailure(message: 'Network error');
      default:
        return const UnknownFailure('Unknown error occurred');
    }
  }

  void dispose() {
    _notificationsController.close();
  }
}
