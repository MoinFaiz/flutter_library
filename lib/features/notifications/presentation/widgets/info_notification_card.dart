import 'package:flutter/material.dart';
import 'package:flutter_library/core/constants/app_constants.dart';
import 'package:flutter_library/core/theme/app_colors.dart';
import 'package:flutter_library/core/theme/app_dimensions.dart';
import 'package:flutter_library/features/notifications/domain/entities/notification.dart';

class InfoNotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onDelete;

  const InfoNotificationCard({
    super.key,
    required this.notification,
    this.onTap,
    this.onMarkAsRead,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: notification.isRead ? 0 : 2,
      color: notification.isRead 
          ? Theme.of(context).colorScheme.surface
          : Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1),
      child: InkWell(
        onTap: () {
          if (!notification.isRead) {
            onMarkAsRead?.call();
          }
          onTap?.call();
        },
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              _buildNotificationIcon(context),
              const SizedBox(width: AppConstants.defaultPadding),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                            ),
                          ),
                        ),
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
                    SizedBox(height: AppDimensions.spaceXs),
                    Text(
                      notification.message,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    SizedBox(height: AppDimensions.spaceSm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatTimestamp(notification.timestamp),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        if (onDelete != null)
                          IconButton(
                            onPressed: onDelete,
                            icon: const Icon(Icons.delete_outline),
                            iconSize: AppDimensions.iconXs,
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(BuildContext context) {
    IconData iconData;
    Color color;

    switch (notification.type) {
      case NotificationType.reminder:
        iconData = Icons.access_time;
        color = AppColors.warning;
        break;
      case NotificationType.newBook:
        iconData = Icons.book;
        color = AppColors.success;
        break;
      case NotificationType.bookReturned:
        iconData = Icons.check_circle;
        color = Theme.of(context).colorScheme.primary;
        break;
      case NotificationType.overdue:
        iconData = Icons.warning;
        color = Theme.of(context).colorScheme.error;
        break;
      case NotificationType.information:
        iconData = Icons.info;
        color = Theme.of(context).colorScheme.primary;
        break;
      case NotificationType.systemUpdate:
        iconData = Icons.system_update;
        color = Theme.of(context).colorScheme.secondary;
        break;
      default:
        iconData = Icons.notifications;
        color = Theme.of(context).colorScheme.primary;
        break;
    }

    return CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.1),
      child: Icon(iconData, color: color, size: AppDimensions.iconSm),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
