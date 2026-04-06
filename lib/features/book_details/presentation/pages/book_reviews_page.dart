import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_library/core/constants/app_constants.dart';
import 'package:flutter_library/core/theme/app_dimensions.dart';
import 'package:flutter_library/core/utils/helpers/responsive_utils.dart';
import 'package:flutter_library/features/cart/presentation/widgets/cart_icon_button_with_badge.dart';
import 'package:flutter_library/features/book_details/domain/entities/review.dart';
import 'package:flutter_library/features/book_details/presentation/pages/book_reviews_page_args.dart';
import 'package:flutter_library/shared/widgets/rating_display.dart';

/// Dedicated page for displaying all book reviews
class BookReviewsPage extends StatefulWidget {
  final BookReviewsPageArgs args;

  const BookReviewsPage({
    super.key,
    required this.args,
  });

  @override
  State<BookReviewsPage> createState() => _BookReviewsPageState();
}

class _BookReviewsPageState extends State<BookReviewsPage> {
  final _reviewController = TextEditingController();
  double _selectedRating = 0.0;
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _reviewController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Trigger load immediately when widget is created
    if (widget.args.reviews == null && widget.args.onLoadReviews != null) {
      widget.args.onLoadReviews!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.reviewsTitle),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: AppDimensions.elevationNone,
        scrolledUnderElevation: AppDimensions.elevationXs,
        actions: const [
          CartIconButtonWithBadge(),
        ],
      ),
      body: Column(
        children: [
          // Book header
          _buildBookHeader(),
          
          // Divider
          Divider(
            height: 1,
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
          
          // Reviews content
          Expanded(
            child: _buildReviewsContent(),
          ),
        ],
      ),
      // Floating action button for adding review
      floatingActionButton: widget.args.onAddReview != null
          ? FloatingActionButton.extended(
              onPressed: _showAddReviewDialog,
              icon: const Icon(Icons.rate_review),
              label: const Text(AppConstants.addReviewFabLabel),
            )
          : null,
    );
  }

  Widget _buildBookHeader() {
    final bookCoverSize = ResponsiveUtils.getResponsiveBookCoverSize(context);
    final spacing = ResponsiveUtils.getResponsiveSpacing(context);
    
    return Container(
      padding: ResponsiveUtils.getResponsivePadding(context),
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        children: [
          // Book cover
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.smallPadding),
            child: CachedNetworkImage(
              imageUrl: widget.args.book.primaryImageUrl,
              width: bookCoverSize.width,
              height: bookCoverSize.height,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: bookCoverSize.width,
                height: bookCoverSize.height,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                width: bookCoverSize.width,
                height: bookCoverSize.height,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppConstants.smallPadding),
                ),
                child: Icon(
                  Icons.book,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          
          SizedBox(width: spacing),
          
          // Book info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.args.book.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, base: 4)),
                Text(
                  widget.args.book.author,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, base: 8)),
                Row(
                  children: [
                    RatingDisplay(
                      rating: widget.args.book.rating,
                      iconSize: AppConstants.ratingSize,
                    ),
                    SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, base: 8)),
                    Text(
                      widget.args.book.rating.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsContent() {
    // Handle error state
    if (widget.args.error != null) {
      return _buildErrorWidget();
    }
    
    // Handle loading state
    if (widget.args.isLoading) {
      return _buildLoadingWidget();
    }
    
    // Handle not loaded state
    if (widget.args.reviews == null) {
      return _buildNotLoadedWidget();
    }
    
    // Handle loaded state
    return _buildReviewsList();
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: ResponsiveUtils.getResponsivePadding(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: ResponsiveUtils.getResponsiveSpacing(context, base: 64),
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context)),
            Text(
              AppConstants.failedToLoadReviewsTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, base: 8)),
            Text(
              widget.args.error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, base: 24)),
            ElevatedButton.icon(
              onPressed: widget.args.onLoadReviews,
              icon: const Icon(Icons.refresh),
              label: const Text(AppConstants.retryButtonText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildNotLoadedWidget() {
    return Center(
      child: Padding(
        padding: ResponsiveUtils.getResponsivePadding(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: ResponsiveUtils.getResponsiveSpacing(context, base: 64),
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context)),
            Text(
              AppConstants.loadReviewsTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, base: 8)),
            Text(
              AppConstants.loadReviewsSubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, base: 24)),
            ElevatedButton.icon(
              onPressed: widget.args.onLoadReviews,
              icon: const Icon(Icons.rate_review),
              label: const Text(AppConstants.loadReviewsButtonText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsList() {
    final reviewsList = widget.args.reviews ?? [];
    
    if (reviewsList.isEmpty) {
      return Center(
        child: Padding(
          padding: ResponsiveUtils.getResponsivePadding(context),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.rate_review_outlined,
                size: ResponsiveUtils.getResponsiveSpacing(context, base: 64),
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context)),
              Text(
                AppConstants.noReviewsYetTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, base: 8)),
              Text(
                AppConstants.noReviewsYetSubtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              if (widget.args.onAddReview != null) ...[
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, base: 24)),
                ElevatedButton.icon(
                  onPressed: _showAddReviewDialog,
                  icon: const Icon(Icons.add),
                  label: const Text(AppConstants.addFirstReviewButtonText),
                ),
              ],
            ],
          ),
        ),
      );
    }
    
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Reviews summary
        SliverToBoxAdapter(
          child: Container(
            margin: ResponsiveUtils.getResponsivePadding(context),
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
                      widget.args.book.rating.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    RatingDisplay(
                      rating: widget.args.book.rating,
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
        ),
        
        // Individual reviews
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final review = reviewsList[index];
              final horizontalPadding = ResponsiveUtils.getResponsiveHorizontalPadding(context);
              return Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding.left,
                  0,
                  horizontalPadding.right,
                  index == reviewsList.length - 1 
                      ? ResponsiveUtils.getResponsiveSpacing(context) 
                      : ResponsiveUtils.getResponsiveSpacing(context, base: 8),
                ),
                child: _buildReviewItem(review),
              );
            },
            childCount: reviewsList.length,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewItem(Review review) {
    final avatarRadius = ResponsiveUtils.getResponsiveAvatarRadius(context);
    final spacing = ResponsiveUtils.getResponsiveSpacing(context);
    
    return Container(
      padding: EdgeInsets.all(spacing),
      margin: EdgeInsets.only(bottom: ResponsiveUtils.getResponsiveSpacing(context, base: 8)),
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
                radius: avatarRadius,
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

  void _showAddReviewDialog() {
    final modalSizes = ResponsiveUtils.getResponsiveModalSizes(context);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: modalSizes['initial']!,
        maxChildSize: modalSizes['max']!,
        minChildSize: modalSizes['min']!,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(ResponsiveUtils.getResponsiveSpacing(context, base: 20)),
              topRight: Radius.circular(ResponsiveUtils.getResponsiveSpacing(context, base: 20)),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: EdgeInsets.symmetric(
                  vertical: ResponsiveUtils.getResponsiveSpacing(context, base: 12),
                ),
                width: AppConstants.reviewModalHandleWidth,
                height: AppConstants.reviewModalHandleHeight,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
                ),
              ),
              
              // Header
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.getResponsiveSpacing(context, base: 20),
                ),
                child: Row(
                  children: [
                    Text(
                      AppConstants.addYourReviewTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.all(ResponsiveUtils.getResponsiveSpacing(context, base: 20)),
                  child: _buildAddReviewForm(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddReviewForm() {
    final starSize = ResponsiveUtils.getResponsiveStarSize(context);
    final spacing = ResponsiveUtils.getResponsiveSpacing(context);
    final textFieldLines = ResponsiveUtils.getResponsiveTextFieldLines(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rating selector
        Text(
          AppConstants.ratingLabel,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, base: 12)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final starValue = index + 1.0;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedRating = starValue;
                });
              },
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.getResponsiveSpacing(context, base: AppConstants.reviewFormStarPadding),
                ),
                child: Icon(
                  starValue <= _selectedRating 
                      ? Icons.star 
                      : Icons.star_border,
                  size: starSize,
                  color: starValue <= _selectedRating 
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                ),
              ),
            );
          }),
        ),
        
        SizedBox(height: spacing * 1.5),
        
        // Review text
        Text(
          AppConstants.reviewLabel,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, base: 12)),
        TextField(
          controller: _reviewController,
          maxLines: textFieldLines,
          decoration: InputDecoration(
            hintText: AppConstants.reviewHintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
        ),
        
        SizedBox(height: spacing * 1.5),
        
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
              padding: EdgeInsets.symmetric(vertical: spacing),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _submitReview() {
    if (_selectedRating > 0 && _reviewController.text.isNotEmpty) {
      widget.args.onAddReview?.call(_reviewController.text, _selectedRating);
      setState(() {
        _reviewController.clear();
        _selectedRating = 0.0;
      });
      
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(AppConstants.reviewSubmittedMessage),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
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
}
