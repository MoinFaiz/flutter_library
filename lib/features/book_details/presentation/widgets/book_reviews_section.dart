import 'package:flutter/material.dart';
import 'package:flutter_library/core/constants/app_constants.dart';
import 'package:flutter_library/core/navigation/app_routes.dart';
import 'package:flutter_library/core/utils/helpers/responsive_utils.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/book_details/domain/entities/review.dart';
import 'package:flutter_library/features/book_details/presentation/pages/book_reviews_page_args.dart';
import 'package:flutter_library/shared/widgets/rating_display.dart';

/// Widget displaying book reviews preview with option to view all reviews
class BookReviewsSection extends StatefulWidget {
  final Book book;
  final List<Review>? reviews; // Made nullable for distributed loading
  final bool isLoading;
  final String? error;
  final Function(String reviewText, double rating)? onAddReview;
  final VoidCallback? onLoadReviews;
  final int maxPreviewReviews; // Number of reviews to show in preview

  const BookReviewsSection({
    super.key,
    required this.book,
    this.reviews,
    this.isLoading = false,
    this.error,
    this.onAddReview,
    this.onLoadReviews,
    this.maxPreviewReviews = AppConstants.defaultMaxPreviewReviews, // Use constant
  });

  @override
  State<BookReviewsSection> createState() => _BookReviewsSectionState();
}

class _BookReviewsSectionState extends State<BookReviewsSection> {
  final _reviewController = TextEditingController();
  double _selectedRating = 0.0;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Trigger load immediately when widget is created
    if (widget.reviews == null && widget.onLoadReviews != null) {
      widget.onLoadReviews!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: ResponsiveUtils.getResponsiveHorizontalPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppConstants.reviewsTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context)),
          
          // Add review section
          if (widget.onAddReview != null) ...[
            _buildAddReviewSection(context),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, base: 24)),
          ],
          
          // Reviews content with distributed loading
          _buildReviewsContent(),
        ],
      ),
    );
  }

  Widget _buildReviewsContent() {
    // Handle error state
    if (widget.error != null) {
      return _buildErrorWidget();
    }
    
    // Handle loading state
    if (widget.isLoading) {
      return _buildLoadingWidget();
    }
    
    // Handle not loaded state
    if (widget.reviews == null) {
      return _buildNotLoadedWidget();
    }
    
    // Handle loaded state
    return _buildReviewsList(context);
  }

  Widget _buildErrorWidget() {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.getResponsiveSpacing(context)),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
            size: ResponsiveUtils.getResponsiveSpacing(context, base: 48),
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, base: 8)),
          Text(
            AppConstants.failedToLoadReviewsTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, base: 4)),
          Text(
            widget.error!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context)),
          ElevatedButton(
            onPressed: widget.onLoadReviews,
            child: const Text(AppConstants.retryButtonText),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.getResponsiveSpacing(context, base: 32)),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildNotLoadedWidget() {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.getResponsiveSpacing(context)),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: ResponsiveUtils.getResponsiveSpacing(context, base: 48),
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, base: 8)),
          Text(
            AppConstants.loadReviewsTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, base: 4)),
          Text(
            AppConstants.loadReviewsSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context)),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.onLoadReviews,
                  child: const Text(AppConstants.loadReviewsButtonText),
                ),
              ),
              SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, base: 8)),
              Expanded(
                child: OutlinedButton(
                  onPressed: _navigateToAllReviews,
                  child: const Text(AppConstants.viewAllReviewsButtonText),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildAddReviewSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.getResponsiveSpacing(context)),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppConstants.addYourReviewTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context)),
          
          // Rating selector
          Text(
            AppConstants.ratingLabel,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, base: 8)),
          Row(
            children: List.generate(5, (index) {
              final starValue = index + 1.0;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedRating = starValue;
                  });
                },
                child: Padding(
                  padding: EdgeInsets.only(right: ResponsiveUtils.getResponsiveSpacing(context, base: 4)),
                  child: Icon(
                    starValue <= _selectedRating 
                        ? Icons.star 
                        : Icons.star_border,
                    size: ResponsiveUtils.getResponsiveSpacing(context, base: 32),
                    color: starValue <= _selectedRating 
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                  ),
                ),
              );
            }),
          ),
          
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context)),
          
          // Review text
          TextField(
            controller: _reviewController,
            maxLines: ResponsiveUtils.getResponsiveTextFieldLines(context) ~/ 2, // Half the lines for preview
            decoration: InputDecoration(
              hintText: AppConstants.reviewHintText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.smallPadding),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
          ),
          
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context)),
          
          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _selectedRating > 0 && _reviewController.text.isNotEmpty
                  ? _submitReview
                  : null,
              icon: const Icon(Icons.send),
              label: const Text(AppConstants.submitReviewButtonText),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: ResponsiveUtils.getResponsiveSpacing(context, base: 12)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.smallPadding),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildReviewsList(BuildContext context) {
    final reviewsList = widget.reviews ?? [];
    
    if (reviewsList.isEmpty) {
      return Container(
        padding: EdgeInsets.all(ResponsiveUtils.getResponsiveSpacing(context)),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        child: Row(
          children: [
            Icon(
              Icons.rate_review_outlined,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, base: 12)),
            Expanded(
              child: Text(
                AppConstants.noReviewsYetSubtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    // Show only preview reviews
    final previewReviews = reviewsList.take(widget.maxPreviewReviews).toList();
    final hasMoreReviews = reviewsList.length > widget.maxPreviewReviews;
    
    return Column(
      children: [
        // Reviews summary
        Container(
          padding: EdgeInsets.all(ResponsiveUtils.getResponsiveSpacing(context)),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.book.rating.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  RatingDisplay(
                    rating: widget.book.rating,
                    iconSize: ResponsiveUtils.getResponsiveSpacing(context, base: 20),
                    iconColor: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ],
              ),
              SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context)),
              Expanded(
                child: Text(
                  '${AppConstants.basedOnReviewsText} ${reviewsList.length} ${reviewsList.length == 1 ? AppConstants.reviewSingular : AppConstants.reviewPlural}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context)),
        
        // Preview reviews
        ...previewReviews.map((review) => Padding(
          padding: EdgeInsets.only(bottom: ResponsiveUtils.getResponsiveSpacing(context)),
          child: _buildReviewItem(context, review),
        )),
        
        // View all reviews button
        if (hasMoreReviews || reviewsList.isNotEmpty) ...[
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, base: 8)),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _navigateToAllReviews,
              icon: const Icon(Icons.reviews),
              label: Text(
                hasMoreReviews 
                    ? '${AppConstants.viewAllReviewsButtonText} ${reviewsList.length} ${AppConstants.reviewPlural}'
                    : AppConstants.viewAllReviewsButtonText,
              ),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: ResponsiveUtils.getResponsiveSpacing(context, base: 12)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.smallPadding),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildReviewItem(BuildContext context, Review review) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.getResponsiveSpacing(context)),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: ResponsiveUtils.getResponsiveAvatarRadius(context),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  review.userName[0].toUpperCase(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, base: 12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, base: 4)),
                    Row(
                      children: [
                        RatingDisplay(
                          rating: review.rating,
                          iconSize: AppConstants.ratingSize,
                        ),
                        SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, base: 8)),
                        Text(
                          _formatDate(review.createdAt),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, base: 12)),
          
          Text(
            review.reviewText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
  
  void _submitReview() {
    if (_selectedRating > 0 && _reviewController.text.isNotEmpty) {
      widget.onAddReview?.call(_reviewController.text, _selectedRating);
      setState(() {
        _reviewController.clear();
        _selectedRating = 0.0;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(AppConstants.reviewSubmittedMessage),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.smallPadding),
          ),
        ),
      );
    }
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return AppConstants.todayText;
    } else if (difference.inDays == 1) {
      return AppConstants.yesterdayText;
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${AppConstants.daysAgoSuffix}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
  
  void _navigateToAllReviews() {
    final args = BookReviewsPageArgs(
      book: widget.book,
      reviews: widget.reviews,
      isLoading: widget.isLoading,
      error: widget.error,
      onAddReview: widget.onAddReview,
      onLoadReviews: widget.onLoadReviews,
    );
    
    Navigator.pushNamed(
      context,
      AppRoutes.bookReviews,
      arguments: args,
    );
  }
}


