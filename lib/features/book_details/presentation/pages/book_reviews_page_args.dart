import 'package:flutter/material.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/book_details/domain/entities/review.dart';

/// Data class for passing arguments to the book reviews page
class BookReviewsPageArgs {
  final Book book;
  final List<Review>? reviews;
  final bool isLoading;
  final String? error;
  final Function(String reviewText, double rating)? onAddReview;
  final VoidCallback? onLoadReviews;

  const BookReviewsPageArgs({
    required this.book,
    this.reviews,
    this.isLoading = false,
    this.error,
    this.onAddReview,
    this.onLoadReviews,
  });
}
