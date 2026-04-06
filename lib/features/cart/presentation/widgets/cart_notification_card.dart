import 'package:flutter/material.dart';
import 'package:flutter_library/core/theme/app_colors.dart';
import 'package:flutter_library/core/theme/app_dimensions.dart';
import 'package:flutter_library/core/utils/helpers/responsive_utils.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_notification.dart';

class CartNotificationCard extends StatelessWidget {
  final CartNotification notification;
  final VoidCallback onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const CartNotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
    this.onAccept,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: notification.isRead ? null : Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icon based on notification type
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getIconColor(context, notification.type).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getIcon(notification.type),
                      color: _getIconColor(context, notification.type),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Notification content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getTitle(notification.type),
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        SizedBox(height: AppDimensions.spaceXs),
                        Text(
                          notification.message,
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  // Unread indicator
                  if (!notification.isRead)
                    Container(
                      width: AppDimensions.dotSize,
                      height: AppDimensions.dotSize,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              
              SizedBox(height: AppDimensions.spaceSm),
              
              // Book info
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
                    child: Builder(
                      builder: (context) {
                        final coverSize = ResponsiveUtils.getResponsiveBookCoverSize(context);
                        return Image.network(
                          notification.bookImageUrl,
                          width: coverSize.width * 0.6,
                          height: coverSize.height * 0.75,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: coverSize.width * 0.6,
                              height: coverSize.height * 0.75,
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              child: const Icon(Icons.book, size: 20),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.bookTitle,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          notification.bookAuthor,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: AppDimensions.spaceSm),
              
              // Time and actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatTime(notification.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  
                  // Action buttons for received requests
                  if (notification.requiresAction && onAccept != null && onReject != null)
                    Row(
                      children: [
                        TextButton(
                          onPressed: onReject,
                          child: const Text('Reject'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: onAccept,
                          child: const Text('Accept'),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.requestSent:
        return Icons.send;
      case NotificationType.requestReceived:
        return Icons.inbox;
      case NotificationType.requestAccepted:
        return Icons.check_circle;
      case NotificationType.requestRejected:
        return Icons.cancel;
    }
  }

  Color _getIconColor(BuildContext context, NotificationType type) {
    switch (type) {
      case NotificationType.requestSent:
        return Theme.of(context).colorScheme.primary;
      case NotificationType.requestReceived:
        return AppColors.warning;
      case NotificationType.requestAccepted:
        return AppColors.success;
      case NotificationType.requestRejected:
        return Theme.of(context).colorScheme.error;
    }
  }

  String _getTitle(NotificationType type) {
    switch (type) {
      case NotificationType.requestSent:
        return 'Request Sent';
      case NotificationType.requestReceived:
        return 'New Request';
      case NotificationType.requestAccepted:
        return 'Request Accepted';
      case NotificationType.requestRejected:
        return 'Request Rejected';
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
