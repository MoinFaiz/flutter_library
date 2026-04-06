import 'package:equatable/equatable.dart';

/// Value object representing book availability counts
class BookAvailability extends Equatable {
  final int availableForRentCount;
  final int availableForSaleCount;
  final int totalCopies;

  const BookAvailability({
    required this.availableForRentCount,
    required this.availableForSaleCount,
    required this.totalCopies,
  });

  /// Whether any copies are available for rent
  bool get hasRentAvailable => availableForRentCount > 0;

  /// Whether any copies are available for sale
  bool get hasSaleAvailable => availableForSaleCount > 0;

  /// Total available copies (rent + sale)
  int get totalAvailable => availableForRentCount + availableForSaleCount;

  /// Whether the book is out of stock
  bool get isOutOfStock => totalAvailable == 0;

  /// Availability status as string
  String get availabilityStatus {
    if (isOutOfStock) return 'Out of Stock';
    if (hasRentAvailable && hasSaleAvailable) return 'Available for Rent & Sale';
    if (hasRentAvailable) return 'Available for Rent Only';
    if (hasSaleAvailable) return 'Available for Sale Only';
    return 'Unavailable';
  }

  BookAvailability copyWith({
    int? availableForRentCount,
    int? availableForSaleCount,
    int? totalCopies,
  }) {
    return BookAvailability(
      availableForRentCount: availableForRentCount ?? this.availableForRentCount,
      availableForSaleCount: availableForSaleCount ?? this.availableForSaleCount,
      totalCopies: totalCopies ?? this.totalCopies,
    );
  }

  @override
  List<Object> get props => [
        availableForRentCount,
        availableForSaleCount,
        totalCopies,
      ];
}
