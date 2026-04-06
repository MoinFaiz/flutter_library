import 'package:flutter/material.dart';
import 'package:flutter_library/core/constants/app_constants.dart';
import 'package:flutter_library/core/utils/helpers/responsive_utils.dart';
import 'package:flutter_library/shared/widgets/rating_selector.dart';

/// Simple dialog for quickly rating a book without writing a review
class QuickRateDialog extends StatefulWidget {
  final String bookTitle;
  final double? currentRating;
  final Function(double rating) onRate;

  const QuickRateDialog({
    super.key,
    required this.bookTitle,
    this.currentRating,
    required this.onRate,
  });

  @override
  State<QuickRateDialog> createState() => _QuickRateDialogState();
}

class _QuickRateDialogState extends State<QuickRateDialog> {
  late double _selectedRating;

  @override
  void initState() {
    super.initState();
    _selectedRating = widget.currentRating ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      title: Row(
        children: [
          Icon(
            Icons.star,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, base: 12)),
          const Expanded(
            child: Text('Rate this Book'),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.bookTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, base: 24)),
          
          RatingSelector(
            rating: _selectedRating,
            onRatingChanged: (rating) {
              setState(() {
                _selectedRating = rating;
              });
            },
            size: 48,
          ),
          
          if (_selectedRating > 0) ...[
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, base: 16)),
            Text(
              '${_selectedRating.toStringAsFixed(1)} out of 5 stars',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
          
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, base: 16)),
          
          Container(
            padding: EdgeInsets.all(ResponsiveUtils.getResponsiveSpacing(context, base: 12)),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppConstants.smallPadding),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, base: 8)),
                Expanded(
                  child: Text(
                    'You can add a written review later if you want!',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedRating > 0 ? _handleRate : null,
          child: Text(widget.currentRating != null ? 'Update Rating' : 'Submit Rating'),
        ),
      ],
    );
  }

  void _handleRate() {
    if (_selectedRating > 0) {
      widget.onRate(_selectedRating);
      Navigator.of(context).pop();
    }
  }
}
