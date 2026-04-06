import 'package:flutter/material.dart';
import 'package:flutter_library/core/constants/app_constants.dart';
import 'package:flutter_library/core/theme/app_colors.dart';
import 'package:flutter_library/core/theme/app_dimensions.dart';
import 'package:flutter_library/core/utils/extensions/string_extensions.dart';
import 'package:flutter_library/core/utils/helpers/responsive_utils.dart';
import 'package:flutter_library/features/orders/domain/entities/order.dart';
import 'package:flutter_library/shared/widgets/book_cover_image.dart';

/// Widget for displaying an order item card
class OrderCard extends StatelessWidget {
  final Order order;
  final bool isActive;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;

  const OrderCard({
    super.key,
    required this.order,
    required this.isActive,
    this.onTap,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isActive ? 4 : 2,
      child: Container(
        decoration: isActive
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  width: AppDimensions.dividerThin,
                ),
              )
            : null,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Book image
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.smallPadding),
                  child: Builder(
                    builder: (context) {
                      final coverSize = ResponsiveUtils.getResponsiveBookCoverSize(context);
                      return BookCoverImage(
                        imageUrl: order.bookImageUrl,
                        width: coverSize.width,
                        height: coverSize.height,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                
                // Order details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order ID and Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Order #${order.id}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          _buildStatusChip(context, order.status),
                        ],
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      
                      // Book title
                      Text(
                        order.bookTitle,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: AppDimensions.spaceXs),
                      
                      // Book author
                      Text(
                        'by ${order.bookAuthor}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      SizedBox(height: AppDimensions.spaceXs),
                      
                      // Order type
                      Row(
                        children: [
                          Icon(
                            order.type == OrderType.purchase 
                                ? Icons.shopping_cart_outlined 
                                : Icons.schedule_outlined,
                            size: AppDimensions.iconXs,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            order.type.name.capitalize,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      
                      // Date and price
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDate(order.orderDate),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                          Text(
                            '\$${order.price.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
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
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, OrderStatus status) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case OrderStatus.pending:
        backgroundColor = AppColors.warning.withValues(alpha: 0.1);
        textColor = AppColors.warning;
        break;
      case OrderStatus.processing:
        backgroundColor = Theme.of(context).colorScheme.primary.withValues(alpha: 0.1);
        textColor = Theme.of(context).colorScheme.primary;
        break;
      case OrderStatus.shipped:
        backgroundColor = Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1);
        textColor = Theme.of(context).colorScheme.secondary;
        break;
      case OrderStatus.delivered:
        backgroundColor = AppColors.success.withValues(alpha: 0.1);
        textColor = AppColors.success;
        break;
      case OrderStatus.returned:
        backgroundColor = Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.1);
        textColor = Theme.of(context).colorScheme.tertiary;
        break;
      case OrderStatus.completed:
        backgroundColor = Theme.of(context).colorScheme.outline.withValues(alpha: 0.1);
        textColor = Theme.of(context).colorScheme.outline;
        break;
      case OrderStatus.cancelled:
        backgroundColor = Theme.of(context).colorScheme.error.withValues(alpha: 0.1);
        textColor = Theme.of(context).colorScheme.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Text(
        order.status.name.capitalize,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
