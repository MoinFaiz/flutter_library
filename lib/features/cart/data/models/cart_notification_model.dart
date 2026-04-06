import 'package:flutter_library/features/cart/domain/entities/cart_notification.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_item.dart';

class CartNotificationModel extends CartNotification {
  const CartNotificationModel({
    required super.id,
    required super.requestId,
    required super.bookId,
    required super.bookTitle,
    required super.bookAuthor,
    required super.bookImageUrl,
    required super.type,
    required super.requestType,
    required super.message,
    required super.isRead,
    required super.createdAt,
    super.actionUserId,
    super.actionUserName,
  });

  factory CartNotificationModel.fromJson(Map<String, dynamic> json) {
    return CartNotificationModel(
      id: json['id'] as String,
      requestId: json['request_id'] as String,
      bookId: json['book_id'] as String,
      bookTitle: json['book_title'] as String,
      bookAuthor: json['book_author'] as String,
      bookImageUrl: json['book_image_url'] as String,
      type: _parseNotificationType(json['type'] as String),
      requestType: _parseRequestType(json['request_type'] as String),
      message: json['message'] as String,
      isRead: json['is_read'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      actionUserId: json['action_user_id'] as String?,
      actionUserName: json['action_user_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'request_id': requestId,
      'book_id': bookId,
      'book_title': bookTitle,
      'book_author': bookAuthor,
      'book_image_url': bookImageUrl,
      'type': _notificationTypeToString(type),
      'request_type': _requestTypeToString(requestType),
      'message': message,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'action_user_id': actionUserId,
      'action_user_name': actionUserName,
    };
  }

  factory CartNotificationModel.fromEntity(CartNotification notification) {
    return CartNotificationModel(
      id: notification.id,
      requestId: notification.requestId,
      bookId: notification.bookId,
      bookTitle: notification.bookTitle,
      bookAuthor: notification.bookAuthor,
      bookImageUrl: notification.bookImageUrl,
      type: notification.type,
      requestType: notification.requestType,
      message: notification.message,
      isRead: notification.isRead,
      createdAt: notification.createdAt,
      actionUserId: notification.actionUserId,
      actionUserName: notification.actionUserName,
    );
  }

  static NotificationType _parseNotificationType(String type) {
    switch (type.toLowerCase()) {
      case 'request_sent':
        return NotificationType.requestSent;
      case 'request_received':
        return NotificationType.requestReceived;
      case 'request_accepted':
        return NotificationType.requestAccepted;
      case 'request_rejected':
        return NotificationType.requestRejected;
      default:
        return NotificationType.requestSent;
    }
  }

  static String _notificationTypeToString(NotificationType type) {
    switch (type) {
      case NotificationType.requestSent:
        return 'request_sent';
      case NotificationType.requestReceived:
        return 'request_received';
      case NotificationType.requestAccepted:
        return 'request_accepted';
      case NotificationType.requestRejected:
        return 'request_rejected';
    }
  }

  static CartItemType _parseRequestType(String type) {
    switch (type.toLowerCase()) {
      case 'rent':
      case 'rental':
        return CartItemType.rent;
      case 'purchase':
      case 'buy':
        return CartItemType.purchase;
      default:
        return CartItemType.rent;
    }
  }

  static String _requestTypeToString(CartItemType type) {
    switch (type) {
      case CartItemType.rent:
        return 'rent';
      case CartItemType.purchase:
        return 'purchase';
    }
  }
}
