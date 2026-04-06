import 'package:flutter_library/features/book_upload/domain/entities/book_copy.dart';

/// Data model for book copy
class BookCopyModel extends BookCopy {
  const BookCopyModel({
    super.id,
    super.bookId,
    super.userId,
    required super.imageUrls,
    required super.condition,
    required super.isForSale,
    required super.isForRent,
    required super.isForDonate,
    super.expectedPrice,
    super.rentPrice,
    super.notes,
    super.uploadDate,
    super.updatedAt,
  });

  /// Create model from JSON
  factory BookCopyModel.fromJson(Map<String, dynamic> json) {
    return BookCopyModel(
      id: json['id'] as String?,
      bookId: json['bookId'] as String?,
      userId: json['userId'] as String?,
      imageUrls: (json['images'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      condition: _parseCondition(json['condition']?.toString()),
      isForSale: json['isForSale'] as bool? ?? false,
      isForRent: json['isForRent'] as bool? ?? false,
      isForDonate: json['isForDonate'] as bool? ?? false,
      expectedPrice: (json['expectedPrice'] as num?)?.toDouble(),
      rentPrice: (json['rentPrice'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      uploadDate: json['uploadDate'] != null
          ? DateTime.parse(json['uploadDate'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'userId': userId,
      'images': imageUrls,
      'condition': condition.name,
      'isForSale': isForSale,
      'isForRent': isForRent,
      'isForDonate': isForDonate,
      'expectedPrice': expectedPrice,
      'rentPrice': rentPrice,
      'notes': notes,
      'uploadDate': uploadDate?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Parse condition from string
  static BookCondition _parseCondition(String? conditionStr) {
    switch (conditionStr?.toLowerCase().trim()) {
      case 'new':
        return BookCondition.new_;
      case 'like new':
      case 'likenew':
        return BookCondition.likeNew;
      case 'very good':
      case 'verygood':
        return BookCondition.veryGood;
      case 'good':
        return BookCondition.good;
      case 'acceptable':
        return BookCondition.acceptable;
      case 'poor':
        return BookCondition.poor;
      default:
        return BookCondition.good;
    }
  }

  /// Create model from entity
  factory BookCopyModel.fromEntity(BookCopy bookCopy) {
    return BookCopyModel(
      id: bookCopy.id,
      bookId: bookCopy.bookId,
      userId: bookCopy.userId,
      imageUrls: bookCopy.imageUrls,
      condition: bookCopy.condition,
      isForSale: bookCopy.isForSale,
      isForRent: bookCopy.isForRent,
      isForDonate: bookCopy.isForDonate,
      expectedPrice: bookCopy.expectedPrice,
      rentPrice: bookCopy.rentPrice,
      notes: bookCopy.notes,
      uploadDate: bookCopy.uploadDate,
      updatedAt: bookCopy.updatedAt,
    );
  }

  /// Create a copy with updated fields
  @override
  BookCopyModel copyWith({
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
    return BookCopyModel(
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
}
