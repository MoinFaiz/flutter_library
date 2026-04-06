import 'package:equatable/equatable.dart';
import 'package:flutter_library/features/notifications/domain/entities/notification_data.dart';

/// Base notification entity
class AppNotification extends Equatable {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;
  final NotificationData? data;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    this.data,
  });

  @override
  List<Object?> get props => [id, title, message, timestamp, type, isRead, data];

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    NotificationType? type,
    bool? isRead,
    NotificationData? data,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }
}

/// Book request notification entity
class BookRequestNotification extends AppNotification {
  /// Convenient access to typed book request data
  BookRequestData? get bookData => data as BookRequestData?;

  const BookRequestNotification({
    required super.id,
    required super.title,
    required super.message,
    required super.timestamp,
    required super.type,
    super.isRead = false,
    BookRequestData? bookRequestData,
  }) : super(data: bookRequestData);

  @override
  BookRequestNotification copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    NotificationType? type,
    bool? isRead,
    NotificationData? data,
  }) {
    return BookRequestNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      bookRequestData: data as BookRequestData? ?? bookData,
    );
  }
}

/// Notification types
enum NotificationType {
  information,
  reminder,
  bookRequest,
  bookReturned,
  newBook,
  overdue,
  systemUpdate,
  // Cart-related notification types
  cartRequestSent,
  cartRequestReceived,
  cartRequestAccepted,
  cartRequestRejected,
}

/// Request types for book requests
enum RequestType {
  rent,
  buy,
  borrow,
}

/// Status of book requests
enum RequestStatus {
  pending,
  accepted,
  rejected,
  completed,
  cancelled,
}
