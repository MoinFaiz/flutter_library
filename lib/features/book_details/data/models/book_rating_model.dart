import 'package:flutter_library/features/book_details/domain/entities/book_rating.dart';

/// Data model for book rating
class BookRatingModel extends BookRating {
  const BookRatingModel({
    required super.id,
    required super.bookId,
    required super.userId,
    required super.rating,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create model from JSON
  factory BookRatingModel.fromJson(Map<String, dynamic> json) {
    return BookRatingModel(
      id: json['id'] as String,
      bookId: json['bookId'] as String,
      userId: json['userId'] as String,
      rating: (json['rating'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Create model from entity
  factory BookRatingModel.fromEntity(BookRating rating) {
    return BookRatingModel(
      id: rating.id,
      bookId: rating.bookId,
      userId: rating.userId,
      rating: rating.rating,
      createdAt: rating.createdAt,
      updatedAt: rating.updatedAt,
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'userId': userId,
      'rating': rating,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  @override
  BookRatingModel copyWith({
    String? id,
    String? bookId,
    String? userId,
    double? rating,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookRatingModel(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      userId: userId ?? this.userId,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
