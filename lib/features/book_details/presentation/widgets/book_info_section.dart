import 'package:flutter/material.dart';
import 'package:flutter_library/core/constants/app_constants.dart';
import 'package:flutter_library/core/theme/app_dimensions.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/shared/widgets/rating_display.dart';

/// Widget displaying basic book information
class BookInfoSection extends StatelessWidget {
  final Book book;

  const BookInfoSection({
    super.key,
    required this.book,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            book.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          
          SizedBox(height: AppDimensions.spaceSm),
          
          // Author
          Text(
            'by ${book.author}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          
          SizedBox(height: AppDimensions.spaceMd),
          
          // Rating and year
          Row(
            children: [
              RatingDisplay(
                rating: book.rating,
                iconSize: 20,
              ),
              const Spacer(),
              Text(
                'Published ${book.publishedYear}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          
          SizedBox(height: AppDimensions.spaceMd),
          
          // Genres
          if (book.genres.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: book.genres.map((genre) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  ),
                  child: Text(
                    genre,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          
          SizedBox(height: AppDimensions.spaceMd),
          
          // Availability status
          Row(
            children: [
              Icon(
                _getAvailabilityIcon(),
                size: 16,
                color: _getAvailabilityColor(context),
              ),
              const SizedBox(width: 4),
              Text(
                book.availabilityStatus,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _getAvailabilityColor(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  IconData _getAvailabilityIcon() {
    if (book.isAvailableForRent || book.isAvailableForSale) {
      return Icons.check_circle;
    }
    return Icons.cancel;
  }
  
  Color _getAvailabilityColor(BuildContext context) {
    if (book.isAvailableForRent || book.isAvailableForSale) {
      return Theme.of(context).colorScheme.primary;
    }
    return Theme.of(context).colorScheme.error;
  }
}
