import 'package:flutter/material.dart';
import 'package:flutter_library/core/constants/app_constants.dart';
import 'package:flutter_library/core/theme/app_colors.dart';
import 'package:flutter_library/core/utils/helpers/responsive_utils.dart';
import 'package:flutter_library/features/book_details/domain/entities/review.dart';

/// Dialog for writing or editing a review
class WriteReviewDialog extends StatefulWidget {
  final String bookTitle;
  final Review? existingReview;
  final Function(String reviewText, double rating) onSubmit;

  const WriteReviewDialog({
    super.key,
    required this.bookTitle,
    this.existingReview,
    required this.onSubmit,
  });

  @override
  State<WriteReviewDialog> createState() => _WriteReviewDialogState();
}

class _WriteReviewDialogState extends State<WriteReviewDialog> {
  late final TextEditingController _reviewController;
  late double _selectedRating;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _reviewController = TextEditingController(
      text: widget.existingReview?.reviewText ?? '',
    );
    _selectedRating = widget.existingReview?.rating ?? 0.0;
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.existingReview != null;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: EdgeInsets.all(ResponsiveUtils.getResponsiveSpacing(context, base: 20)),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, base: 20)),
                _buildRatingSelector(context),
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, base: 20)),
                _buildReviewTextField(context),
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, base: 24)),
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.rate_review,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
            SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, base: 12)),
            Expanded(
              child: Text(
                _isEditing ? 'Edit Your Review' : 'Write a Review',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Close',
            ),
          ],
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, base: 8)),
        Text(
          widget.bookTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildRatingSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Rating *',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, base: 12)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final starValue = index + 1.0;
            final halfStarValue = index + 0.5;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (_selectedRating == starValue) {
                    // If clicking the same star, set to half star
                    _selectedRating = halfStarValue;
                  } else {
                    _selectedRating = starValue;
                  }
                });
              },
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.getResponsiveSpacing(context, base: 4),
                ),
                child: Icon(
                  _getStarIcon(starValue, halfStarValue),
                  size: 48,
                  color: starValue <= _selectedRating || halfStarValue == _selectedRating
                      ? AppColors.ratingColor
                      : Theme.of(context).colorScheme.outline,
                ),
              ),
            );
          }),
        ),
        if (_selectedRating > 0) ...[
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, base: 8)),
          Center(
            child: Text(
              '${_selectedRating.toStringAsFixed(1)} out of 5 stars',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        ],
      ],
    );
  }

  IconData _getStarIcon(double starValue, double halfStarValue) {
    if (halfStarValue == _selectedRating) {
      return Icons.star_half;
    } else if (starValue <= _selectedRating) {
      return Icons.star;
    } else {
      return Icons.star_border;
    }
  }

  Widget _buildReviewTextField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Review *',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, base: 8)),
        TextFormField(
          controller: _reviewController,
          maxLines: 8,
          maxLength: 500,
          decoration: InputDecoration(
            hintText: 'Share your thoughts about this book...\n\nWhat did you like? What didn\'t you like? Would you recommend it?',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.smallPadding),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            counterText: '${_reviewController.text.length}/500',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please write your review';
            }
            if (value.trim().length < 10) {
              return 'Review must be at least 10 characters long';
            }
            return null;
          },
          onChanged: (value) {
            setState(() {}); // Update counter
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.smallPadding),
              ),
            ),
            child: const Text('Cancel'),
          ),
        ),
        SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, base: 12)),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: _handleSubmit,
            icon: Icon(_isEditing ? Icons.save : Icons.send),
            label: Text(_isEditing ? 'Update Review' : 'Submit Review'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.smallPadding),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedRating == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a rating'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      widget.onSubmit(_reviewController.text.trim(), _selectedRating);
      Navigator.of(context).pop();
    }
  }
}
