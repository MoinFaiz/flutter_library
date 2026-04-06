import 'package:flutter/material.dart';
import 'package:flutter_library/core/theme/app_colors.dart';

/// Interactive rating selector widget
class RatingSelector extends StatelessWidget {
  final double rating;
  final ValueChanged<double> onRatingChanged;
  final double size;
  final bool enabled;
  final bool allowHalfStars;

  const RatingSelector({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    this.size = 40.0,
    this.enabled = true,
    this.allowHalfStars = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1.0;
        final halfStarValue = index + 0.5;
        
        return GestureDetector(
          onTap: enabled
              ? () {
                  if (allowHalfStars && rating == starValue) {
                    // If clicking the same star, set to half star
                    onRatingChanged(halfStarValue);
                  } else {
                    onRatingChanged(starValue);
                  }
                }
              : null,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size * 0.08),
            child: Icon(
              _getStarIcon(starValue, halfStarValue),
              size: size,
              color: _getStarColor(starValue, halfStarValue, context),
            ),
          ),
        );
      }),
    );
  }

  IconData _getStarIcon(double starValue, double halfStarValue) {
    if (allowHalfStars && halfStarValue == rating) {
      return Icons.star_half;
    } else if (starValue <= rating) {
      return Icons.star;
    } else {
      return Icons.star_border;
    }
  }

  Color _getStarColor(double starValue, double halfStarValue, BuildContext context) {
    if (!enabled) {
      return Theme.of(context).colorScheme.outline.withValues(alpha: 0.3);
    }
    
    if ((allowHalfStars && halfStarValue == rating) || starValue <= rating) {
      return AppColors.ratingColor;
    }
    
    return Theme.of(context).colorScheme.outline;
  }
}
