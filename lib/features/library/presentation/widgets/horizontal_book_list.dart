import 'package:flutter/material.dart';
import 'package:flutter_library/core/constants/app_constants.dart';
import 'package:flutter_library/core/theme/app_dimensions.dart';
import 'package:flutter_library/core/utils/helpers/ui_utils.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/shared/widgets/book_card.dart';

/// Horizontal book list widget with max 5 items and "More" button
class HorizontalBookList extends StatelessWidget {
  final String title;
  final List<Book> books;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onMoreTapped;
  final Function(Book)? onBookTapped;
  final bool showMoreButton;

  const HorizontalBookList({
    super.key,
    required this.title,
    required this.books,
    this.isLoading = false,
    this.errorMessage,
    this.onMoreTapped,
    this.onBookTapped,
    this.showMoreButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (showMoreButton && books.length >= 5 && onMoreTapped != null)
                TextButton.icon(
                  onPressed: onMoreTapped,
                  icon: const Icon(Icons.arrow_forward, size: AppDimensions.iconXs),
                  label: const Text(AppConstants.moreButton),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
            ],
          ),
        ),
        
        // Book list - let it size naturally based on card children
        _buildBookList(context),
      ],
    );
  }

  Widget _buildBookList(BuildContext context) {
    if (isLoading) {
      return _buildLoadingList(context);
    }

    if (errorMessage != null) {
      return _buildErrorState(context);
    }

    if (books.isEmpty) {
      return _buildEmptyState(context);
    }

    final availableWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = UIUtils.getHorizontalBookCardWidthFromWidth(availableWidth);
    final cardHeight = UIUtils.getHorizontalBookCardHeightFromWidth(cardWidth);
    
    return SizedBox(
      height: cardHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return _buildBookItem(context, book);
        },
      ),
    );
  }

  Widget _buildBookItem(BuildContext context, Book book) {
    final availableWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = UIUtils.getHorizontalBookCardWidthFromWidth(availableWidth);
    
    return SizedBox(
      width: cardWidth,
      child: Container(
        margin: const EdgeInsets.only(right: AppConstants.defaultPadding),
        child: BookCard(
          book: book,
          onTap: () => onBookTapped?.call(book),
          showFavoriteButton: false, // Don't show favorite button in library horizontal lists
        ),
      ),
    );
  }

  Widget _buildLoadingList(BuildContext context) {
    final availableWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = UIUtils.getHorizontalBookCardWidthFromWidth(availableWidth);
    final cardHeight = UIUtils.getHorizontalBookCardHeightFromWidth(cardWidth);
    
    return SizedBox(
      height: cardHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
        itemCount: 3, // Show 3 loading placeholders
        itemBuilder: (context, index) {
          return SizedBox(
            width: cardWidth,
            child: Container(
              margin: const EdgeInsets.only(right: AppConstants.defaultPadding),
              child: Card(
                margin: const EdgeInsets.all(AppConstants.smallPadding),
                elevation: AppDimensions.elevationSm,
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        width: double.infinity,
                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(AppConstants.smallPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            UIUtils.createSkeletonContainer(
                              context,
                              height: AppConstants.skeletonTitleHeight,
                              width: double.infinity,
                            ),
                            SizedBox(height: AppDimensions.spaceXs),
                            UIUtils.createSkeletonContainer(
                              context,
                              height: AppConstants.skeletonSubtitleHeight,
                              width: cardWidth * 0.65,
                            ),
                            const Spacer(),
                            UIUtils.createSkeletonContainer(
                              context,
                              height: AppConstants.skeletonRatingHeight,
                              width: cardWidth * 0.5,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: AppConstants.iconSize * 2,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            AppConstants.errorLoadingBooksMessage,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppDimensions.spaceXs),
          Text(
            errorMessage!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_books_outlined,
            size: AppConstants.iconSize * 2,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            AppConstants.noBooksYetTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppDimensions.spaceXs),
          Text(
            title.toLowerCase().contains('borrowed') 
                ? AppConstants.noBorrowedBooksMessage
                : AppConstants.noUploadedBooksMessage,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
