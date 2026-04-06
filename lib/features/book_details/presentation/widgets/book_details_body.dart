import 'package:flutter/material.dart';
import 'package:flutter_library/core/theme/app_dimensions.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/book_details/domain/entities/review.dart';
import 'package:flutter_library/features/book_details/domain/entities/rental_status.dart';
import 'package:flutter_library/features/book_details/presentation/widgets/book_info_section.dart';
import 'package:flutter_library/features/book_details/presentation/widgets/book_pricing_section.dart';
import 'package:flutter_library/features/book_details/presentation/widgets/book_actions_section.dart';
import 'package:flutter_library/features/book_details/presentation/widgets/book_rental_status_section.dart';
import 'package:flutter_library/features/book_details/presentation/widgets/book_description_section.dart';
import 'package:flutter_library/features/book_details/presentation/widgets/book_reviews_section.dart';

/// Main body content for book details page
class BookDetailsBody extends StatelessWidget {
  final Book book;
  final List<Review>? reviews; // Made nullable for distributed loading
  final RentalStatus? rentalStatus;
  final bool isPerformingAction;
  final bool isLoadingReviews;
  final bool isLoadingRentalStatus;
  final String? reviewsError;
  final String? rentalStatusError;
  final VoidCallback? onRent;
  final VoidCallback? onBuy;
  final VoidCallback? onReturn;
  final VoidCallback? onRenew;
  final VoidCallback? onRemoveFromCart;
  final Function(String reviewText, double rating)? onAddReview;
  final VoidCallback? onLoadReviews;
  final VoidCallback? onLoadRentalStatus;

  const BookDetailsBody({
    super.key,
    required this.book,
    this.reviews,
    this.rentalStatus,
    required this.isPerformingAction,
    this.isLoadingReviews = false,
    this.isLoadingRentalStatus = false,
    this.reviewsError,
    this.rentalStatusError,
    this.onRent,
    this.onBuy,
    this.onReturn,
    this.onRenew,
    this.onRemoveFromCart,
    this.onAddReview,
    this.onLoadReviews,
    this.onLoadRentalStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book basic info (title, author, rating, genre)
          BookInfoSection(book: book),
          
          const Divider(height: 32),
          
          // Pricing information
          BookPricingSection(book: book),
          
          const Divider(height: 32),
          
          // Rental status (if applicable)
          BookRentalStatusSection(
            book: book,
            rentalStatus: rentalStatus,
            isLoading: isLoadingRentalStatus,
            error: rentalStatusError,
            onLoadRentalStatus: onLoadRentalStatus,
          ),
          
          // Action buttons (rent, buy, return, etc.) - only show when rental status is loaded
          if (!isLoadingRentalStatus && (rentalStatus != null || rentalStatusError != null)) ...[
            const Divider(height: 32),
            BookActionsSection(
              book: book,
              rentalStatus: rentalStatus,
              isPerformingAction: isPerformingAction,
              onRent: onRent,
              onBuy: onBuy,
              onReturn: onReturn,
              onRenew: onRenew,
            ),
          ],
          
          const Divider(height: 32),
          
          // Description
          BookDescriptionSection(book: book),
          
          const Divider(height: 32),
          
          // Reviews
          BookReviewsSection(
            book: book,
            reviews: reviews,
            isLoading: isLoadingReviews,
            error: reviewsError,
            onAddReview: onAddReview,
            onLoadReviews: onLoadReviews,
          ),
          
          // Bottom padding
          SizedBox(height: AppDimensions.space2Xl),
        ],
      ),
    );
  }
}
