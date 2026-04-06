import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/book_details/data/models/rental_status_model.dart';
import 'package:flutter_library/features/book_details/domain/entities/rental_status.dart';

void main() {
  group('RentalStatusModel', () {
    final testDueDate = DateTime(2023, 2, 15, 23, 59, 59);
    final testRentedDate = DateTime(2023, 1, 15, 10, 30, 0);
    
    final testRentalStatusModel = RentalStatusModel(
      bookId: 'book_1',
      status: RentalStatusType.rented,
      dueDate: testDueDate,
      rentedDate: testRentedDate,
      returnDate: null,
      daysRemaining: 5,
      canRenew: true,
      isInCart: false,
      isPurchased: false,
      lateFee: 0.0,
      notes: 'Book in good condition',
    );

    final testJson = {
      'bookId': 'book_1',
      'status': 'rented',
      'dueDate': '2023-02-15T23:59:59.000',
      'rentedDate': '2023-01-15T10:30:00.000',
      'returnDate': null,
      'daysRemaining': 5,
      'canRenew': true,
      'isInCart': false,
      'isPurchased': false,
      'lateFee': 0.0,
      'notes': 'Book in good condition',
    };

    group('Entity Extension', () {
      test('should be a subclass of RentalStatus entity', () {
        expect(testRentalStatusModel, isA<RentalStatus>());
      });

      test('should have correct properties from parent entity', () {
        expect(testRentalStatusModel.bookId, equals('book_1'));
        expect(testRentalStatusModel.status, equals(RentalStatusType.rented));
        expect(testRentalStatusModel.dueDate, equals(testDueDate));
        expect(testRentalStatusModel.rentedDate, equals(testRentedDate));
        expect(testRentalStatusModel.returnDate, isNull);
        expect(testRentalStatusModel.daysRemaining, equals(5));
        expect(testRentalStatusModel.canRenew, isTrue);
        expect(testRentalStatusModel.isInCart, isFalse);
        expect(testRentalStatusModel.isPurchased, isFalse);
        expect(testRentalStatusModel.lateFee, equals(0.0));
        expect(testRentalStatusModel.notes, equals('Book in good condition'));
      });
    });

    group('fromJson', () {
      test('should return a valid RentalStatusModel from JSON', () {
        // act
        final result = RentalStatusModel.fromJson(testJson);

        // assert
        expect(result, isA<RentalStatusModel>());
        expect(result.bookId, equals('book_1'));
        expect(result.status, equals(RentalStatusType.rented));
        expect(result.dueDate, equals(testDueDate));
        expect(result.rentedDate, equals(testRentedDate));
        expect(result.returnDate, isNull);
        expect(result.daysRemaining, equals(5));
        expect(result.canRenew, isTrue);
        expect(result.isInCart, isFalse);
        expect(result.isPurchased, isFalse);
        expect(result.lateFee, equals(0.0));
        expect(result.notes, equals('Book in good condition'));
      });

      test('should handle available status', () {
        // arrange
        final jsonWithAvailableStatus = Map<String, dynamic>.from(testJson);
        jsonWithAvailableStatus['status'] = 'available';

        // act
        final result = RentalStatusModel.fromJson(jsonWithAvailableStatus);

        // assert
        expect(result.status, equals(RentalStatusType.available));
      });

      test('should handle inCart status', () {
        // arrange
        final jsonWithInCartStatus = Map<String, dynamic>.from(testJson);
        jsonWithInCartStatus['status'] = 'inCart';

        // act
        final result = RentalStatusModel.fromJson(jsonWithInCartStatus);

        // assert
        expect(result.status, equals(RentalStatusType.inCart));
      });

      test('should handle unavailable status', () {
        // arrange
        final jsonWithUnavailableStatus = Map<String, dynamic>.from(testJson);
        jsonWithUnavailableStatus['status'] = 'unavailable';

        // act
        final result = RentalStatusModel.fromJson(jsonWithUnavailableStatus);

        // assert
        expect(result.status, equals(RentalStatusType.unavailable));
      });

      test('should handle null optional fields with default values', () {
        // arrange
        final minimalJson = {
          'bookId': 'book_1',
          'status': 'available',
        };

        // act
        final result = RentalStatusModel.fromJson(minimalJson);

        // assert
        expect(result.bookId, equals('book_1'));
        expect(result.status, equals(RentalStatusType.available));
        expect(result.dueDate, isNull);
        expect(result.rentedDate, isNull);
        expect(result.returnDate, isNull);
        expect(result.daysRemaining, isNull);
        expect(result.canRenew, isFalse);
        expect(result.isInCart, isFalse);
        expect(result.isPurchased, isFalse);
        expect(result.lateFee, isNull);
        expect(result.notes, isNull);
      });

      test('should handle purchased status when provided', () {
        // arrange
        final jsonWithPurchasedStatus = Map<String, dynamic>.from(testJson);
        jsonWithPurchasedStatus['status'] = 'purchased';
        jsonWithPurchasedStatus['returnDate'] = null;

        // act
        final result = RentalStatusModel.fromJson(jsonWithPurchasedStatus);

        // assert
        expect(result.status, equals(RentalStatusType.purchased));
        expect(result.returnDate, isNull);
      });

      test('should handle dueSoon status', () {
        // arrange
        final jsonWithDueSoonStatus = Map<String, dynamic>.from(testJson);
        jsonWithDueSoonStatus['status'] = 'duesoon';
        jsonWithDueSoonStatus['daysRemaining'] = 2;

        // act
        final result = RentalStatusModel.fromJson(jsonWithDueSoonStatus);

        // assert
        expect(result.status, equals(RentalStatusType.dueSoon));
        expect(result.daysRemaining, equals(2));
      });

      test('should handle overdue status', () {
        // arrange
        final jsonWithOverdueStatus = Map<String, dynamic>.from(testJson);
        jsonWithOverdueStatus['status'] = 'overdue';
        jsonWithOverdueStatus['daysRemaining'] = -3;
        jsonWithOverdueStatus['lateFee'] = 5.50;

        // act
        final result = RentalStatusModel.fromJson(jsonWithOverdueStatus);

        // assert
        expect(result.status, equals(RentalStatusType.overdue));
        expect(result.daysRemaining, equals(-3));
        expect(result.lateFee, equals(5.50));
      });

      test('should handle invalid status by defaulting to available', () {
        // arrange
        final jsonWithInvalidStatus = Map<String, dynamic>.from(testJson);
        jsonWithInvalidStatus['status'] = 'invalid_status';

        // act
        final result = RentalStatusModel.fromJson(jsonWithInvalidStatus);

        // assert
        expect(result.status, equals(RentalStatusType.available));
      });

      test('should throw when required fields are missing', () {
        // arrange
        final incompleteJson = <String, dynamic>{
          'bookId': 'book_1',
          // missing status
        };

        // act & assert
        expect(() => RentalStatusModel.fromJson(incompleteJson), throwsA(isA<TypeError>()));
      });

      test('should throw when date strings are invalid', () {
        // arrange
        final jsonWithInvalidDate = Map<String, dynamic>.from(testJson);
        jsonWithInvalidDate['dueDate'] = 'invalid-date';

        // act & assert
        expect(() => RentalStatusModel.fromJson(jsonWithInvalidDate), throwsA(isA<FormatException>()));
      });
    });

    group('toJson', () {
      test('should return a valid JSON map', () {
        // act
        final result = testRentalStatusModel.toJson();

        // assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['bookId'], equals('book_1'));
        expect(result['status'], equals('rented'));
        expect(result['dueDate'], equals('2023-02-15T23:59:59.000'));
        expect(result['rentedDate'], equals('2023-01-15T10:30:00.000'));
        expect(result['returnDate'], isNull);
        expect(result['daysRemaining'], equals(5));
        expect(result['canRenew'], isTrue);
        expect(result['isInCart'], isFalse);
        expect(result['isPurchased'], isFalse);
        expect(result['lateFee'], equals(0.0));
        expect(result['notes'], equals('Book in good condition'));
      });

      test('should maintain data integrity in round-trip conversion', () {
        // act
        final json = testRentalStatusModel.toJson();
        final reconstructed = RentalStatusModel.fromJson(json);

        // assert
        expect(reconstructed.bookId, equals(testRentalStatusModel.bookId));
        expect(reconstructed.status, equals(testRentalStatusModel.status));
        expect(reconstructed.dueDate, equals(testRentalStatusModel.dueDate));
        expect(reconstructed.rentedDate, equals(testRentalStatusModel.rentedDate));
        expect(reconstructed.returnDate, equals(testRentalStatusModel.returnDate));
        expect(reconstructed.daysRemaining, equals(testRentalStatusModel.daysRemaining));
        expect(reconstructed.canRenew, equals(testRentalStatusModel.canRenew));
        expect(reconstructed.isInCart, equals(testRentalStatusModel.isInCart));
        expect(reconstructed.isPurchased, equals(testRentalStatusModel.isPurchased));
        expect(reconstructed.lateFee, equals(testRentalStatusModel.lateFee));
        expect(reconstructed.notes, equals(testRentalStatusModel.notes));
      });

      test('should correctly serialize dueSoon status to JSON', () {
        // arrange
        final dueSoonModel = RentalStatusModel(
          bookId: 'book_2',
          status: RentalStatusType.dueSoon,
          dueDate: DateTime.parse('2023-02-12T23:59:59.000'),
          rentedDate: DateTime.parse('2023-01-15T10:30:00.000'),
          daysRemaining: 2,
          canRenew: true,
        );

        // act
        final result = dueSoonModel.toJson();

        // assert
        expect(result['status'], equals('duesoon'));
        expect(result['daysRemaining'], equals(2));
      });

      test('should handle model with overdue status', () {
        // arrange
        final statusWithOverdue = RentalStatusModel(
          bookId: 'book_1',
          status: RentalStatusType.overdue,
          dueDate: testDueDate,
          rentedDate: testRentedDate,
          returnDate: null,
          daysRemaining: -3,
          canRenew: false,
          isInCart: false,
          isPurchased: false,
          lateFee: 2.50,
          notes: 'Book is overdue',
        );

        // act
        final result = statusWithOverdue.toJson();

        // assert
        expect(result['status'], equals('overdue'));
        expect(result['returnDate'], isNull);
        expect(result['daysRemaining'], equals(-3));
        expect(result['lateFee'], equals(2.50));
        expect(result['notes'], equals('Book is overdue'));
      });
    });

    group('copyWith', () {
      test('should create a copy with updated bookId', () {
        // act
        final result = testRentalStatusModel.copyWith(bookId: 'book_999');

        // assert
        expect(result.bookId, equals('book_999'));
        expect(result.status, equals(testRentalStatusModel.status));
        expect(result.dueDate, equals(testRentalStatusModel.dueDate));
      });

      test('should create a copy with updated status', () {
        // act
        final result = testRentalStatusModel.copyWith(status: RentalStatusType.overdue);

        // assert
        expect(result.status, equals(RentalStatusType.overdue));
        expect(result.bookId, equals(testRentalStatusModel.bookId));
      });

      test('should create a copy with updated dueDate', () {
        // arrange
        final newDueDate = DateTime.parse('2023-03-01T23:59:59.000');

        // act
        final result = testRentalStatusModel.copyWith(dueDate: newDueDate);

        // assert
        expect(result.dueDate, equals(newDueDate));
        expect(result.bookId, equals(testRentalStatusModel.bookId));
      });

      test('should create a copy with updated rentedDate', () {
        // arrange
        final newRentedDate = DateTime.parse('2023-01-20T10:00:00.000');

        // act
        final result = testRentalStatusModel.copyWith(rentedDate: newRentedDate);

        // assert
        expect(result.rentedDate, equals(newRentedDate));
      });

      test('should create a copy with updated returnDate', () {
        // arrange
        final newReturnDate = DateTime.parse('2023-02-16T10:00:00.000');

        // act
        final result = testRentalStatusModel.copyWith(returnDate: newReturnDate);

        // assert
        expect(result.returnDate, equals(newReturnDate));
      });

      test('should create a copy with updated daysRemaining', () {
        // act
        final result = testRentalStatusModel.copyWith(daysRemaining: 10);

        // assert
        expect(result.daysRemaining, equals(10));
      });

      test('should create a copy with updated canRenew', () {
        // act
        final result = testRentalStatusModel.copyWith(canRenew: false);

        // assert
        expect(result.canRenew, isFalse);
      });

      test('should create a copy with updated isInCart', () {
        // act
        final result = testRentalStatusModel.copyWith(isInCart: true);

        // assert
        expect(result.isInCart, isTrue);
      });

      test('should create a copy with updated isPurchased', () {
        // act
        final result = testRentalStatusModel.copyWith(isPurchased: true);

        // assert
        expect(result.isPurchased, isTrue);
      });

      test('should create a copy with updated lateFee', () {
        // act
        final result = testRentalStatusModel.copyWith(lateFee: 10.50);

        // assert
        expect(result.lateFee, equals(10.50));
      });

      test('should create a copy with updated notes', () {
        // act
        final result = testRentalStatusModel.copyWith(notes: 'Updated notes');

        // assert
        expect(result.notes, equals('Updated notes'));
      });

      test('should keep original values when no parameters provided', () {
        // act
        final result = testRentalStatusModel.copyWith();

        // assert
        expect(result.bookId, equals(testRentalStatusModel.bookId));
        expect(result.status, equals(testRentalStatusModel.status));
        expect(result.dueDate, equals(testRentalStatusModel.dueDate));
        expect(result.rentedDate, equals(testRentalStatusModel.rentedDate));
        expect(result.returnDate, equals(testRentalStatusModel.returnDate));
        expect(result.daysRemaining, equals(testRentalStatusModel.daysRemaining));
        expect(result.canRenew, equals(testRentalStatusModel.canRenew));
        expect(result.isInCart, equals(testRentalStatusModel.isInCart));
        expect(result.isPurchased, equals(testRentalStatusModel.isPurchased));
        expect(result.lateFee, equals(testRentalStatusModel.lateFee));
        expect(result.notes, equals(testRentalStatusModel.notes));
      });
    });

    group('Equality', () {
      test('should be equal to another RentalStatusModel with same values', () {
        // arrange
        final otherRentalStatusModel = RentalStatusModel(
          bookId: 'book_1',
          status: RentalStatusType.rented,
          dueDate: testDueDate,
          rentedDate: testRentedDate,
          returnDate: null,
          daysRemaining: 5,
          canRenew: true,
          isInCart: false,
          isPurchased: false,
          lateFee: 0.0,
          notes: 'Book in good condition',
        );

        // act & assert
        expect(testRentalStatusModel, equals(otherRentalStatusModel));
        expect(testRentalStatusModel.hashCode, equals(otherRentalStatusModel.hashCode));
      });

      test('should not be equal to RentalStatusModel with different values', () {
        // arrange
        final differentRentalStatusModel = RentalStatusModel(
          bookId: 'book_2', // different bookId
          status: RentalStatusType.rented,
          dueDate: testDueDate,
          rentedDate: testRentedDate,
          returnDate: null,
          daysRemaining: 5,
          canRenew: true,
          isInCart: false,
          isPurchased: false,
          lateFee: 0.0,
          notes: 'Book in good condition',
        );

        // act & assert
        expect(testRentalStatusModel, isNot(equals(differentRentalStatusModel)));
      });
    });

    group('Edge Cases', () {
      test('should handle negative days remaining', () {
        // arrange
        final jsonWithNegativeDays = Map<String, dynamic>.from(testJson);
        jsonWithNegativeDays['daysRemaining'] = -3;

        // act
        final result = RentalStatusModel.fromJson(jsonWithNegativeDays);

        // assert
        expect(result.daysRemaining, equals(-3));
      });

      test('should handle high late fee', () {
        // arrange
        final jsonWithHighFee = Map<String, dynamic>.from(testJson);
        jsonWithHighFee['lateFee'] = 99.99;

        // act
        final result = RentalStatusModel.fromJson(jsonWithHighFee);

        // assert
        expect(result.lateFee, equals(99.99));
      });

      test('should handle uppercase status strings', () {
        // arrange
        final testStatuses = {
          'AVAILABLE': RentalStatusType.available,
          'RENTED': RentalStatusType.rented,
          'DUESOON': RentalStatusType.dueSoon,
          'OVERDUE': RentalStatusType.overdue,
          'INCART': RentalStatusType.inCart,
          'PURCHASED': RentalStatusType.purchased,
          'UNAVAILABLE': RentalStatusType.unavailable,
        };

        for (final entry in testStatuses.entries) {
          final jsonWithStatus = Map<String, dynamic>.from(testJson);
          jsonWithStatus['status'] = entry.key;

          // act
          final result = RentalStatusModel.fromJson(jsonWithStatus);

          // assert
          expect(result.status, equals(entry.value),
              reason: 'Status ${entry.key} should map to ${entry.value}');
        }
      });

      test('should handle mixed case status strings', () {
        // arrange
        final testStatuses = {
          'Available': RentalStatusType.available,
          'Rented': RentalStatusType.rented,
          'DueSoon': RentalStatusType.dueSoon,
          'OverDue': RentalStatusType.overdue,
          'InCart': RentalStatusType.inCart,
          'Purchased': RentalStatusType.purchased,
          'UnAvailable': RentalStatusType.unavailable,
        };

        for (final entry in testStatuses.entries) {
          final jsonWithStatus = Map<String, dynamic>.from(testJson);
          jsonWithStatus['status'] = entry.key;

          // act
          final result = RentalStatusModel.fromJson(jsonWithStatus);

          // assert
          expect(result.status, equals(entry.value),
              reason: 'Status ${entry.key} should map to ${entry.value}');
        }
      });

      test('should handle all RentalStatusType values in toJson', () {
        // arrange & act & assert
        final statusMappings = {
          RentalStatusType.available: 'available',
          RentalStatusType.rented: 'rented',
          RentalStatusType.dueSoon: 'duesoon',
          RentalStatusType.overdue: 'overdue',
          RentalStatusType.inCart: 'incart',
          RentalStatusType.purchased: 'purchased',
          RentalStatusType.unavailable: 'unavailable',
        };

        for (final entry in statusMappings.entries) {
          final model = RentalStatusModel(
            bookId: 'test_book',
            status: entry.key,
          );

          final json = model.toJson();

          expect(json['status'], equals(entry.value),
              reason: 'Status ${entry.key} should serialize to ${entry.value}');
        }
      });

      test('should handle zero late fee', () {
        // arrange
        final jsonWithZeroFee = Map<String, dynamic>.from(testJson);
        jsonWithZeroFee['lateFee'] = 0.0;

        // act
        final result = RentalStatusModel.fromJson(jsonWithZeroFee);

        // assert
        expect(result.lateFee, equals(0.0));
      });

      test('should handle very long notes', () {
        // arrange
        final longNotes = 'A' * 1000;
        final jsonWithLongNotes = Map<String, dynamic>.from(testJson);
        jsonWithLongNotes['notes'] = longNotes;

        // act
        final result = RentalStatusModel.fromJson(jsonWithLongNotes);

        // assert
        expect(result.notes, equals(longNotes));
        expect(result.notes!.length, equals(1000));
      });

      test('should handle empty notes string', () {
        // arrange
        final jsonWithEmptyNotes = Map<String, dynamic>.from(testJson);
        jsonWithEmptyNotes['notes'] = '';

        // act
        final result = RentalStatusModel.fromJson(jsonWithEmptyNotes);

        // assert
        expect(result.notes, equals(''));
      });
    });
  });
}
