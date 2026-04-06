import 'package:flutter/material.dart';
import 'package:flutter_library/core/constants/app_constants.dart';
import 'package:flutter_library/core/theme/app_colors.dart';

/// Reusable rating display component
class RatingDisplay extends StatelessWidget {
  final double rating;
  final double iconSize;
  final Color? iconColor;
  final TextStyle? textStyle;
  final MainAxisAlignment alignment;

  const RatingDisplay({
    super.key,
    required this.rating,
    this.iconSize = AppConstants.ratingSize,
    this.iconColor,
    this.textStyle,
    this.alignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star,
          size: iconSize,
          color: iconColor ?? AppColors.ratingColor,
        ),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: textStyle ?? Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
