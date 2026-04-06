import 'package:equatable/equatable.dart';

/// Enum for book condition
enum BookCondition {
  new_,
  likeNew,
  veryGood,
  good,
  acceptable,
  poor;

  /// Display name for the condition
  String get displayName {
    switch (this) {
      case BookCondition.new_:
        return 'New';
      case BookCondition.likeNew:
        return 'Like New';
      case BookCondition.veryGood:
        return 'Very Good';
      case BookCondition.good:
        return 'Good';
      case BookCondition.acceptable:
        return 'Acceptable';
      case BookCondition.poor:
        return 'Poor';
    }
  }

  /// Description of the condition
  String get description {
    switch (this) {
      case BookCondition.new_:
        return 'Brand new, unused book';
      case BookCondition.likeNew:
        return 'Nearly new with minimal wear';
      case BookCondition.veryGood:
        return 'Some wear but still in great condition';
      case BookCondition.good:
        return 'Normal wear with some signs of use';
      case BookCondition.acceptable:
        return 'Significant wear but still readable';
      case BookCondition.poor:
        return 'Heavy wear, may have damage';
    }
  }
}

/// Entity representing a copy of a book that a user wants to upload
class BookCopy extends Equatable {
  final String? id;
  final String? bookId; // Reference to the main book
  final String? userId; // Owner of this copy
  final List<String> imageUrls; // Images of this specific copy
  final BookCondition condition;
  final bool isForSale;
  final bool isForRent;
  final bool isForDonate;
  final double? expectedPrice; // Price if for sale
  final double? rentPrice; // Price if for rent
  final String? notes; // Additional notes about the copy
  final DateTime? uploadDate;
  final DateTime? updatedAt;

  const BookCopy({
    this.id,
    this.bookId,
    this.userId,
    required this.imageUrls,
    required this.condition,
    required this.isForSale,
    required this.isForRent,
    required this.isForDonate,
    this.expectedPrice,
    this.rentPrice,
    this.notes,
    this.uploadDate,
    this.updatedAt,
  });

  /// Whether this copy is available for any type of transaction
  bool get isAvailable => isForSale || isForRent || isForDonate;

  /// Primary availability type as string
  String get availabilityType {
    if (isForSale && isForRent && isForDonate) return 'Sale, Rent & Donate';
    if (isForSale && isForRent) return 'Sale & Rent';
    if (isForSale && isForDonate) return 'Sale & Donate';
    if (isForRent && isForDonate) return 'Rent & Donate';
    if (isForSale) return 'For Sale';
    if (isForRent) return 'For Rent';
    if (isForDonate) return 'For Donate';
    return 'Not Available';
  }

  /// Whether this copy has required fields for upload
  bool get isValid {
    return imageUrls.isNotEmpty && 
           (isForSale || isForRent || isForDonate);
  }

  /// Whether this copy has pricing information
  bool get hasPricing {
    return (isForSale && expectedPrice != null) || 
           (isForRent && rentPrice != null);
  }

  BookCopy copyWith({
    String? id,
    String? bookId,
    String? userId,
    List<String>? imageUrls,
    BookCondition? condition,
    bool? isForSale,
    bool? isForRent,
    bool? isForDonate,
    double? expectedPrice,
    double? rentPrice,
    String? notes,
    DateTime? uploadDate,
    DateTime? updatedAt,
  }) {
    return BookCopy(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      userId: userId ?? this.userId,
      imageUrls: imageUrls ?? this.imageUrls,
      condition: condition ?? this.condition,
      isForSale: isForSale ?? this.isForSale,
      isForRent: isForRent ?? this.isForRent,
      isForDonate: isForDonate ?? this.isForDonate,
      expectedPrice: expectedPrice ?? this.expectedPrice,
      rentPrice: rentPrice ?? this.rentPrice,
      notes: notes ?? this.notes,
      uploadDate: uploadDate ?? this.uploadDate,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        bookId,
        userId,
        imageUrls,
        condition,
        isForSale,
        isForRent,
        isForDonate,
        expectedPrice,
        rentPrice,
        notes,
        uploadDate,
        updatedAt,
      ];
}
