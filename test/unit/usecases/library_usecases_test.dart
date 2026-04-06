import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_library/features/library/domain/usecases/get_uploaded_books_usecase.dart';
import 'package:flutter_library/features/library/domain/usecases/get_borrowed_books_usecase.dart';
import 'package:flutter_library/features/library/domain/repositories/library_repository.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';
import 'package:flutter_library/core/error/failures.dart';

class MockLibraryRepository extends Mock implements LibraryRepository {}

void main() {
  group('Library Use Cases Tests', () {
    late MockLibraryRepository mockRepository;

    setUp(() {
      mockRepository = MockLibraryRepository();
    });

    final mockUploadedBook = Book(
      id: 'uploaded_book_1',
      title: 'My Uploaded Book',
      author: 'Test Author',
      description: 'Book I uploaded',
      imageUrls: const ['uploaded.jpg'],
      rating: 4.2,
      pricing: const BookPricing(
        salePrice: 19.99,
        rentPrice: 4.99,
      ),
      availability: const BookAvailability(
        totalCopies: 5,
        availableForRentCount: 3,
        availableForSaleCount: 2,
      ),
      metadata: const BookMetadata(
        ageAppropriateness: AgeAppropriateness.adult,
        genres: ['Fiction', 'Drama'],
        pageCount: 250,
        language: 'English',
      ),
      isFavorite: false,
      isFromFriend: false,
      publishedYear: 2024,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final mockBorrowedBook = Book(
      id: 'borrowed_book_1',
      title: 'Borrowed Book',
      author: 'Another Author',
      description: 'Book I borrowed',
      imageUrls: const ['borrowed.jpg'],
      rating: 4.7,
      pricing: const BookPricing(
        salePrice: 29.99,
        rentPrice: 7.99,
      ),
      availability: const BookAvailability(
        totalCopies: 2,
        availableForRentCount: 0,
        availableForSaleCount: 1,
      ),
      metadata: const BookMetadata(
        ageAppropriateness: AgeAppropriateness.youngAdult,
        genres: ['Mystery', 'Thriller'],
        pageCount: 320,
        language: 'English',
      ),
      isFavorite: true,
      isFromFriend: false,
      publishedYear: 2023,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    group('GetUploadedBooksUseCase', () {
      late GetUploadedBooksUseCase useCase;

      setUp(() {
        useCase = GetUploadedBooksUseCase(mockRepository);
      });

      test('should return list of uploaded books when repository call is successful', () async {
        // Arrange
        final uploadedBooks = [mockUploadedBook];
        when(() => mockRepository.getUploadedBooks(page: 1, limit: 10))
            .thenAnswer((_) async => Right(uploadedBooks));

        // Act
        final result = await useCase(page: 1, limit: 10);

        // Assert
        expect(result, Right(uploadedBooks));
        verify(() => mockRepository.getUploadedBooks(page: 1, limit: 10)).called(1);
      });

      test('should return empty list when user has no uploaded books', () async {
        // Arrange
        when(() => mockRepository.getUploadedBooks(page: 1, limit: 10))
            .thenAnswer((_) async => const Right([]));

        // Act
        final result = await useCase(page: 1, limit: 10);

        // Assert
        expect(result, equals(const Right(<Book>[])));
      });

      test('should handle pagination correctly', () async {
        // Arrange
        final page1Books = [mockUploadedBook];
        final page2Books = <Book>[];

        when(() => mockRepository.getUploadedBooks(page: 1, limit: 5))
            .thenAnswer((_) async => Right(page1Books));
        when(() => mockRepository.getUploadedBooks(page: 2, limit: 5))
            .thenAnswer((_) async => Right(page2Books));

        // Act
        final result1 = await useCase(page: 1, limit: 5);
        final result2 = await useCase(page: 2, limit: 5);

        // Assert
        expect(result1, Right(page1Books));
        expect(result2, Right(page2Books));
      });

      test('should return failure when repository call fails', () async {
        // Arrange
        when(() => mockRepository.getUploadedBooks(page: 1, limit: 10))
            .thenAnswer((_) async => const Left(ServerFailure()));

        // Act
        final result = await useCase(page: 1, limit: 10);

        // Assert
        expect(result, const Left(ServerFailure()));
      });

      test('should handle network failures gracefully', () async {
        // Arrange
        when(() => mockRepository.getUploadedBooks(page: 1, limit: 10))
            .thenAnswer((_) async => const Left(NetworkFailure()));

        // Act
        final result = await useCase(page: 1, limit: 10);

        // Assert
        expect(result, const Left(NetworkFailure()));
      });

      test('should handle validation failures for invalid parameters', () async {
        // Arrange
        when(() => mockRepository.getUploadedBooks(page: 0, limit: 10))
            .thenAnswer((_) async => const Left(ValidationFailure('Page must be greater than 0')));

        // Act
        final result = await useCase(page: 0, limit: 10);

        // Assert
        expect(result, const Left(ValidationFailure('Page must be greater than 0')));
      });

      test('should use default parameters when not specified', () async {
        // Arrange
        when(() => mockRepository.getUploadedBooks(page: 1, limit: 20))
            .thenAnswer((_) async => Right([mockUploadedBook]));

        // Act
        final result = await useCase();

        // Assert
        expect(result, isA<Right<Failure, List<Book>>>());
        verify(() => mockRepository.getUploadedBooks(page: 1, limit: 20)).called(1);
      });
    });

    group('GetBorrowedBooksUseCase', () {
      late GetBorrowedBooksUseCase useCase;

      setUp(() {
        useCase = GetBorrowedBooksUseCase(mockRepository);
      });

      test('should return list of borrowed books when repository call is successful', () async {
        // Arrange
        final borrowedBooks = [mockBorrowedBook];
        when(() => mockRepository.getBorrowedBooks(page: 1, limit: 10))
            .thenAnswer((_) async => Right(borrowedBooks));

        // Act
        final result = await useCase(page: 1, limit: 10);

        // Assert
        expect(result, Right(borrowedBooks));
        verify(() => mockRepository.getBorrowedBooks(page: 1, limit: 10)).called(1);
      });

      test('should return empty list when user has no borrowed books', () async {
        // Arrange
        when(() => mockRepository.getBorrowedBooks(page: 1, limit: 10))
            .thenAnswer((_) async => const Right([]));

        // Act
        final result = await useCase(page: 1, limit: 10);

        // Assert
        expect(result, equals(const Right(<Book>[])));
      });

      test('should filter borrowed books by page', () async {
        // Arrange
        when(() => mockRepository.getBorrowedBooks(page: 1, limit: 10))
            .thenAnswer((_) async => Right([mockBorrowedBook]));

        // Act
        final result = await useCase(page: 1, limit: 10);

        // Assert
        expect(result, isA<Right<Failure, List<Book>>>());
        expect(result.fold((_) => [], (books) => books), equals([mockBorrowedBook]));
        verify(() => mockRepository.getBorrowedBooks(page: 1, limit: 10)).called(1);
      });

      test('should handle different pages correctly', () async {
        // Arrange
        when(() => mockRepository.getBorrowedBooks(page: 2, limit: 10))
            .thenAnswer((_) async => const Right([]));

        // Act
        final result = await useCase(page: 2, limit: 10);

        // Assert
        expect(result, equals(const Right(<Book>[])));
      });

      test('should return failure when repository call fails', () async {
        // Arrange
        when(() => mockRepository.getBorrowedBooks(page: 1, limit: 10))
            .thenAnswer((_) async => const Left(ServerFailure()));

        // Act
        final result = await useCase(page: 1, limit: 10);

        // Assert
        expect(result, const Left(ServerFailure()));
      });

      test('should handle authentication failures', () async {
        // Arrange
        when(() => mockRepository.getBorrowedBooks(page: 1, limit: 10))
            .thenAnswer((_) async => const Left(AuthenticationFailure()));

        // Act
        final result = await useCase(page: 1, limit: 10);

        // Assert
        expect(result, const Left(AuthenticationFailure()));
      });

      test('should handle cache failures gracefully', () async {
        // Arrange
        when(() => mockRepository.getBorrowedBooks(page: 1, limit: 10))
            .thenAnswer((_) async => const Left(CacheFailure('Cache error')));

        // Act
        final result = await useCase(page: 1, limit: 10);

        // Assert
        expect(result, const Left(CacheFailure('Cache error')));
      });

      test('should use default parameters when not specified', () async {
        // Arrange
        when(() => mockRepository.getBorrowedBooks(page: 1, limit: 20))
            .thenAnswer((_) async => Right([mockBorrowedBook]));

        // Act
        final result = await useCase();

        // Assert
        expect(result, isA<Right<Failure, List<Book>>>());
        verify(() => mockRepository.getBorrowedBooks(page: 1, limit: 20)).called(1);
      });
    });

    group('GetAllUploadedBooksUseCase', () {
      late GetAllUploadedBooksUseCase useCase;

      setUp(() {
        useCase = GetAllUploadedBooksUseCase(mockRepository);
      });

      test('should return all uploaded books when repository call is successful', () async {
        // Arrange
        final allUploadedBooks = [mockUploadedBook, mockUploadedBook];
        when(() => mockRepository.getAllUploadedBooks())
            .thenAnswer((_) async => Right(allUploadedBooks));

        // Act
        final result = await useCase();

        // Assert
        expect(result, Right(allUploadedBooks));
        verify(() => mockRepository.getAllUploadedBooks()).called(1);
      });

      test('should return empty list when user has no uploaded books', () async {
        // Arrange
        when(() => mockRepository.getAllUploadedBooks())
            .thenAnswer((_) async => const Right([]));

        // Act
        final result = await useCase();

        // Assert
        expect(result, equals(const Right(<Book>[])));
      });

      test('should handle large datasets efficiently', () async {
        // Arrange
        final largeBookList = List.generate(1000, (index) => mockUploadedBook);
        when(() => mockRepository.getAllUploadedBooks())
            .thenAnswer((_) async => Right(largeBookList));

        // Act
        final result = await useCase();

        // Assert
        expect(result.fold((_) => 0, (books) => books.length), 1000);
      });

      test('should return failure when repository call fails', () async {
        // Arrange
        when(() => mockRepository.getAllUploadedBooks())
            .thenAnswer((_) async => const Left(ServerFailure()));

        // Act
        final result = await useCase();

        // Assert
        expect(result, const Left(ServerFailure()));
      });
    });

    group('GetAllBorrowedBooksUseCase', () {
      late GetAllBorrowedBooksUseCase useCase;

      setUp(() {
        useCase = GetAllBorrowedBooksUseCase(mockRepository);
      });

      test('should return all borrowed books when repository call is successful', () async {
        // Arrange
        final allBorrowedBooks = [mockBorrowedBook, mockBorrowedBook];
        when(() => mockRepository.getAllBorrowedBooks())
            .thenAnswer((_) async => Right(allBorrowedBooks));

        // Act
        final result = await useCase();

        // Assert
        expect(result, Right(allBorrowedBooks));
        verify(() => mockRepository.getAllBorrowedBooks()).called(1);
      });

      test('should return empty list when user has no borrowed books', () async {
        // Arrange
        when(() => mockRepository.getAllBorrowedBooks())
            .thenAnswer((_) async => const Right([]));

        // Act
        final result = await useCase();

        // Assert
        expect(result, equals(const Right(<Book>[])));
      });

      test('should return failure when repository call fails', () async {
        // Arrange
        when(() => mockRepository.getAllBorrowedBooks())
            .thenAnswer((_) async => const Left(ServerFailure()));

        // Act
        final result = await useCase();

        // Assert
        expect(result, const Left(ServerFailure()));
      });
    });

    group('Integration Tests', () {
      test('should handle complete library workflow', () async {
        // Arrange
        final getUploadedUseCase = GetUploadedBooksUseCase(mockRepository);
        final getBorrowedUseCase = GetBorrowedBooksUseCase(mockRepository);
        final getAllUploadedUseCase = GetAllUploadedBooksUseCase(mockRepository);
        final getAllBorrowedUseCase = GetAllBorrowedBooksUseCase(mockRepository);

        when(() => mockRepository.getUploadedBooks(page: 1, limit: 20))
            .thenAnswer((_) async => Right([mockUploadedBook]));
        when(() => mockRepository.getBorrowedBooks(page: 1, limit: 20))
            .thenAnswer((_) async => Right([mockBorrowedBook]));
        when(() => mockRepository.getAllUploadedBooks())
            .thenAnswer((_) async => Right([mockUploadedBook]));
        when(() => mockRepository.getAllBorrowedBooks())
            .thenAnswer((_) async => Right([mockBorrowedBook]));

        // Act & Assert
        final uploadedResult = await getUploadedUseCase();
        expect(uploadedResult.fold((_) => 0, (books) => books.length), 1);

        final borrowedResult = await getBorrowedUseCase();
        expect(borrowedResult.fold((_) => 0, (books) => books.length), 1);

        final allUploadedResult = await getAllUploadedUseCase();
        expect(allUploadedResult.fold((_) => 0, (books) => books.length), 1);

        final allBorrowedResult = await getAllBorrowedUseCase();
        expect(allBorrowedResult.fold((_) => 0, (books) => books.length), 1);
      });

      test('should handle errors gracefully across different use cases', () async {
        // Arrange
        final getUploadedUseCase = GetUploadedBooksUseCase(mockRepository);
        final getBorrowedUseCase = GetBorrowedBooksUseCase(mockRepository);

        when(() => mockRepository.getUploadedBooks(page: 1, limit: 20))
            .thenAnswer((_) async => const Left(NetworkFailure()));
        when(() => mockRepository.getBorrowedBooks(page: 1, limit: 20))
            .thenAnswer((_) async => const Left(ServerFailure()));

        // Act & Assert
        final uploadedResult = await getUploadedUseCase();
        expect(uploadedResult, const Left(NetworkFailure()));

        final borrowedResult = await getBorrowedUseCase();
        expect(borrowedResult, const Left(ServerFailure()));
      });
    });
  });
}
