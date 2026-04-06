import 'package:equatable/equatable.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';

/// Data Transfer Object for books received from a remote or local data source.
/// Intentionally separate from [Book] entity — carries no user-preference state
/// such as [isFavorite]. Repositories call [toEntity] to cross the data→domain
/// boundary.
class BookModel extends Equatable {
  final String id;
  final String title;
  final String author;
  final List<String> imageUrls;
  final double rating;
  final BookPricing pricing;
  final BookAvailability availability;
  final BookMetadata metadata;
  final bool isFromFriend;
  final String description;
  final int publishedYear;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.imageUrls,
    required this.rating,
    required this.pricing,
    required this.availability,
    required this.metadata,
    required this.isFromFriend,
    required this.description,
    required this.publishedYear,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Converts this DTO to a domain [Book] entity.
  /// [isFavorite] defaults to false; the presentation layer is responsible for
  /// enriching with the correct status via [GetFavoriteIdsUseCase].
  Book toEntity() {
    return Book(
      id: id,
      title: title,
      author: author,
      imageUrls: imageUrls,
      rating: rating,
      pricing: pricing,
      availability: availability,
      metadata: metadata,
      isFromFriend: isFromFriend,
      isFavorite: false,
      description: description,
      publishedYear: publishedYear,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Creates a [BookModel] from a domain [Book] entity (e.g. for caching).
  factory BookModel.fromEntity(Book book) {
    return BookModel(
      id: book.id,
      title: book.title,
      author: book.author,
      imageUrls: book.imageUrls,
      rating: book.rating,
      pricing: book.pricing,
      availability: book.availability,
      metadata: book.metadata,
      isFromFriend: book.isFromFriend,
      description: book.description,
      publishedYear: book.publishedYear,
      createdAt: book.createdAt,
      updatedAt: book.updatedAt,
    );
  }

  factory BookModel.fromJson(Map<String, dynamic> json) {
    // Parse pricing information
    final pricingData = json['pricing'] as Map<String, dynamic>? ?? {};
    final pricing = BookPricing(
      salePrice: (pricingData['salePrice'] as num?)?.toDouble() ?? 0.0,
      discountedSalePrice: pricingData['discountedSalePrice'] != null
          ? (pricingData['discountedSalePrice'] as num).toDouble()
          : null,
      rentPrice: (pricingData['rentPrice'] as num?)?.toDouble() ?? 0.0,
      discountedRentPrice: pricingData['discountedRentPrice'] != null
          ? (pricingData['discountedRentPrice'] as num).toDouble()
          : null,
      percentageDiscountForRent: pricingData['percentageDiscountForRent'] != null
          ? (pricingData['percentageDiscountForRent'] as num).toDouble()
          : null,
      percentageDiscountForSale: pricingData['percentageDiscountForSale'] != null
          ? (pricingData['percentageDiscountForSale'] as num).toDouble()
          : null,
      minimumCostToBuy: pricingData['minimumCostToBuy'] != null
          ? (pricingData['minimumCostToBuy'] as num).toDouble()
          : null,
      maximumCostToBuy: pricingData['maximumCostToBuy'] != null
          ? (pricingData['maximumCostToBuy'] as num).toDouble()
          : null,
    );

    // Parse availability information
    final availabilityData = json['availability'] as Map<String, dynamic>? ?? {};
    final availability = BookAvailability(
      availableForRentCount: availabilityData['availableForRentCount'] as int? ?? 0,
      availableForSaleCount: availabilityData['availableForSaleCount'] as int? ?? 0,
      totalCopies: availabilityData['totalCopies'] as int? ?? 1,
    );

    // Parse metadata information
    final metadataMap = json['metadata'] as Map<String, dynamic>? ?? {};
    final metadata = BookMetadata(
      isbn: metadataMap['isbn'] as String?,
      publisher: metadataMap['publisher'] as String?,
      ageAppropriateness: _parseAgeAppropriateness(metadataMap['ageAppropriateness'] as String?),
      genres: (metadataMap['genres'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['Unknown'],
      pageCount: metadataMap['pageCount'] as int? ?? 0,
      language: metadataMap['language'] as String? ?? 'English',
      edition: metadataMap['edition'] as String?,
    );

    return BookModel(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      pricing: pricing,
      availability: availability,
      metadata: metadata,
      isFromFriend: json['isFromFriend'] as bool? ?? false,
      description: json['description'] as String? ?? '',
      publishedYear: json['publishedYear'] as int? ?? DateTime.now().year,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  // Helper method to parse age appropriateness
  static AgeAppropriateness _parseAgeAppropriateness(String? value) {
    switch (value?.toLowerCase()) {
      case 'children':
        return AgeAppropriateness.children;
      case 'young_adult':
      case 'youngadult':
        return AgeAppropriateness.youngAdult;
      case 'adult':
        return AgeAppropriateness.adult;
      case 'all_ages':
      case 'allages':
        return AgeAppropriateness.allAges;
      default:
        return AgeAppropriateness.allAges;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'imageUrls': imageUrls,
      'rating': rating,
      'pricing': {
        'salePrice': pricing.salePrice,
        'discountedSalePrice': pricing.discountedSalePrice,
        'rentPrice': pricing.rentPrice,
        'discountedRentPrice': pricing.discountedRentPrice,
        'percentageDiscountForRent': pricing.percentageDiscountForRent,
        'percentageDiscountForSale': pricing.percentageDiscountForSale,
        'minimumCostToBuy': pricing.minimumCostToBuy,
        'maximumCostToBuy': pricing.maximumCostToBuy,
      },
      'availability': {
        'availableForRentCount': availability.availableForRentCount,
        'availableForSaleCount': availability.availableForSaleCount,
        'totalCopies': availability.totalCopies,
      },
      'metadata': {
        'isbn': metadata.isbn,
        'publisher': metadata.publisher,
        'ageAppropriateness': metadata.ageAppropriateness.name,
        'genres': metadata.genres,
        'pageCount': metadata.pageCount,
        'language': metadata.language,
        'edition': metadata.edition,
      },
      'isFromFriend': isFromFriend,
      'description': description,
      'publishedYear': publishedYear,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
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
        description,
        publishedYear,
        createdAt,
        updatedAt,
      ];
}

