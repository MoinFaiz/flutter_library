import 'package:flutter/material.dart';
import 'package:flutter_library/core/constants/app_constants.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/shared/widgets/book_cover_image.dart';
import 'package:flutter_library/shared/widgets/book_genre_display.dart';
import 'package:flutter_library/shared/widgets/favorite_button.dart';
import 'package:flutter_library/shared/widgets/rating_display.dart';

/// Book list item for use in lists
class BookListItem extends StatelessWidget {
  final Book book;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final bool showFavoriteButton;

  const BookListItem({
    super.key,
    required this.book,
    this.onTap,
    this.onFavoriteToggle,
    this.showFavoriteButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding,
      ),
      child: ListTile(
        isThreeLine: true,
        leading: SizedBox(
          width: 42,
          height: 56,
          child: BookCoverImage(
            imageUrl: book.primaryImageUrl,
            width: 42,
            height: 56,
          ),
        ),
        title: Text(
          book.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(book.author),
            const SizedBox(height: 2),
            BookGenreDisplay(
              genres: book.genres,
              maxGenres: 3,
            ),
            const SizedBox(height: 4),
            RatingDisplay(rating: book.rating),
          ],
        ),
        trailing: showFavoriteButton
            ? FavoriteButton(
                isFavorite: book.isFavorite,
                onPressed: onFavoriteToggle,
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}
