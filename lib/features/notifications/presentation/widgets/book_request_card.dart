import 'package:flutter/material.dart';
import 'package:flutter_library/core/constants/app_constants.dart';
import 'package:flutter_library/core/theme/app_colors.dart';
import 'package:flutter_library/core/theme/app_dimensions.dart';
import 'package:flutter_library/core/theme/app_typography.dart';
import 'package:flutter_library/features/notifications/domain/entities/notification.dart';

class BookRequestCard extends StatelessWidget {
  final BookRequestNotification notification;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onDelete;
  final VoidCallback? onAccept;
  final Function(String?)? onReject;

  const BookRequestCard({
    super.key,
    required this.notification,
    this.onTap,
    this.onMarkAsRead,
    this.onDelete,
    this.onAccept,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: notification.isRead ? 0 : 3,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  _buildRequestIcon(context),
                  const SizedBox(width: AppConstants.defaultPadding),
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
                            _buildStatusChip(context),
                            if (!notification.isRead)
                              Container(
                                width: AppDimensions.dotSize,
                                height: AppDimensions.dotSize,
                                margin: const EdgeInsets.only(left: 8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        Text(
                          _formatTimestamp(notification.timestamp),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              
              // Book Info
              Container(
                padding: const EdgeInsets.all(AppConstants.smallPadding),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Book: ${notification.bookData?.bookTitle ?? 'Unknown'}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: AppDimensions.spaceXs),
                    Text(
                      'Requested by: ${notification.bookData?.requesterName ?? 'Unknown'}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (notification.bookData?.offerPrice != null) ...[
                      SizedBox(height: AppDimensions.spaceXs),
                      Text(
                        'Offer: \$${notification.bookData?.offerPrice?.toStringAsFixed(2) ?? '0.00'}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    if (notification.bookData?.pickupDate != null) ...[
                      SizedBox(height: AppDimensions.spaceXs),
                      Text(
                        'Pickup: ${_formatDate(notification.bookData!.pickupDate!)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                    if (notification.bookData?.pickupLocation != null) ...[
                      SizedBox(height: AppDimensions.spaceXs),
                      Text(
                        'Location: ${notification.bookData?.pickupLocation}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
              
              // Message
              if (notification.bookData?.requestMessage != null && notification.bookData!.requestMessage!.isNotEmpty) ...[
                const SizedBox(height: AppConstants.smallPadding),
                Text(
                  'Message:',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppDimensions.spaceXs),
                Text(
                  notification.bookData!.requestMessage!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              
              // Actions
              if (notification.bookData?.status == 'pending') ...[
                const SizedBox(height: AppConstants.defaultPadding),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showRejectDialog(context),
                        icon: const Icon(Icons.close),
                        label: const Text('Reject'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                          side: BorderSide(color: Theme.of(context).colorScheme.error),
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
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestIcon(BuildContext context) {
    IconData iconData;
    Color color;

    switch (notification.bookData?.requestType) {
      case 'rent':
        iconData = Icons.schedule;
        color = Theme.of(context).colorScheme.primary;
        break;
      case 'buy':
        iconData = Icons.shopping_cart;
        color = AppColors.success;
        break;
      case 'borrow':
        iconData = Icons.book;
        color = AppColors.warning;
        break;
      default:
        iconData = Icons.help_outline;
        color = Theme.of(context).colorScheme.outline;
        break;
    }

    return CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.1),
      child: Icon(iconData, color: color, size: AppDimensions.iconSm),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    Color chipColor;
    String statusText;

    switch (notification.bookData?.status) {
      case 'pending':
        chipColor = AppColors.warning;
        statusText = 'Pending';
        break;
      case 'accepted':
        chipColor = AppColors.success;
        statusText = 'Accepted';
        break;
      case 'rejected':
        chipColor = Theme.of(context).colorScheme.error;
        statusText = 'Rejected';
        break;
      case 'completed':
        chipColor = Theme.of(context).colorScheme.primary;
        statusText = 'Completed';
        break;
      case 'cancelled':
        chipColor = Theme.of(context).colorScheme.outline;
        statusText = 'Cancelled';
        break;
      default:
        chipColor = Theme.of(context).colorScheme.outline;
        statusText = 'Unknown';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: chipColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: chipColor,
          fontSize: AppTypography.fontSizeXs,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showRejectDialog(BuildContext context) {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Are you sure you want to reject this request?'),
            SizedBox(height: AppDimensions.spaceMd),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason (optional)',
                hintText: 'Enter reason for rejection...',
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
              onReject?.call(reasonController.text.trim().isEmpty 
                  ? null 
                  : reasonController.text.trim());
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
