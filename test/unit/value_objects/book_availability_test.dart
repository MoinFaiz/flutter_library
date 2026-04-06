import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';

void main() {
  group('BookAvailability Value Object Tests', () {
    final fullAvailability = BookAvailability(
      totalCopies: 10,
      availableForRentCount: 6,
      availableForSaleCount: 4,
    );

    final partialAvailability = BookAvailability(
      totalCopies: 5,
      availableForRentCount: 3,
      availableForSaleCount: 0, // No sale copies available
    );

    final outOfStock = BookAvailability(
      totalCopies: 3,
      availableForRentCount: 0,
      availableForSaleCount: 0,
    );

    group('Constructor and Properties', () {
      test('should create BookAvailability with all properties', () {
        expect(fullAvailability.totalCopies, 10);
        expect(fullAvailability.availableForRentCount, 6);
        expect(fullAvailability.availableForSaleCount, 4);
      });

      test('should create BookAvailability with partial availability', () {
        expect(partialAvailability.totalCopies, 5);
        expect(partialAvailability.availableForRentCount, 3);
        expect(partialAvailability.availableForSaleCount, 0);
      });

      test('should create BookAvailability with zero availability', () {
        expect(outOfStock.totalCopies, 3);
        expect(outOfStock.availableForRentCount, 0);
        expect(outOfStock.availableForSaleCount, 0);
      });
    });

    group('Availability Status Checks', () {
      test('hasRentAvailable should return true when rent copies available', () {
        expect(fullAvailability.hasRentAvailable, true);
        expect(partialAvailability.hasRentAvailable, true);
      });

      test('hasRentAvailable should return false when no rent copies available', () {
        expect(outOfStock.hasRentAvailable, false);
      });

      test('hasSaleAvailable should return true when sale copies available', () {
        expect(fullAvailability.hasSaleAvailable, true);
      });

      test('hasSaleAvailable should return false when no sale copies available', () {
        expect(partialAvailability.hasSaleAvailable, false);
        expect(outOfStock.hasSaleAvailable, false);
      });
    });

    group('Total Available Calculation', () {
      test('totalAvailable should sum rent and sale counts', () {
        expect(fullAvailability.totalAvailable, 10); // 6 + 4
        expect(partialAvailability.totalAvailable, 3); // 3 + 0
        expect(outOfStock.totalAvailable, 0); // 0 + 0
      });

      test('totalAvailable should handle edge cases', () {
        final edgeCase = BookAvailability(
          totalCopies: 1,
          availableForRentCount: 1,
          availableForSaleCount: 0,
        );
        expect(edgeCase.totalAvailable, 1);
      });
    });

    group('Out of Stock Detection', () {
      test('isOutOfStock should return false when books are available', () {
        expect(fullAvailability.isOutOfStock, false);
        expect(partialAvailability.isOutOfStock, false);
      });

      test('isOutOfStock should return true when no books are available', () {
        expect(outOfStock.isOutOfStock, true);
      });

      test('isOutOfStock should handle single copy scenarios', () {
        final singleCopy = BookAvailability(
          totalCopies: 1,
          availableForRentCount: 1,
          availableForSaleCount: 0,
        );
        expect(singleCopy.isOutOfStock, false);

        final zeroAvailable = BookAvailability(
          totalCopies: 1,
          availableForRentCount: 0,
          availableForSaleCount: 0,
        );
        expect(zeroAvailable.isOutOfStock, true);
      });
    });

    group('Availability Status Display', () {
      test('availabilityStatus should return correct status for full availability', () {
        expect(fullAvailability.availabilityStatus, 'Available for Rent & Sale');
      });

      test('availabilityStatus should return correct status for rent only', () {
        expect(partialAvailability.availabilityStatus, 'Available for Rent Only');
      });

      test('availabilityStatus should return correct status for sale only', () {
        final saleOnly = BookAvailability(
          totalCopies: 5,
          availableForRentCount: 0,
          availableForSaleCount: 3,
        );
        expect(saleOnly.availabilityStatus, 'Available for Sale Only');
      });

      test('availabilityStatus should return correct status for out of stock', () {
        expect(outOfStock.availabilityStatus, 'Out of Stock');
      });
    });

    group('copyWith Method', () {
      test('should create new instance with updated rent count', () {
        final updated = fullAvailability.copyWith(availableForRentCount: 8);
        
        expect(updated.availableForRentCount, 8);
        expect(updated.availableForSaleCount, fullAvailability.availableForSaleCount);
        expect(updated.totalCopies, fullAvailability.totalCopies);
      });

      test('should create new instance with updated sale count', () {
        final updated = fullAvailability.copyWith(availableForSaleCount: 2);
        
        expect(updated.availableForSaleCount, 2);
        expect(updated.availableForRentCount, fullAvailability.availableForRentCount);
        expect(updated.totalCopies, fullAvailability.totalCopies);
      });

      test('should create new instance with updated total copies', () {
        final updated = fullAvailability.copyWith(totalCopies: 15);
        
        expect(updated.totalCopies, 15);
        expect(updated.availableForRentCount, fullAvailability.availableForRentCount);
        expect(updated.availableForSaleCount, fullAvailability.availableForSaleCount);
      });

      test('should create new instance with all properties updated', () {
        final updated = fullAvailability.copyWith(
          totalCopies: 20,
          availableForRentCount: 12,
          availableForSaleCount: 8,
        );
        
        expect(updated.totalCopies, 20);
        expect(updated.availableForRentCount, 12);
        expect(updated.availableForSaleCount, 8);
      });

      test('should return identical instance when no parameters provided', () {
        final copied = fullAvailability.copyWith();
        
        expect(copied.totalCopies, fullAvailability.totalCopies);
        expect(copied.availableForRentCount, fullAvailability.availableForRentCount);
        expect(copied.availableForSaleCount, fullAvailability.availableForSaleCount);
      });
    });

    group('Equatable Implementation', () {
      test('should be equal when all properties are identical', () {
        final availability1 = BookAvailability(
          totalCopies: 10,
          availableForRentCount: 6,
          availableForSaleCount: 4,
        );

        final availability2 = BookAvailability(
          totalCopies: 10,
          availableForRentCount: 6,
          availableForSaleCount: 4,
        );

        expect(availability1, equals(availability2));
        expect(availability1.hashCode, equals(availability2.hashCode));
      });

      test('should not be equal when properties differ', () {
        final availability1 = fullAvailability;
        final availability2 = fullAvailability.copyWith(availableForRentCount: 5);

        expect(availability1, isNot(equals(availability2)));
        expect(availability1.hashCode, isNot(equals(availability2.hashCode)));
      });

      test('should not be equal when total copies differ', () {
        final availability1 = fullAvailability;
        final availability2 = fullAvailability.copyWith(totalCopies: 15);

        expect(availability1, isNot(equals(availability2)));
        expect(availability1.hashCode, isNot(equals(availability2.hashCode)));
      });
    });

    group('Business Logic Validations', () {
      test('should handle scenarios where available exceeds total', () {
        // This might happen due to data inconsistency
        final inconsistent = BookAvailability(
          totalCopies: 5,
          availableForRentCount: 4,
          availableForSaleCount: 3, // Total available (7) > total copies (5)
        );
        
        expect(inconsistent.totalAvailable, 7);
        expect(inconsistent.hasRentAvailable, true);
        expect(inconsistent.hasSaleAvailable, true);
        expect(inconsistent.isOutOfStock, false);
      });

      test('should handle zero total copies with available counts', () {
        final zeroTotal = BookAvailability(
          totalCopies: 0,
          availableForRentCount: 1,
          availableForSaleCount: 1,
        );
        
        expect(zeroTotal.totalAvailable, 2);
        expect(zeroTotal.isOutOfStock, false);
      });

      test('should handle negative counts gracefully', () {
        final negativeCount = BookAvailability(
          totalCopies: 5,
          availableForRentCount: -1, // Invalid but handled
          availableForSaleCount: 3,
        );
        
        expect(negativeCount.totalAvailable, 2); // -1 + 3
        expect(negativeCount.hasRentAvailable, false); // -1 is not > 0
        expect(negativeCount.hasSaleAvailable, true);
      });
    });

    group('Edge Cases and Realistic Scenarios', () {
      test('should handle single copy book scenarios', () {
        final singleCopyRent = BookAvailability(
          totalCopies: 1,
          availableForRentCount: 1,
          availableForSaleCount: 0,
        );
        
        expect(singleCopyRent.availabilityStatus, 'Available for Rent Only');
        expect(singleCopyRent.totalAvailable, 1);
        expect(singleCopyRent.isOutOfStock, false);

        final singleCopySale = BookAvailability(
          totalCopies: 1,
          availableForRentCount: 0,
          availableForSaleCount: 1,
        );
        
        expect(singleCopySale.availabilityStatus, 'Available for Sale Only');
      });

      test('should handle large inventory scenarios', () {
        final largeInventory = BookAvailability(
          totalCopies: 1000,
          availableForRentCount: 600,
          availableForSaleCount: 400,
        );
        
        expect(largeInventory.totalAvailable, 1000);
        expect(largeInventory.hasRentAvailable, true);
        expect(largeInventory.hasSaleAvailable, true);
        expect(largeInventory.availabilityStatus, 'Available for Rent & Sale');
      });

      test('should handle popular book with high demand (low availability)', () {
        final lowAvailability = BookAvailability(
          totalCopies: 100,
          availableForRentCount: 1,
          availableForSaleCount: 1,
        );
        
        expect(lowAvailability.totalAvailable, 2);
        expect(lowAvailability.hasRentAvailable, true);
        expect(lowAvailability.hasSaleAvailable, true);
        expect(lowAvailability.isOutOfStock, false);
        expect(lowAvailability.availabilityStatus, 'Available for Rent & Sale');
      });
    });
  });
}
