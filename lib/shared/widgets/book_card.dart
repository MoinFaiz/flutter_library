import 'package:flutter/material.dart';
import 'package:flutter_library/core/constants/app_constants.dart';
import 'package:flutter_library/core/theme/app_dimensions.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/shared/widgets/book_cover_image.dart';
import 'package:flutter_library/shared/widgets/book_genre_display.dart';
import 'package:flutter_library/shared/widgets/book_image_carousel.dart';
import 'package:flutter_library/shared/widgets/favorite_button.dart';
import 'package:flutter_library/shared/widgets/from_friend_button.dart';
import 'package:flutter_library/shared/widgets/default_book_placeholder.dart';
import 'package:flutter_library/shared/widgets/rating_display.dart';

/// Reusable book card widget for grid/list display
class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final bool showFavoriteButton;

  const BookCard({
    super.key,
    required this.book,
    this.onTap,
    this.onFavoriteToggle,
    this.showFavoriteButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(AppConstants.smallPadding),
      elevation: AppDimensions.elevationSm,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                        horizontal: 6,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surface
                            .withValues(alpha: 0.95),
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusMd),
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
            // Book details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.smallPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        book.title,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: AppDimensions.spaceXs),
                    Flexible(
                      child: Text(
                        book.author,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: AppDimensions.spaceXs),
                    Flexible(
                      child: BookGenreDisplay(
                        genres: book.genres,
                        maxGenres: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
