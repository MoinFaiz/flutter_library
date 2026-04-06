import 'package:flutter_library/features/notifications/domain/entities/notification.dart';
import 'package:flutter_library/features/notifications/domain/entities/notification_data.dart';

/// Converter utility for notification data
class NotificationDataConverter {
  /// Convert JSON to type-safe notification data
  static NotificationData? fromJson(Map<String, dynamic>? json, NotificationType type) {
    if (json == null) return null;

    switch (type) {
      case NotificationType.bookRequest:
        return BookRequestData(
          bookId: json['bookId'] as String,
          bookTitle: json['bookTitle'] as String,
          requesterId: json['requesterId'] as String,
          requesterName: json['requesterName'] as String,
          requesterEmail: json['requesterEmail'] as String,
          requestType: json['requestType'] as String,
          pickupDate: json['pickupDate'] != null
              ? DateTime.parse(json['pickupDate'] as String)
              : null,
          pickupLocation: json['pickupLocation'] as String?,
          offerPrice: json['offerPrice']?.toDouble(),
          requestMessage: json['requestMessage'] as String?,
          status: json['status'] as String? ?? 'pending',
        );
      case NotificationType.reminder:
        return BookReminderData(
          bookId: json['bookId'] as String,
          bookTitle: json['bookTitle'] as String,
          dueDate: DateTime.parse(json['dueDate'] as String),
        );
      case NotificationType.bookReturned:
      case NotificationType.overdue:
        return BookStatusData(
          bookId: json['bookId'] as String,
          bookTitle: json['bookTitle'] as String,
          status: json['status'] as String,
        );
      default:
        return const SystemNotificationData();
    }
  }

  /// Convert type-safe notification data to JSON
  static Map<String, dynamic>? toJson(NotificationData? data) {
    if (data == null) return null;

    if (data is BookRequestData) {
      return {
        'bookId': data.bookId,
        'bookTitle': data.bookTitle,
        'requesterId': data.requesterId,
        'requesterName': data.requesterName,
        'requesterEmail': data.requesterEmail,
        'requestType': data.requestType,
        'pickupDate': data.pickupDate?.toIso8601String(),
        'pickupLocation': data.pickupLocation,
        'offerPrice': data.offerPrice,
        'requestMessage': data.requestMessage,
        'status': data.status,
      };
    } else if (data is BookReminderData) {
      return {
        'bookId': data.bookId,
        'bookTitle': data.bookTitle,
        'dueDate': data.dueDate.toIso8601String(),
      };
    } else if (data is BookStatusData) {
      return {
        'bookId': data.bookId,
        'bookTitle': data.bookTitle,
        'status': data.status,
      };
    } else if (data is SystemNotificationData) {
      return {};
    }

    return null;
  }
}
