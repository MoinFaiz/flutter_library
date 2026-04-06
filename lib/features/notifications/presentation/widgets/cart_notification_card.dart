import 'package:flutter/material.dart';
import 'package:flutter_library/core/constants/app_constants.dart';
import 'package:flutter_library/core/theme/app_colors.dart';
import 'package:flutter_library/core/theme/app_dimensions.dart';
import 'package:flutter_library/core/utils/extensions/date_extensions.dart';
import 'package:flutter_library/features/notifications/domain/entities/notification.dart';
import 'package:flutter_library/features/notifications/domain/entities/notification_data.dart';

/// Card widget for cart-related notifications
class CartNotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onDelete;
  final VoidCallback? onAccept;
  final Function(String?)? onReject;

  const CartNotificationCard({
    super.key,
    required this.notification,
    this.onTap,
    this.onMarkAsRead,
    this.onDelete,
    this.onAccept,
    this.onReject,
  });

  CartNotificationData? get _cartData => 
      notification.data as CartNotificationData?;

  bool get _requiresAction => 
      notification.type == NotificationType.cartRequestReceived;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: notification.isRead ? 0 : 2,
      color: notification.isRead
          ? Theme.of(context).colorScheme.surfaceContainerLowest
          : Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        side: BorderSide(
          color: notification.isRead
              ? Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)
              : Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          width: notification.isRead ? 1 : 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          onMarkAsRead?.call();
          onTap?.call();
        },
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: AppConstants.smallPadding),
              if (_cartData != null) _buildCartDetails(context),
              const SizedBox(height: AppConstants.smallPadding),
              Text(
                notification.message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              if (_requiresAction && onAccept != null && onReject != null) ...[
                const SizedBox(height: AppConstants.defaultPadding),
                _buildActionButtons(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        _buildIcon(context),
        const SizedBox(width: AppConstants.smallPadding),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: AppDimensions.spaceXs),
              Text(
                notification.timestamp.timeAgo,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ],
          ),
        ),
        if (!notification.isRead)
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }

  Widget _buildIcon(BuildContext context) {
    IconData iconData;
    Color iconColor;

    switch (notification.type) {
      case NotificationType.cartRequestSent:
        iconData = Icons.send;
        iconColor = Theme.of(context).colorScheme.primary;
        break;
      case NotificationType.cartRequestReceived:
        iconData = Icons.inbox;
        iconColor = Theme.of(context).colorScheme.tertiary;
        break;
      case NotificationType.cartRequestAccepted:
        iconData = Icons.check_circle;
        iconColor = AppColors.success;
        break;
      case NotificationType.cartRequestRejected:
        iconData = Icons.cancel;
        iconColor = Theme.of(context).colorScheme.error;
        break;
      default:
        iconData = Icons.shopping_cart;
        iconColor = Theme.of(context).colorScheme.primary;
    }

    return Container(
      padding: const EdgeInsets.all(AppConstants.smallPadding),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.smallPadding),
      ),
      child: Icon(iconData, color: iconColor, size: AppDimensions.iconMd),
    );
  }

  Widget _buildCartDetails(BuildContext context) {
    final cartData = _cartData!;

    return Container(
      padding: const EdgeInsets.all(AppConstants.smallPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppConstants.smallPadding),
      ),
      child: Row(
        children: [
          // Book cover
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
            child: Image.network(
              cartData.bookImageUrl,
              width: 50,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 50,
                  height: 70,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.book,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: AppConstants.smallPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartData.bookTitle,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppDimensions.spaceXs),
                Text(
                  cartData.bookAuthor,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                SizedBox(height: AppDimensions.spaceXs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: cartData.requestType == 'rent'
                        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                        : AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
                  ),
                  child: Text(
                    cartData.requestType.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: cartData.requestType == 'rent'
                              ? Theme.of(context).colorScheme.primary
                              : AppColors.success,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showRejectDialog(context),
            icon: const Icon(Icons.close),
            label: const Text('Reject'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              side: BorderSide(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppConstants.smallPadding),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onAccept,
            icon: const Icon(Icons.check),
            label: const Text('Accept'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
      ],
    );
  }

  void _showRejectDialog(BuildContext context) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Are you sure you want to reject this request?'),
            const SizedBox(height: AppConstants.defaultPadding),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason (optional)',
                hintText: 'Provide a reason for rejection...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onReject?.call(
                reasonController.text.isEmpty ? null : reasonController.text,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}
