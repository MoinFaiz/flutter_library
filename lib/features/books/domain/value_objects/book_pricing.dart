import 'package:equatable/equatable.dart';

/// Value object representing book pricing information for rental and sale
class BookPricing extends Equatable {
  final double salePrice;
  final double? discountedSalePrice;
  final double rentPrice;
  final double? discountedRentPrice;
  final double? percentageDiscountForRent;
  final double? percentageDiscountForSale;
  final double? minimumCostToBuy;
  final double? maximumCostToBuy;

  const BookPricing({
    required this.salePrice,
    this.discountedSalePrice,
    required this.rentPrice,
    this.discountedRentPrice,
    this.percentageDiscountForRent,
    this.percentageDiscountForSale,
    this.minimumCostToBuy,
    this.maximumCostToBuy,
  });

  /// Final price for sale (with discount if available)
  double get finalSalePrice => discountedSalePrice ?? salePrice;

  /// Final price for rent (with discount if available)
  double get finalRentPrice => discountedRentPrice ?? rentPrice;

  /// Whether sale has discount
  bool get hasSaleDiscount => 
      discountedSalePrice != null && discountedSalePrice! < salePrice;

  /// Whether rent has discount
  bool get hasRentDiscount => 
      discountedRentPrice != null && discountedRentPrice! < rentPrice;

  /// Calculated sale discount percentage
  double get saleDiscountPercentage {
    if (!hasSaleDiscount) return 0;
    return ((salePrice - discountedSalePrice!) / salePrice * 100);
  }

  /// Calculated rent discount percentage
  double get rentDiscountPercentage {
    if (!hasRentDiscount) return 0;
    return ((rentPrice - discountedRentPrice!) / rentPrice * 100);
  }

  /// Whether this book is in the specified price range for buying
  bool isInPriceRange(double? minPrice, double? maxPrice) {
    final price = finalSalePrice;
    if (minPrice != null && price < minPrice) return false;
    if (maxPrice != null && price > maxPrice) return false;
    return true;
  }

  BookPricing copyWith({
    double? salePrice,
    double? discountedSalePrice,
    double? rentPrice,
    double? discountedRentPrice,
    double? percentageDiscountForRent,
    double? percentageDiscountForSale,
    double? minimumCostToBuy,
    double? maximumCostToBuy,
  }) {
    return BookPricing(
      salePrice: salePrice ?? this.salePrice,
      discountedSalePrice: discountedSalePrice ?? this.discountedSalePrice,
      rentPrice: rentPrice ?? this.rentPrice,
      discountedRentPrice: discountedRentPrice ?? this.discountedRentPrice,
      percentageDiscountForRent: percentageDiscountForRent ?? this.percentageDiscountForRent,
      percentageDiscountForSale: percentageDiscountForSale ?? this.percentageDiscountForSale,
      minimumCostToBuy: minimumCostToBuy ?? this.minimumCostToBuy,
      maximumCostToBuy: maximumCostToBuy ?? this.maximumCostToBuy,
    );
  }

  @override
  List<Object?> get props => [
        salePrice,
        discountedSalePrice,
        rentPrice,
        discountedRentPrice,
        percentageDiscountForRent,
        percentageDiscountForSale,
        minimumCostToBuy,
        maximumCostToBuy,
      ];
}
