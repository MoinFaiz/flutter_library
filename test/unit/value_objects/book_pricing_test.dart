import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';

void main() {
  group('BookPricing Value Object Tests', () {
    final basicPricing = BookPricing(
      salePrice: 25.99,
      rentPrice: 5.99,
    );

    final discountedPricing = BookPricing(
      salePrice: 30.99,
      discountedSalePrice: 24.79, // 20% discount
      rentPrice: 6.99,
      discountedRentPrice: 5.59, // 20% discount
      percentageDiscountForSale: 20.0,
      percentageDiscountForRent: 20.0,
    );

    group('Constructor and Properties', () {
      test('should create BookPricing with required properties', () {
        expect(basicPricing.salePrice, 25.99);
        expect(basicPricing.rentPrice, 5.99);
        expect(basicPricing.discountedSalePrice, isNull);
        expect(basicPricing.discountedRentPrice, isNull);
      });

      test('should create BookPricing with all properties including discounts', () {
        expect(discountedPricing.salePrice, 30.99);
        expect(discountedPricing.discountedSalePrice, 24.79);
        expect(discountedPricing.rentPrice, 6.99);
        expect(discountedPricing.discountedRentPrice, 5.59);
        expect(discountedPricing.percentageDiscountForSale, 20.0);
        expect(discountedPricing.percentageDiscountForRent, 20.0);
      });
    });

    group('Final Price Calculations', () {
      test('finalSalePrice should return original price when no discount', () {
        expect(basicPricing.finalSalePrice, 25.99);
      });

      test('finalSalePrice should return discounted price when discount available', () {
        expect(discountedPricing.finalSalePrice, 24.79);
      });

      test('finalRentPrice should return original price when no discount', () {
        expect(basicPricing.finalRentPrice, 5.99);
      });

      test('finalRentPrice should return discounted price when discount available', () {
        expect(discountedPricing.finalRentPrice, 5.59);
      });
    });

    group('Discount Detection', () {
      test('hasSaleDiscount should return false when no sale discount', () {
        expect(basicPricing.hasSaleDiscount, false);
      });

      test('hasSaleDiscount should return true when sale discount available', () {
        expect(discountedPricing.hasSaleDiscount, true);
      });

      test('hasRentDiscount should return false when no rent discount', () {
        expect(basicPricing.hasRentDiscount, false);
      });

      test('hasRentDiscount should return true when rent discount available', () {
        expect(discountedPricing.hasRentDiscount, true);
      });

      test('hasSaleDiscount should return false when discounted price equals original', () {
        final noRealDiscount = BookPricing(
          salePrice: 25.99,
          discountedSalePrice: 25.99, // Same price
          rentPrice: 5.99,
        );
        expect(noRealDiscount.hasSaleDiscount, false);
      });

      test('hasSaleDiscount should return false when discounted price is higher', () {
        final invalidDiscount = BookPricing(
          salePrice: 25.99,
          discountedSalePrice: 30.99, // Higher than original
          rentPrice: 5.99,
        );
        expect(invalidDiscount.hasSaleDiscount, false);
      });
    });

    group('Discount Percentage Calculations', () {
      test('saleDiscountPercentage should return 0 when no discount', () {
        expect(basicPricing.saleDiscountPercentage, 0.0);
      });

      test('saleDiscountPercentage should calculate correct percentage', () {
        // (30.99 - 24.79) / 30.99 * 100 ≈ 20%
        expect(discountedPricing.saleDiscountPercentage, closeTo(20.0, 0.1));
      });

      test('rentDiscountPercentage should return 0 when no discount', () {
        expect(basicPricing.rentDiscountPercentage, 0.0);
      });

      test('rentDiscountPercentage should calculate correct percentage', () {
        // (6.99 - 5.59) / 6.99 * 100 ≈ 20%
        expect(discountedPricing.rentDiscountPercentage, closeTo(20.0, 0.1));
      });

      test('should handle edge case of very small discounts', () {
        final smallDiscount = BookPricing(
          salePrice: 10.00,
          discountedSalePrice: 9.99, // 0.1% discount
          rentPrice: 5.00,
        );
        expect(smallDiscount.saleDiscountPercentage, closeTo(0.1, 0.01));
      });

      test('should handle edge case of large discounts', () {
        final largeDiscount = BookPricing(
          salePrice: 100.00,
          discountedSalePrice: 1.00, // 99% discount
          rentPrice: 5.00,
        );
        expect(largeDiscount.saleDiscountPercentage, closeTo(99.0, 0.1));
      });
    });

    group('Price Range Validation', () {
      test('isInPriceRange should return true when within range', () {
        expect(basicPricing.isInPriceRange(20.0, 30.0), true);
        expect(discountedPricing.isInPriceRange(20.0, 30.0), true);
      });

      test('isInPriceRange should return false when below minimum', () {
        expect(basicPricing.isInPriceRange(30.0, 40.0), false);
      });

      test('isInPriceRange should return false when above maximum', () {
        expect(basicPricing.isInPriceRange(10.0, 20.0), false);
      });

      test('isInPriceRange should handle null minimum price', () {
        expect(basicPricing.isInPriceRange(null, 30.0), true);
        expect(basicPricing.isInPriceRange(null, 20.0), false);
      });

      test('isInPriceRange should handle null maximum price', () {
        expect(basicPricing.isInPriceRange(20.0, null), true);
        expect(basicPricing.isInPriceRange(30.0, null), false);
      });

      test('isInPriceRange should handle both null prices', () {
        expect(basicPricing.isInPriceRange(null, null), true);
      });

      test('isInPriceRange should use discounted price when available', () {
        // Discounted price is 24.79, original is 30.99
        expect(discountedPricing.isInPriceRange(24.0, 25.0), true);
        expect(discountedPricing.isInPriceRange(30.0, 35.0), false);
      });

      test('isInPriceRange should handle exact price boundaries', () {
        expect(basicPricing.isInPriceRange(25.99, 25.99), true);
        expect(basicPricing.isInPriceRange(25.98, 25.99), true);
        expect(basicPricing.isInPriceRange(25.99, 26.00), true);
      });
    });

    group('copyWith Method', () {
      test('should create new instance with updated sale price', () {
        final updated = basicPricing.copyWith(salePrice: 35.99);
        
        expect(updated.salePrice, 35.99);
        expect(updated.rentPrice, basicPricing.rentPrice);
        expect(updated.discountedSalePrice, basicPricing.discountedSalePrice);
      });

      test('should create new instance with updated discount prices', () {
        final updated = basicPricing.copyWith(
          discountedSalePrice: 20.99,
          discountedRentPrice: 4.99,
        );
        
        expect(updated.discountedSalePrice, 20.99);
        expect(updated.discountedRentPrice, 4.99);
        expect(updated.salePrice, basicPricing.salePrice);
        expect(updated.rentPrice, basicPricing.rentPrice);
      });

      test('should create new instance with all properties updated', () {
        final updated = basicPricing.copyWith(
          salePrice: 40.99,
          discountedSalePrice: 32.79,
          rentPrice: 8.99,
          discountedRentPrice: 7.19,
          percentageDiscountForSale: 20.0,
          percentageDiscountForRent: 20.0,
          minimumCostToBuy: 32.79,
          maximumCostToBuy: 40.99,
        );
        
        expect(updated.salePrice, 40.99);
        expect(updated.discountedSalePrice, 32.79);
        expect(updated.rentPrice, 8.99);
        expect(updated.discountedRentPrice, 7.19);
        expect(updated.minimumCostToBuy, 32.79);
        expect(updated.maximumCostToBuy, 40.99);
      });

      test('should return identical instance when no parameters provided', () {
        final copied = basicPricing.copyWith();
        
        expect(copied.salePrice, basicPricing.salePrice);
        expect(copied.rentPrice, basicPricing.rentPrice);
        expect(copied.discountedSalePrice, basicPricing.discountedSalePrice);
        expect(copied.discountedRentPrice, basicPricing.discountedRentPrice);
      });
    });

    group('Equatable Implementation', () {
      test('should be equal when all properties are identical', () {
        final pricing1 = BookPricing(
          salePrice: 25.99,
          discountedSalePrice: 20.99,
          rentPrice: 5.99,
          discountedRentPrice: 4.99,
          percentageDiscountForSale: 19.3,
          percentageDiscountForRent: 16.7,
        );

        final pricing2 = BookPricing(
          salePrice: 25.99,
          discountedSalePrice: 20.99,
          rentPrice: 5.99,
          discountedRentPrice: 4.99,
          percentageDiscountForSale: 19.3,
          percentageDiscountForRent: 16.7,
        );

        expect(pricing1, equals(pricing2));
        expect(pricing1.hashCode, equals(pricing2.hashCode));
      });

      test('should not be equal when properties differ', () {
        final pricing1 = basicPricing;
        final pricing2 = basicPricing.copyWith(salePrice: 30.99);

        expect(pricing1, isNot(equals(pricing2)));
        expect(pricing1.hashCode, isNot(equals(pricing2.hashCode)));
      });

      test('should not be equal when discount properties differ', () {
        final pricing1 = discountedPricing;
        final pricing2 = discountedPricing.copyWith(discountedSalePrice: 25.99);

        expect(pricing1, isNot(equals(pricing2)));
        expect(pricing1.hashCode, isNot(equals(pricing2.hashCode)));
      });
    });

    group('Edge Cases and Validation', () {
      test('should handle zero prices', () {
        final freePricing = BookPricing(
          salePrice: 0.0,
          rentPrice: 0.0,
        );
        
        expect(freePricing.finalSalePrice, 0.0);
        expect(freePricing.finalRentPrice, 0.0);
        expect(freePricing.hasSaleDiscount, false);
        expect(freePricing.hasRentDiscount, false);
      });

      test('should handle very high prices', () {
        final expensivePricing = BookPricing(
          salePrice: 999999.99,
          rentPrice: 99999.99,
        );
        
        expect(expensivePricing.finalSalePrice, 999999.99);
        expect(expensivePricing.finalRentPrice, 99999.99);
        expect(expensivePricing.isInPriceRange(999999.0, 1000000.0), true);
      });

      test('should handle precision with small decimal values', () {
        final precisionPricing = BookPricing(
          salePrice: 9.99,
          discountedSalePrice: 9.98,
          rentPrice: 1.99,
          discountedRentPrice: 1.98,
        );
        
        expect(precisionPricing.hasSaleDiscount, true);
        expect(precisionPricing.hasRentDiscount, true);
        expect(precisionPricing.finalSalePrice, 9.98);
        expect(precisionPricing.finalRentPrice, 1.98);
      });
    });
  });
}
