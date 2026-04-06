import 'package:flutter/material.dart';
import 'package:flutter_library/core/constants/app_constants.dart';
import 'package:flutter_library/core/theme/app_colors.dart';
import 'package:flutter_library/core/theme/app_dimensions.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/shared/widgets/book_cover_image.dart';
import 'package:flutter_library/shared/widgets/book_genre_display.dart';
import 'package:flutter_library/shared/widgets/book_image_carousel.dart';
import 'package:flutter_library/shared/widgets/favorite_button.dart';
import 'package:flutter_library/shared/widgets/default_book_placeholder.dart';
import 'package:flutter_library/shared/widgets/rating_display.dart';

/// Enhanced book detail widget for detailed views
class BookDetailCard extends StatelessWidget {
  final Book book;
  final VoidCallback? onFavoriteToggle;
  final bool showFavoriteButton;

  const BookDetailCard({
    super.key,
    required this.book,
    this.onFavoriteToggle,
    this.showFavoriteButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      elevation: AppDimensions.elevationMd,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Large image carousel
          SizedBox(
            height: AppDimensions.bookDetailImageHeight,
            child: Stack(
              children: [
                book.hasAnyImages
                    ? (book.hasMultipleImages
                        ? BookImageCarousel(
                            imageUrls: book.imageUrls,
                            width: double.infinity,
                            height: AppDimensions.bookDetailImageHeight,
                            showIndicators: true,
                          )
                        : BookCoverImage(
                            imageUrl: book.primaryImageUrl,
                            width: double.infinity,
                            height: AppDimensions.bookDetailImageHeight,
                          ))
                    : DefaultBookPlaceholder(
                        width: double.infinity,
                        height: AppDimensions.bookDetailImageHeight,
                      ),
                if (showFavoriteButton)
                  Positioned(
                    top: AppConstants.defaultPadding,
                    right: AppConstants.defaultPadding,
                    child: FavoriteButton(
                      isFavorite: book.isFavorite,
                      onPressed: onFavoriteToggle,
                      iconSize: AppDimensions.iconMd,
                      showBackground: true,
                    ),
                  ),
              ],
            ),
          ),
          // Book information
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppDimensions.spaceSm),
                Text(
                  'by ${book.author}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
                const SizedBox(height: AppDimensions.spaceSm),
                // Genres as chips
                BookGenreDisplay(
                  genres: book.genres,
                  showAsChips: true,
                ),
                const SizedBox(height: AppDimensions.spaceSmPlus),
                // Rating and availability
                Row(
                  children: [
                    RatingDisplay(rating: book.rating),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spaceSm,
                        vertical: AppDimensions.spaceXs,
                      ),
                      decoration: BoxDecoration(
                        color: book.isAvailableForRent || book.isAvailableForSale
                            ? AppColors.success.withValues(alpha: 0.1)
                            : Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                        border: Border.all(
                          color: book.isAvailableForRent || book.isAvailableForSale
                              ? AppColors.success
                              : Theme.of(context).colorScheme.error,
                          width: AppDimensions.dividerThin,
                        ),
                      ),
                      child: Text(
                        book.availabilityStatus,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: book.isAvailableForRent || book.isAvailableForSale
                                  ? AppColors.success
                                  : Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spaceSm + AppDimensions.spaceXs),
                // Description
                Text(
                  book.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimensions.spaceMd),
                // Pricing information
                if (book.isAvailableForSale || book.isAvailableForRent)
                  Row(
                    children: [
                      if (book.isAvailableForSale) ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Buy',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            Text(
                              '\$${book.salePrice.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                          ],
                        ),
                        if (book.isAvailableForRent) const SizedBox(width: 32),
                      ],
                      if (book.isAvailableForRent) ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rent',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            Text(
                              '\$${book.rentPrice.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
