import 'package:equatable/equatable.dart';

/// Book rating entity for users who rate without writing a review
class BookRating extends Equatable {
  final String id;
  final String bookId;
  final String userId;
  final double rating;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BookRating({
    required this.id,
    required this.bookId,
    required this.userId,
    required this.rating,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Validate rating value
  bool get isValidRating => rating >= 0.0 && rating <= 5.0;

  BookRating copyWith({
    String? id,
    String? bookId,
    String? userId,
    double? rating,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookRating(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      userId: userId ?? this.userId,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    bookId,
    userId,
    rating,
    createdAt,
    updatedAt,
  ];
}
