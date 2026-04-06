import 'package:dio/dio.dart';
import 'package:flutter_library/features/notifications/data/datasources/notifications_remote_datasource.dart';
import 'package:flutter_library/features/notifications/data/models/notification_model.dart';
import 'package:flutter_library/features/notifications/domain/entities/notification.dart';
import 'package:flutter_library/features/notifications/domain/entities/notification_data.dart';

class NotificationsRemoteDataSourceImpl implements NotificationsRemoteDataSource {
  final Dio dio;

  NotificationsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await dio.get('/notifications');
      final List<dynamic> data = response.data['notifications'];
      
      return data.map((json) {
        // Check if it's a book request notification
        if (json['type'] == 'bookRequest') {
          return BookRequestNotificationModel.fromJson(json);
        }
        return NotificationModel.fromJson(json);
      }).cast<NotificationModel>().toList();
    } catch (e) {
      // For development, return mock data with simulated network delay
      await Future.delayed(const Duration(milliseconds: 500));
      return _getMockNotifications();
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await dio.get('/notifications/unread-count');
      return response.data['count'];
    } catch (e) {
      // For development, add simulated network delay and return mock count
      await Future.delayed(const Duration(milliseconds: 200));
      return 3;
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await dio.patch('/notifications/$notificationId/read');
    } catch (e) {
      // For development, just simulate success
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      await dio.patch('/notifications/mark-all-read');
    } catch (e) {
      // For development, just simulate success
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      await dio.delete('/notifications/$notificationId');
    } catch (e) {
      // For development, just simulate success
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  @override
  Future<void> acceptBookRequest(String notificationId) async {
    try {
      await dio.post('/book-requests/$notificationId/accept');
    } catch (e) {
      // For development, just simulate success
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  @override
  Future<void> rejectBookRequest(String notificationId, String? reason) async {
    try {
      await dio.post('/book-requests/$notificationId/reject', data: {
        'reason': reason,
      });
    } catch (e) {
      // For development, just simulate success
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  // Mock data for development
  List<NotificationModel> _getMockNotifications() {
    final now = DateTime.now();
    
    final List<NotificationModel> notifications = [
      BookRequestNotificationModel(
        id: '1',
        title: 'Book Rental Request',
        message: 'John Doe wants to rent "Flutter in Action"',
        timestamp: now.subtract(const Duration(hours: 1)),
        type: NotificationType.bookRequest,
        isRead: false,
        bookRequestData: BookRequestData(
          bookId: 'book_1',
          bookTitle: 'Flutter in Action',
          requesterId: 'user_123',
          requesterName: 'John Doe',
          requesterEmail: 'john.doe@email.com',
          requestType: 'rent',
          pickupDate: now.add(const Duration(days: 2)),
          pickupLocation: 'Central Library',
          requestMessage: 'Hi, I would like to rent this book for a week. Can we arrange pickup at the central library?',
          status: 'pending',
        ),
      ),
      BookRequestNotificationModel(
        id: '2',
        title: 'Book Purchase Offer',
        message: 'Sarah Smith wants to buy "Clean Architecture"',
        timestamp: now.subtract(const Duration(hours: 3)),
        type: NotificationType.bookRequest,
        isRead: false,
        bookRequestData: BookRequestData(
          bookId: 'book_2',
          bookTitle: 'Clean Architecture',
          requesterId: 'user_456',
          requesterName: 'Sarah Smith',
          requesterEmail: 'sarah.smith@email.com',
          requestType: 'buy',
          offerPrice: 25.99,
          pickupDate: now.add(const Duration(days: 1)),
          pickupLocation: 'Downtown Coffee Shop',
          requestMessage: 'I\'m interested in purchasing this book. My offer is \$25.99. Let me know if this works for you.',
          status: 'pending',
        ),
      ),
      NotificationModel(
        id: '3',
        title: 'Book Due Soon',
        message: 'Your book "Design Patterns" is due in 2 days',
        timestamp: now.subtract(const Duration(hours: 6)),
        type: NotificationType.reminder,
        isRead: false,
      ),
      NotificationModel(
        id: '4',
        title: 'New Book Available',
        message: 'A new book "Dart Programming" has been added to the library',
        timestamp: now.subtract(const Duration(days: 1)),
        type: NotificationType.newBook,
        isRead: true,
      ),
      NotificationModel(
        id: '5',
        title: 'Book Returned Successfully',
        message: 'You have successfully returned "React Native in Action"',
        timestamp: now.subtract(const Duration(days: 2)),
        type: NotificationType.bookReturned,
        isRead: true,
      ),
    ];
    
    return notifications;
  }
}
