import 'package:flutter/material.dart';
import 'package:flutter_library/core/theme/app_dimensions.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/book_details/presentation/widgets/book_image_carousel.dart';

/// Custom app bar for book details page with image carousel
///
/// This uses SliverAppBar instead of standard AppBar because:
/// 1. It provides an expandable/collapsible app bar with image carousel
/// 2. It integrates with CustomScrollView for smooth scrolling effects
/// 3. It creates a visually rich book detail experience
///
/// For all other pages, use standard AppBar for consistency
class BookDetailsAppBar extends StatelessWidget {
  final Book book;
  final VoidCallback onBack;
  final VoidCallback? onFavoriteToggle;

  const BookDetailsAppBar({
    super.key,
    required this.book,
    required this.onBack,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(AppDimensions.spaceSm),
          decoration: BoxDecoration(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        onPressed: onBack,
      ),
      actions: [
        if (onFavoriteToggle != null)
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(AppDimensions.spaceSm),
              decoration: BoxDecoration(
                color: Theme.of(context).shadowColor.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                book.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: book.isFavorite ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            onPressed: onFavoriteToggle,
          ),
        if (book.isFromFriend)
          Padding(
            padding: const EdgeInsets.only(right: AppDimensions.spaceSm),
            child: Container(
              padding: const EdgeInsets.all(AppDimensions.spaceSm),
              decoration: BoxDecoration(
                color: Theme.of(context).shadowColor.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: BookImageCarousel(
          imageUrls: book.imageUrls,
          heroTag: 'book-${book.id}',
        ),
      ),
    );
  }
}
