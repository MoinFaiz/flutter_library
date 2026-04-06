import 'package:flutter/material.dart';
import 'package:flutter_library/core/theme/app_colors.dart';

/// Reusable price display component
class PriceDisplay extends StatelessWidget {
  final double price;
  final double? discountPrice;
  final TextStyle? originalPriceStyle;
  final TextStyle? discountPriceStyle;
  final String currency;

  const PriceDisplay({
    super.key,
    required this.price,
    this.discountPrice,
    this.originalPriceStyle,
    this.discountPriceStyle,
    this.currency = '\$',
  });

  bool get hasDiscount => discountPrice != null && discountPrice! < price;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (hasDiscount) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$currency${discountPrice!.toStringAsFixed(2)}',
            style: discountPriceStyle ?? 
                theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.discountColor,
                ),
          ),
          const SizedBox(width: 8),
          Text(
            '$currency${price.toStringAsFixed(2)}',
            style: originalPriceStyle ?? 
                theme.textTheme.bodySmall?.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: theme.colorScheme.outline,
                ),
          ),
        ],
      );
    }

    return Text(
      '$currency${price.toStringAsFixed(2)}',
      style: originalPriceStyle ?? theme.textTheme.bodyMedium,
    );
  }
}
