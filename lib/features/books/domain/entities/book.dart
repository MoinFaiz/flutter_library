import 'package:equatable/equatable.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';

class Book extends Equatable {
  final String id;
  final String title;
  final String author;
  final List<String> imageUrls; // Multiple images for user uploads
  final double rating;
  final BookPricing pricing; // Separated pricing logic
  final BookAvailability availability; // Availability counts
  final BookMetadata metadata; // ISBN, publisher, genres, etc.
  final bool isFromFriend;
  final bool isFavorite;
  final String description;
  final int publishedYear;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.imageUrls,
    required this.rating,
    required this.pricing,
    required this.availability,
    required this.metadata,
    required this.isFromFriend,
    required this.isFavorite,
    required this.description,
    required this.publishedYear,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convenience getters for backward compatibility and ease of use
  String get primaryImageUrl => imageUrls.isNotEmpty ? imageUrls.first : '';
  String get primaryGenre => metadata.primaryGenre;
  List<String> get genres => metadata.genres;
  bool get hasMultipleImages => imageUrls.length > 1;
  bool get hasAnyImages => imageUrls.isNotEmpty;
  
  // Pricing convenience getters
  double get salePrice => pricing.finalSalePrice;
  double get rentPrice => pricing.finalRentPrice;
  bool get hasDiscount => pricing.hasSaleDiscount || pricing.hasRentDiscount;
  
  // Availability convenience getters
  bool get isAvailableForRent => availability.hasRentAvailable;
  bool get isAvailableForSale => availability.hasSaleAvailable;
  String get availabilityStatus => availability.availabilityStatus;

  // Business logic methods
  bool isInPriceRange(double? minPrice, double? maxPrice) {
    return pricing.isInPriceRange(minPrice, maxPrice);
  }

  bool matchesGenre(String genre) {
    return metadata.genres
        .any((g) => g.toLowerCase().contains(genre.toLowerCase()));
  }

  bool isAppropriateForAge(AgeAppropriateness targetAge) {
    return metadata.ageAppropriateness == targetAge || 
           metadata.ageAppropriateness == AgeAppropriateness.allAges;
  }

  Book copyWith({
    String? id,
    String? title,
    String? author,
    List<String>? imageUrls,
    double? rating,
    BookPricing? pricing,
    BookAvailability? availability,
    BookMetadata? metadata,
    bool? isFromFriend,
    bool? isFavorite,
    String? description,
    int? publishedYear,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      imageUrls: imageUrls ?? this.imageUrls,
      rating: rating ?? this.rating,
      pricing: pricing ?? this.pricing,
      availability: availability ?? this.availability,
      metadata: metadata ?? this.metadata,
      isFromFriend: isFromFriend ?? this.isFromFriend,
      isFavorite: isFavorite ?? this.isFavorite,
      description: description ?? this.description,
      publishedYear: publishedYear ?? this.publishedYear,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        author,
        imageUrls,
        rating,
        pricing,
        availability,
        metadata,
        isFromFriend,
        isFavorite,
        description,
        publishedYear,
        createdAt,
        updatedAt,
      ];
}
