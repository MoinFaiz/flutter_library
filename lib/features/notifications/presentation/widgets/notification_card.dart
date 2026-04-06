import 'package:flutter/material.dart';
import 'package:flutter_library/features/notifications/domain/entities/notification.dart';
import 'package:flutter_library/features/notifications/presentation/widgets/book_request_card.dart';
import 'package:flutter_library/features/notifications/presentation/widgets/cart_notification_card.dart';
import 'package:flutter_library/features/notifications/presentation/widgets/info_notification_card.dart';

class NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onDelete;
  final Function(String, String?)? onAcceptBookRequest;
  final Function(String, String?)? onRejectBookRequest;
  final Function(String, String?)? onAcceptCartRequest;
  final Function(String, String?)? onRejectCartRequest;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
    this.onMarkAsRead,
    this.onDelete,
    this.onAcceptBookRequest,
    this.onRejectBookRequest,
    this.onAcceptCartRequest,
    this.onRejectCartRequest,
  });

  @override
  Widget build(BuildContext context) {
    // Handle book request notifications
    if (notification.type == NotificationType.bookRequest && 
        notification is BookRequestNotification) {
      return BookRequestCard(
        notification: notification as BookRequestNotification,
        onTap: onTap,
        onMarkAsRead: onMarkAsRead,
        onDelete: onDelete,
        onAccept: onAcceptBookRequest != null 
            ? () => onAcceptBookRequest!(notification.id, null)
            : null,
        onReject: onRejectBookRequest != null 
            ? (reason) => onRejectBookRequest!(notification.id, reason)
            : null,
      );
    }

    // Handle cart notifications
    if (_isCartNotification(notification.type)) {
      return CartNotificationCard(
        notification: notification,
        onTap: onTap,
        onMarkAsRead: onMarkAsRead,
        onDelete: onDelete,
        onAccept: onAcceptCartRequest != null && 
                  notification.type == NotificationType.cartRequestReceived
            ? () => onAcceptCartRequest!(notification.id, null)
            : null,
        onReject: onRejectCartRequest != null && 
                  notification.type == NotificationType.cartRequestReceived
            ? (reason) => onRejectCartRequest!(notification.id, reason)
            : null,
      );
    }

    // Handle all other notifications
    return InfoNotificationCard(
      notification: notification,
      onTap: onTap,
      onMarkAsRead: onMarkAsRead,
      onDelete: onDelete,
    );
  }

  bool _isCartNotification(NotificationType type) {
    return type == NotificationType.cartRequestSent ||
           type == NotificationType.cartRequestReceived ||
           type == NotificationType.cartRequestAccepted ||
           type == NotificationType.cartRequestRejected;
  }
}
