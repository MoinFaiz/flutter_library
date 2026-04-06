import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/book_details/data/datasources/rental_status_remote_datasource.dart';
import 'package:flutter_library/features/book_details/data/models/rental_status_model.dart';
import 'package:flutter_library/features/book_details/domain/entities/rental_status.dart';

void main() {
  group('RentalStatusRemoteDataSourceImpl', () {
    late RentalStatusRemoteDataSourceImpl dataSource;

    setUp(() {
      dataSource = RentalStatusRemoteDataSourceImpl();
    });

    group('getRentalStatus', () {
      test('should return available status for case 0', () async {
        // Arrange - Find a bookId that results in hashCode % 5 == 0
        String bookId = 'test-book-available';
        while (bookId.hashCode % 5 != 0) {
          bookId += 'x';
        }

        // Act
        final result = await dataSource.getRentalStatus(bookId);

        // Assert
        expect(result, isA<RentalStatusModel>());
        expect(result.bookId, equals(bookId));
        expect(result.status, equals(RentalStatusType.available));
        expect(result.canRenew, isFalse);
        expect(result.isInCart, isFalse);
        expect(result.isPurchased, isFalse);
      });

      test('should return rented status for case 1', () async {
        // Arrange - Find a bookId that results in hashCode % 5 == 1
        String bookId = 'test-book-rented';
        while (bookId.hashCode % 5 != 1) {
          bookId += 'x';
        }

        // Act
        final result = await dataSource.getRentalStatus(bookId);

        // Assert
        expect(result, isA<RentalStatusModel>());
        expect(result.bookId, equals(bookId));
        expect(result.status, equals(RentalStatusType.rented));
        expect(result.canRenew, isTrue);
        expect(result.isInCart, isFalse);
        expect(result.isPurchased, isFalse);
        expect(result.dueDate, isNotNull);
        expect(result.rentedDate, isNotNull);
        expect(result.daysRemaining, equals(7));
      });

      test('should return overdue status for case 2', () async {
        // Arrange - Find a bookId that results in hashCode % 5 == 2
        String bookId = 'test-book-overdue';
        while (bookId.hashCode % 5 != 2) {
          bookId += 'x';
        }

        // Act
        final result = await dataSource.getRentalStatus(bookId);

        // Assert
        expect(result, isA<RentalStatusModel>());
        expect(result.bookId, equals(bookId));
        expect(result.status, equals(RentalStatusType.overdue));
        expect(result.canRenew, isFalse);
        expect(result.isInCart, isFalse);
        expect(result.isPurchased, isFalse);
        expect(result.dueDate, isNotNull);
        expect(result.rentedDate, isNotNull);
        expect(result.daysRemaining, equals(-2));
        expect(result.lateFee, equals(5.50));
      });

      test('should return in cart status for case 3', () async {
        // Arrange - Find a bookId that results in hashCode % 5 == 3
        String bookId = 'test-book-cart';
        while (bookId.hashCode % 5 != 3) {
          bookId += 'x';
        }

        // Act
        final result = await dataSource.getRentalStatus(bookId);

        // Assert
        expect(result, isA<RentalStatusModel>());
        expect(result.bookId, equals(bookId));
        expect(result.status, equals(RentalStatusType.available));
        expect(result.canRenew, isFalse);
        expect(result.isInCart, isTrue);
        expect(result.isPurchased, isFalse);
      });

      test('should return purchased status for case 4', () async {
        // Arrange - Find a bookId that results in hashCode % 5 == 4
        String bookId = 'test-book-purchased';
        while (bookId.hashCode % 5 != 4) {
          bookId += 'x';
        }

        // Act
        final result = await dataSource.getRentalStatus(bookId);

        // Assert
        expect(result, isA<RentalStatusModel>());
        expect(result.bookId, equals(bookId));
        expect(result.status, equals(RentalStatusType.purchased));
        expect(result.canRenew, isFalse);
        expect(result.isInCart, isFalse);
        expect(result.isPurchased, isTrue);
      });

      test('should handle default case', () async {
        // Arrange - Use a specific bookId to test default case behavior
        const bookId = 'default-case-test';

        // Act
        final result = await dataSource.getRentalStatus(bookId);

        // Assert
        expect(result, isA<RentalStatusModel>());
        expect(result.bookId, equals(bookId));
        expect(result.status, isA<RentalStatusType>());
        expect(result.canRenew, isA<bool>());
        expect(result.isInCart, isA<bool>());
        expect(result.isPurchased, isA<bool>());
      });

      test('should handle empty bookId', () async {
        // Arrange
        const bookId = '';

        // Act
        final result = await dataSource.getRentalStatus(bookId);

        // Assert
        expect(result, isA<RentalStatusModel>());
        expect(result.bookId, equals(bookId));
      });

      test('should simulate network delay', () async {
        // Arrange
        const bookId = 'test-delay';
        final stopwatch = Stopwatch()..start();

        // Act
        await dataSource.getRentalStatus(bookId);

        // Assert
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(600));
      });
    });

    group('getRentalStatusBatch', () {
      test('should return status for multiple books', () async {
        // Arrange
        const bookIds = ['book1', 'book2', 'book3'];

        // Act
        final results = await dataSource.getRentalStatusBatch(bookIds);

        // Assert
        expect(results, hasLength(3));
        expect(results[0].bookId, equals('book1'));
        expect(results[1].bookId, equals('book2'));
        expect(results[2].bookId, equals('book3'));
        
        for (final result in results) {
          expect(result, isA<RentalStatusModel>());
          expect(result.status, isA<RentalStatusType>());
        }
      });

      test('should handle empty list', () async {
        // Arrange
        const bookIds = <String>[];

        // Act
        final results = await dataSource.getRentalStatusBatch(bookIds);

        // Assert
        expect(results, isEmpty);
      });

      test('should handle single book', () async {
        // Arrange
        const bookIds = ['single-book'];

        // Act
        final results = await dataSource.getRentalStatusBatch(bookIds);

        // Assert
        expect(results, hasLength(1));
        expect(results[0].bookId, equals('single-book'));
      });

      test('should simulate network delay for batch operation', () async {
        // Arrange
        const bookIds = ['book1', 'book2'];
        final stopwatch = Stopwatch()..start();

        // Act
        await dataSource.getRentalStatusBatch(bookIds);

        // Assert
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(800));
      });

      test('should handle large batch', () async {
        // Arrange
        final bookIds = List.generate(10, (index) => 'book$index');

        // Act
        final results = await dataSource.getRentalStatusBatch(bookIds);

        // Assert
        expect(results, hasLength(10));
        for (int i = 0; i < results.length; i++) {
          expect(results[i].bookId, equals('book$i'));
        }
      });
    });

    group('updateRentalStatus', () {
      test('should return updated rental status', () async {
        // Arrange
        final inputStatus = RentalStatusModel(
          bookId: 'test-book',
          status: RentalStatusType.rented,
          dueDate: DateTime.now().add(const Duration(days: 14)),
          rentedDate: DateTime.now(),
          daysRemaining: 14,
          canRenew: true,
          isInCart: false,
          isPurchased: false,
        );

        // Act
        final result = await dataSource.updateRentalStatus(inputStatus);

        // Assert
        expect(result, equals(inputStatus));
        expect(result.bookId, equals('test-book'));
        expect(result.status, equals(RentalStatusType.rented));
        expect(result.canRenew, isTrue);
      });

      test('should handle status update with late fee', () async {
        // Arrange
        final inputStatus = RentalStatusModel(
          bookId: 'overdue-book',
          status: RentalStatusType.overdue,
          dueDate: DateTime.now().subtract(const Duration(days: 5)),
          rentedDate: DateTime.now().subtract(const Duration(days: 19)),
          daysRemaining: -5,
          canRenew: false,
          isInCart: false,
          isPurchased: false,
          lateFee: 12.50,
        );

        // Act
        final result = await dataSource.updateRentalStatus(inputStatus);

        // Assert
        expect(result, equals(inputStatus));
        expect(result.lateFee, equals(12.50));
        expect(result.status, equals(RentalStatusType.overdue));
      });

      test('should handle purchased status update', () async {
        // Arrange
        final inputStatus = RentalStatusModel(
          bookId: 'purchased-book',
          status: RentalStatusType.purchased,
          canRenew: false,
          isInCart: false,
          isPurchased: true,
        );

        // Act
        final result = await dataSource.updateRentalStatus(inputStatus);

        // Assert
        expect(result, equals(inputStatus));
        expect(result.isPurchased, isTrue);
        expect(result.status, equals(RentalStatusType.purchased));
      });

      test('should simulate network delay for update', () async {
        // Arrange
        final inputStatus = RentalStatusModel(
          bookId: 'test-delay',
          status: RentalStatusType.available,
          canRenew: false,
          isInCart: false,
          isPurchased: false,
        );
        final stopwatch = Stopwatch()..start();

        // Act
        await dataSource.updateRentalStatus(inputStatus);

        // Assert
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(500));
      });
    });

    group('Edge Cases and Integration', () {
      test('should handle rapid successive calls', () async {
        // Arrange
        const bookId = 'rapid-test';

        // Act
        final futures = List.generate(3, (_) => dataSource.getRentalStatus(bookId));
        final results = await Future.wait(futures);

        // Assert
        expect(results, hasLength(3));
        for (final result in results) {
          expect(result.bookId, equals(bookId));
          expect(result, isA<RentalStatusModel>());
        }
      });

      test('should maintain consistency across multiple calls for same book', () async {
        // Arrange
        const bookId = 'consistency-test';

        // Act
        final result1 = await dataSource.getRentalStatus(bookId);
        final result2 = await dataSource.getRentalStatus(bookId);

        // Assert
        expect(result1.bookId, equals(result2.bookId));
        expect(result1.status, equals(result2.status));
        expect(result1.canRenew, equals(result2.canRenew));
        expect(result1.isInCart, equals(result2.isInCart));
        expect(result1.isPurchased, equals(result2.isPurchased));
      });

      test('should handle special characters in book ID', () async {
        // Arrange
        const bookId = 'book-with-special-chars!@#\$%^&*()';

        // Act
        final result = await dataSource.getRentalStatus(bookId);

        // Assert
        expect(result, isA<RentalStatusModel>());
        expect(result.bookId, equals(bookId));
      });

      test('should handle very long book ID', () async {
        // Arrange
        final bookId = 'very-long-book-id-${'x' * 100}';

        // Act
        final result = await dataSource.getRentalStatus(bookId);

        // Assert
        expect(result, isA<RentalStatusModel>());
        expect(result.bookId, equals(bookId));
      });
    });
  });
}
