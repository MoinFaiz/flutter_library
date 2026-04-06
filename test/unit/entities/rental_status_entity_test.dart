import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/book_details/domain/entities/rental_status.dart';

void main() {
  group('RentalStatus Entity', () {
    const tBookId = 'book_123';
    const tStatus = RentalStatusType.rented;
    final tDueDate = DateTime(2023, 6, 15, 23, 59);
    final tRentedDate = DateTime(2023, 5, 15, 10, 30);
    final tReturnDate = DateTime(2023, 6, 10, 14, 30);
    const tDaysRemaining = 5;
    const tCanRenew = true;
    const tIsInCart = false;
    const tIsPurchased = false;
    const tLateFee = 2.50;
    const tNotes = 'Please return by due date to avoid late fees.';

    final tRentalStatus = RentalStatus(
      bookId: tBookId,
      status: tStatus,
      dueDate: tDueDate,
      rentedDate: tRentedDate,
      returnDate: tReturnDate,
      daysRemaining: tDaysRemaining,
      canRenew: tCanRenew,
      isInCart: tIsInCart,
      isPurchased: tIsPurchased,
      lateFee: tLateFee,
      notes: tNotes,
    );

    group('constructor', () {
      test('should create RentalStatus with all fields', () {
        // act & assert
        expect(tRentalStatus.bookId, equals(tBookId));
        expect(tRentalStatus.status, equals(tStatus));
        expect(tRentalStatus.dueDate, equals(tDueDate));
        expect(tRentalStatus.rentedDate, equals(tRentedDate));
        expect(tRentalStatus.returnDate, equals(tReturnDate));
        expect(tRentalStatus.daysRemaining, equals(tDaysRemaining));
        expect(tRentalStatus.canRenew, equals(tCanRenew));
        expect(tRentalStatus.isInCart, equals(tIsInCart));
        expect(tRentalStatus.isPurchased, equals(tIsPurchased));
        expect(tRentalStatus.lateFee, equals(tLateFee));
        expect(tRentalStatus.notes, equals(tNotes));
      });

      test('should create RentalStatus with required fields only', () {
        // arrange
        const rentalStatus = RentalStatus(
          bookId: tBookId,
          status: RentalStatusType.available,
        );

        // assert
        expect(rentalStatus.bookId, equals(tBookId));
        expect(rentalStatus.status, equals(RentalStatusType.available));
        expect(rentalStatus.dueDate, isNull);
        expect(rentalStatus.rentedDate, isNull);
        expect(rentalStatus.returnDate, isNull);
        expect(rentalStatus.daysRemaining, isNull);
        expect(rentalStatus.canRenew, isFalse);
        expect(rentalStatus.isInCart, isFalse);
        expect(rentalStatus.isPurchased, isFalse);
        expect(rentalStatus.lateFee, isNull);
        expect(rentalStatus.notes, isNull);
      });
    });

    group('convenience getters', () {
      test('isRented should return true for rented status', () {
        final rentedStatus = RentalStatus(
          bookId: tBookId,
          status: RentalStatusType.rented,
        );

        expect(rentedStatus.isRented, isTrue);
      });

      test('isRented should return true for dueSoon status', () {
        final dueSoonStatus = RentalStatus(
          bookId: tBookId,
          status: RentalStatusType.dueSoon,
        );

        expect(dueSoonStatus.isRented, isTrue);
      });

      test('isRented should return true for overdue status', () {
        final overdueStatus = RentalStatus(
          bookId: tBookId,
          status: RentalStatusType.overdue,
        );

        expect(overdueStatus.isRented, isTrue);
      });

      test('isRented should return false for available status', () {
        final availableStatus = RentalStatus(
          bookId: tBookId,
          status: RentalStatusType.available,
        );

        expect(availableStatus.isRented, isFalse);
      });

      test('isOverdue should return true for overdue status', () {
        final overdueStatus = RentalStatus(
          bookId: tBookId,
          status: RentalStatusType.overdue,
        );

        expect(overdueStatus.isOverdue, isTrue);
      });

      test('isOverdue should return false for non-overdue status', () {
        final rentedStatus = RentalStatus(
          bookId: tBookId,
          status: RentalStatusType.rented,
        );

        expect(rentedStatus.isOverdue, isFalse);
      });

      test('isDueSoon should return true for dueSoon status', () {
        final dueSoonStatus = RentalStatus(
          bookId: tBookId,
          status: RentalStatusType.dueSoon,
        );

        expect(dueSoonStatus.isDueSoon, isTrue);
      });

      test('isDueSoon should return false for non-dueSoon status', () {
        final rentedStatus = RentalStatus(
          bookId: tBookId,
          status: RentalStatusType.rented,
        );

        expect(rentedStatus.isDueSoon, isFalse);
      });

      test('isAvailable should return true for available status', () {
        final availableStatus = RentalStatus(
          bookId: tBookId,
          status: RentalStatusType.available,
        );

        expect(availableStatus.isAvailable, isTrue);
      });

      test('isAvailable should return false for non-available status', () {
        final rentedStatus = RentalStatus(
          bookId: tBookId,
          status: RentalStatusType.rented,
        );

        expect(rentedStatus.isAvailable, isFalse);
      });

      test('hasLateFee should return true when lateFee is positive', () {
        final statusWithFee = RentalStatus(
          bookId: tBookId,
          status: RentalStatusType.overdue,
          lateFee: 5.0,
        );

        expect(statusWithFee.hasLateFee, isTrue);
      });

      test('hasLateFee should return false when lateFee is null', () {
        final statusWithoutFee = RentalStatus(
          bookId: tBookId,
          status: RentalStatusType.rented,
        );

        expect(statusWithoutFee.hasLateFee, isFalse);
      });

      test('hasLateFee should return false when lateFee is zero', () {
        final statusWithZeroFee = RentalStatus(
          bookId: tBookId,
          status: RentalStatusType.rented,
          lateFee: 0.0,
        );

        expect(statusWithZeroFee.hasLateFee, isFalse);
      });
    });

    group('progressPercentage', () {
      test('should return correct progress percentage', () {
        // arrange - 10 days rental, 5 days remaining means 50% complete
        final rentedDate = DateTime(2023, 5, 1);
        final dueDate = DateTime(2023, 5, 11); // 10 days later
        const daysRemaining = 5;
        
        final status = RentalStatus(
          bookId: tBookId,
          status: RentalStatusType.rented,
          rentedDate: rentedDate,
          dueDate: dueDate,
          daysRemaining: daysRemaining,
        );

        // act
        final progress = status.progressPercentage;

        // assert
        expect(progress, equals(0.5)); // 50%
      });

      test('should return 0.0 when daysRemaining is null', () {
        final status = RentalStatus(
          bookId: tBookId,
          status: RentalStatusType.available,
          rentedDate: DateTime(2023, 5, 1),
          dueDate: DateTime(2023, 5, 11),
        );

        expect(status.progressPercentage, equals(0.0));
      });

      test('should return 0.0 when rentedDate is null', () {
        final status = RentalStatus(
          bookId: tBookId,
          status: RentalStatusType.rented,
          dueDate: DateTime(2023, 5, 11),
          daysRemaining: 5,
        );

        expect(status.progressPercentage, equals(0.0));
      });

      test('should return 0.0 when dueDate is null', () {
        final status = RentalStatus(
          bookId: tBookId,
          status: RentalStatusType.rented,
          rentedDate: DateTime(2023, 5, 1),
          daysRemaining: 5,
        );

        expect(status.progressPercentage, equals(0.0));
      });

      test('should return 1.0 when totalDays is zero or negative', () {
        // arrange - same day rental
        final sameDate = DateTime(2023, 5, 1);
        
        final status = RentalStatus(
          bookId: tBookId,
          status: RentalStatusType.rented,
          rentedDate: sameDate,
          dueDate: sameDate,
          daysRemaining: 0,
        );

        expect(status.progressPercentage, equals(1.0));
      });

      test('should clamp progress between 0.0 and 1.0', () {
        // arrange - overdue scenario (negative days remaining)
        final rentedDate = DateTime(2023, 5, 1);
        final dueDate = DateTime(2023, 5, 11);
        const daysRemaining = -5; // 5 days overdue
        
        final status = RentalStatus(
          bookId: tBookId,
          status: RentalStatusType.overdue,
          rentedDate: rentedDate,
          dueDate: dueDate,
          daysRemaining: daysRemaining,
        );

        final progress = status.progressPercentage;
        
        expect(progress, greaterThanOrEqualTo(0.0));
        expect(progress, lessThanOrEqualTo(1.0));
      });

      test('should handle edge case with very long rental period', () {
        // arrange - 1 year rental, 100 days remaining
        final rentedDate = DateTime(2023, 1, 1);
        final dueDate = DateTime(2024, 1, 1); // 365 days
        const daysRemaining = 100;
        
        final status = RentalStatus(
          bookId: tBookId,
          status: RentalStatusType.rented,
          rentedDate: rentedDate,
          dueDate: dueDate,
          daysRemaining: daysRemaining,
        );

        final progress = status.progressPercentage;
        
        expect(progress, greaterThan(0.0));
        expect(progress, lessThan(1.0));
      });
    });

    group('equality', () {
      test('should be equal when all properties are the same', () {
        // arrange
        final status1 = tRentalStatus;
        final status2 = RentalStatus(
          bookId: tBookId,
          status: tStatus,
          dueDate: tDueDate,
          rentedDate: tRentedDate,
          returnDate: tReturnDate,
          daysRemaining: tDaysRemaining,
          canRenew: tCanRenew,
          isInCart: tIsInCart,
          isPurchased: tIsPurchased,
          lateFee: tLateFee,
          notes: tNotes,
        );

        // assert
        expect(status1, equals(status2));
        expect(status1.hashCode, equals(status2.hashCode));
      });

      test('should not be equal when properties differ', () {
        // arrange
        final status1 = tRentalStatus;
        final status2 = RentalStatus(
          bookId: 'different_book_id',
          status: tStatus,
          dueDate: tDueDate,
          rentedDate: tRentedDate,
          returnDate: tReturnDate,
          daysRemaining: tDaysRemaining,
          canRenew: tCanRenew,
          isInCart: tIsInCart,
          isPurchased: tIsPurchased,
          lateFee: tLateFee,
          notes: tNotes,
        );

        // assert
        expect(status1, isNot(equals(status2)));
      });
    });

    group('props', () {
      test('should return correct list of properties', () {
        // act
        final props = tRentalStatus.props;

        // assert
        expect(props, equals([
          tBookId,
          tStatus,
          tDueDate,
          tRentedDate,
          tReturnDate,
          tDaysRemaining,
          tCanRenew,
          tIsInCart,
          tIsPurchased,
          tLateFee,
          tNotes,
        ]));
      });
    });

    group('edge cases', () {
      test('should handle all RentalStatusType values', () {
        for (final statusType in RentalStatusType.values) {
          final status = RentalStatus(
            bookId: tBookId,
            status: statusType,
          );

          expect(status.status, equals(statusType));
        }
      });

      test('should handle negative daysRemaining', () {
        final status = RentalStatus(
          bookId: tBookId,
          status: RentalStatusType.overdue,
          daysRemaining: -10,
        );

        expect(status.daysRemaining, equals(-10));
      });

      test('should handle zero daysRemaining', () {
        final status = RentalStatus(
          bookId: tBookId,
          status: RentalStatusType.dueSoon,
          daysRemaining: 0,
        );

        expect(status.daysRemaining, equals(0));
      });

      test('should handle negative lateFee', () {
        final status = RentalStatus(
          bookId: tBookId,
          status: RentalStatusType.overdue,
          lateFee: -5.0,
        );

        expect(status.lateFee, equals(-5.0));
        expect(status.hasLateFee, isFalse); // Only positive fees count
      });

      test('should handle very large lateFee', () {
        final status = RentalStatus(
          bookId: tBookId,
          status: RentalStatusType.overdue,
          lateFee: 999999.99,
        );

        expect(status.lateFee, equals(999999.99));
        expect(status.hasLateFee, isTrue);
      });

      test('should handle empty notes', () {
        final status = RentalStatus(
          bookId: tBookId,
          status: RentalStatusType.rented,
          notes: '',
        );

        expect(status.notes, isEmpty);
      });

      test('should handle very long notes', () {
        final longNotes = 'A' * 1000;
        final status = RentalStatus(
          bookId: tBookId,
          status: RentalStatusType.rented,
          notes: longNotes,
        );

        expect(status.notes, equals(longNotes));
        expect(status.notes!.length, equals(1000));
      });

      test('should handle special characters in notes', () {
        const specialNotes = 'Notes with special chars: àáâãäåæçèéêë & symbols !@#\$%^&*() 😀🎉';
        final status = RentalStatus(
          bookId: tBookId,
          status: RentalStatusType.rented,
          notes: specialNotes,
        );

        expect(status.notes, equals(specialNotes));
      });

      test('should handle future dates', () {
        final futureDate = DateTime(2100, 12, 31);
        final status = RentalStatus(
          bookId: tBookId,
          status: RentalStatusType.rented,
          dueDate: futureDate,
          rentedDate: futureDate,
          returnDate: futureDate,
        );

        expect(status.dueDate, equals(futureDate));
        expect(status.rentedDate, equals(futureDate));
        expect(status.returnDate, equals(futureDate));
      });

      test('should handle very old dates', () {
        final oldDate = DateTime(1900, 1, 1);
        final status = RentalStatus(
          bookId: tBookId,
          status: RentalStatusType.rented,
          dueDate: oldDate,
          rentedDate: oldDate,
          returnDate: oldDate,
        );

        expect(status.dueDate, equals(oldDate));
        expect(status.rentedDate, equals(oldDate));
        expect(status.returnDate, equals(oldDate));
      });
    });
  });
}
