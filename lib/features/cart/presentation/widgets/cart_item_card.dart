import 'package:flutter/material.dart';
import 'package:flutter_library/core/theme/app_colors.dart';
import 'package:flutter_library/core/theme/app_dimensions.dart';
import 'package:flutter_library/core/theme/app_typography.dart';
import 'package:flutter_library/core/utils/helpers/responsive_utils.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_item.dart';

class CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onRemove;
  final VoidCallback onSendRequest;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onRemove,
    required this.onSendRequest,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book Image
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              child: Builder(
                builder: (context) {
                  final coverSize = ResponsiveUtils.getResponsiveBookCoverSize(context);
                  return Image.network(
                    item.book.primaryImageUrl,
                    width: coverSize.width,
                    height: coverSize.height,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: coverSize.width,
                        height: coverSize.height,
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.book),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            
            // Book Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.book.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppDimensions.spaceXs),
                  Text(
                    item.book.author,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  SizedBox(height: AppDimensions.spaceSm),
                  
                  // Type Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: item.isRental ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1) : AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    ),
                    child: Text(
                      item.isRental 
                          ? 'Rent (${item.rentalPeriodInDays} days)'
                          : 'Purchase',
                      style: TextStyle(
                        fontSize: AppTypography.fontSizeXs,
                        color: item.isRental ? Theme.of(context).colorScheme.primary : AppColors.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: AppDimensions.spaceSm),
                  
                  // Price and Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${item.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                      ),
                      Row(
                        children: [
                          if (!item.hasRequestSent)
                            ElevatedButton(
                              onPressed: onSendRequest,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              child: const Text('Request'),
                            ),
                          if (item.hasRequestSent)
                            Chip(
                              label: const Text('Requested'),
                              backgroundColor: AppColors.warning.withValues(alpha: 0.1),
                              labelStyle: TextStyle(
                                fontSize: AppTypography.fontSizeXs,
                                color: AppColors.warning,
                              ),
                            ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            color: Theme.of(context).colorScheme.error,
                            onPressed: onRemove,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
