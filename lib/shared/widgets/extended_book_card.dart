import 'package:flutter/material.dart';
import 'package:flutter_library/core/constants/app_constants.dart';
import 'package:flutter_library/core/theme/app_dimensions.dart';
import 'package:flutter_library/core/theme/app_typography.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/shared/widgets/book_cover_image.dart';
import 'package:flutter_library/shared/widgets/book_genre_display.dart';
import 'package:flutter_library/shared/widgets/book_image_carousel.dart';
import 'package:flutter_library/shared/widgets/favorite_button.dart';
import 'package:flutter_library/shared/widgets/from_friend_button.dart';
import 'package:flutter_library/shared/widgets/default_book_placeholder.dart';
import 'package:flutter_library/shared/widgets/rating_display.dart';

/// Extended book card with pricing and availability information
/// Used in home page and favorites page
class ExtendedBookCard extends StatelessWidget {
  final Book book;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final bool showFavoriteButton;
  final double? width;
  final double? height;

  const ExtendedBookCard({
    super.key,
    required this.book,
    this.onTap,
    this.onFavoriteToggle,
    this.showFavoriteButton = true,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(AppConstants.smallPadding),
      elevation: AppDimensions.elevationSm,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: width,
          height: height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book cover image section
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    // Book cover image with carousel support
                    book.hasAnyImages
                        ? (book.hasMultipleImages
                            ? BookImageCarousel(
                                imageUrls: book.imageUrls,
                                width: double.infinity,
                              )
                            : BookCoverImage(
                                imageUrl: book.primaryImageUrl,
                                width: double.infinity,
                              ))
                        : DefaultBookPlaceholder(
                            width: double.infinity,
                          ),
                    
                    // From friend button at top left
                    if (book.isFromFriend)
                      Positioned(
                        top: AppConstants.smallPadding,
                        left: AppConstants.smallPadding,
                        child: FromFriendButton(
                          iconSize: AppDimensions.iconXs,
                          showBackground: true,
                        ),
                      ),
                    
                    // Favorite button at top right
                    if (showFavoriteButton)
                      Positioned(
                        top: AppConstants.smallPadding,
                        right: AppConstants.smallPadding,
                        child: FavoriteButton(
                          isFavorite: book.isFavorite,
                          onPressed: onFavoriteToggle,
                          iconSize: AppDimensions.iconXs,
                          showBackground: true,
                        ),
                      ),
                    
                    // Rating badge at bottom left
                    Positioned(
                      bottom: AppConstants.smallPadding,
                      left: AppConstants.smallPadding,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spaceXs + 2,
                          vertical: AppDimensions.spaceXs,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                        ),
                        child: RatingDisplay(
                          rating: book.rating,
                          iconSize: AppDimensions.iconXs - 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Book details section
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.smallPadding),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Title
                            Text(
                              book.title,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: AppTypography.fontSizeSm,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: AppDimensions.spaceXs),
                            
                            // Author
                            Text(
                              book.author,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.outline,
                                    fontSize: AppTypography.fontSizeXs,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: AppDimensions.spaceXs),
                            
                            // Genres
                            BookGenreDisplay(
                              genres: book.genres,
                              maxGenres: 2,
                            ),
                            
                            SizedBox(height: AppDimensions.spaceSm),
                            
                            // Availability counts
                            _buildAvailabilityCounts(context),
                            
                            SizedBox(height: AppDimensions.spaceXs),
                            
                            // Pricing information
                            if (book.availability.hasRentAvailable)
                              _buildRentPricing(context),
                            
                            if (book.availability.hasSaleAvailable)
                              Padding(
                                padding: EdgeInsets.only(
                                  top: book.availability.hasRentAvailable ? 2 : 0,
                                ),
                                child: _buildSalePricing(context),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvailabilityCounts(BuildContext context) {
    return Row(
      children: [
        // Rent availability
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.schedule,
              size: AppDimensions.iconXs,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(width: AppDimensions.spaceXs),
            Text(
              '${book.availability.availableForRentCount}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
        
        const SizedBox(width: AppDimensions.spaceLayout),
        
        // Sale availability
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_cart,
              size: AppDimensions.iconXs,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(width: AppDimensions.spaceXs),
            Text(
              '${book.availability.availableForSaleCount}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRentPricing(BuildContext context) {
    final discount = book.pricing.percentageDiscountForRent ?? 
                     book.pricing.rentDiscountPercentage;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Rent ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: AppTypography.fontSizeXs,
          ),
        ),
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (book.pricing.hasRentDiscount)
                Text(
                  '\$${book.pricing.discountedRentPrice!.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: AppTypography.fontSizeXs,
                  ),
                  overflow: TextOverflow.ellipsis,
                )
              else
                Text(
                  '\$${book.pricing.rentPrice.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: AppTypography.fontSizeXs,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              if (book.pricing.hasRentDiscount) ...[
                const SizedBox(width: AppDimensions.spaceXxs),
                Text(
                  '\$${book.pricing.rentPrice.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: AppTypography.fontSizeXs,
                    decoration: TextDecoration.lineThrough,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  overflow: TextOverflow.clip,
                ),
              ],
            ],
          ),
        ),
        if (book.pricing.hasRentDiscount) ...[
          const SizedBox(width: AppDimensions.spaceXs - 1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spaceXs - 1, vertical: 1),
            decoration: BoxDecoration(
              color: const Color(0xFFFF4785),
              borderRadius: BorderRadius.circular(AppDimensions.radiusXs - 1),
            ),
            child: Text(
              '${discount.toStringAsFixed(0)}%',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: AppTypography.fontSizeXs,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSalePricing(BuildContext context) {
    final minPrice = book.pricing.minimumCostToBuy;
    final maxPrice = book.pricing.maximumCostToBuy;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Buy ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: AppTypography.fontSizeXs,
          ),
        ),
        Expanded(
          child: minPrice != null && maxPrice != null && minPrice != maxPrice
              ? Text(
                  '\$${minPrice.toStringAsFixed(0)}-\$${maxPrice.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: AppTypography.fontSizeXs,
                  ),
                  overflow: TextOverflow.ellipsis,
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (book.pricing.hasSaleDiscount)
                      Text(
                        '\$${book.pricing.discountedSalePrice!.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: AppTypography.fontSizeXs,
                        ),
                        overflow: TextOverflow.ellipsis,
                      )
                    else
                      Text(
                        '\$${book.pricing.salePrice.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: AppTypography.fontSizeXs,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (book.pricing.hasSaleDiscount) ...[
                      const SizedBox(width: AppDimensions.spaceXxs),
                      Text(
                        '\$${book.pricing.salePrice.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: AppTypography.fontSizeXs,
                          decoration: TextDecoration.lineThrough,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        overflow: TextOverflow.clip,
                      ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}
