import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';
import 'package:flutter_library/features/library/domain/repositories/library_repository.dart';
import 'package:flutter_library/features/library/domain/usecases/get_uploaded_books_usecase.dart';
import 'package:flutter_library/features/library/domain/usecases/get_borrowed_books_usecase.dart';

class MockLibraryRepository extends Mock implements LibraryRepository {}

void main() {
  late MockLibraryRepository mockRepository;
  late GetUploadedBooksUseCase getUploadedBooksUseCase;
  late GetBorrowedBooksUseCase getBorrowedBooksUseCase;
  late GetAllUploadedBooksUseCase getAllUploadedBooksUseCase;
  late GetAllBorrowedBooksUseCase getAllBorrowedBooksUseCase;

  setUp(() {
    mockRepository = MockLibraryRepository();
    getUploadedBooksUseCase = GetUploadedBooksUseCase(mockRepository);
    getBorrowedBooksUseCase = GetBorrowedBooksUseCase(mockRepository);
    getAllUploadedBooksUseCase = GetAllUploadedBooksUseCase(mockRepository);
    getAllBorrowedBooksUseCase = GetAllBorrowedBooksUseCase(mockRepository);
  });

  // Helper function to create test books
  Book createTestBook({
    required String id,
    required String title,
    required String author,
    List<String> imageUrls = const ['https://example.com/image.jpg'],
    double rating = 4.5,
    double salePrice = 29.99,
    double rentPrice = 9.99,
    List<String> genres = const ['fiction'],
  }) {
    return Book(
      id: id,
      title: title,
      author: author,
      imageUrls: imageUrls,
      rating: rating,
      pricing: BookPricing(
        salePrice: salePrice,
        rentPrice: rentPrice,
      ),
      availability: const BookAvailability(
        availableForRentCount: 1,
        availableForSaleCount: 1,
        totalCopies: 1,
      ),
      metadata: BookMetadata(
        isbn: '$id-isbn',
        publisher: 'Test Publisher',
        ageAppropriateness: AgeAppropriateness.adult,
        genres: genres,
        pageCount: 300,
        language: 'English',
      ),
      isFromFriend: false,
      isFavorite: false,
      description: 'Test Description for $title',
      publishedYear: 2023,
      createdAt: DateTime(2023, 1, 1),
      updatedAt: DateTime(2023, 1, 1),
    );
  }

  group('GetUploadedBooksUseCase', () {
    final testBooks = [
      createTestBook(
        id: '1',
        title: 'Test Book 1',
        author: 'Test Author 1',
      ),
      createTestBook(
        id: '2',
        title: 'Test Book 2',
        author: 'Test Author 2',
        genres: ['non-fiction'],
      ),
    ];

    test('should return list of uploaded books from repository', () async {
      // Arrange
      when(() => mockRepository.getUploadedBooks(page: any(named: 'page'), limit: any(named: 'limit')))
          .thenAnswer((_) async => Right(testBooks));

      // Act
      final result = await getUploadedBooksUseCase();

      // Assert
      expect(result, equals(Right(testBooks)));
      verify(() => mockRepository.getUploadedBooks(page: 1, limit: 20));
    });

    test('should return list of uploaded books with custom page and limit', () async {
      // Arrange
      when(() => mockRepository.getUploadedBooks(page: any(named: 'page'), limit: any(named: 'limit')))
          .thenAnswer((_) async => Right(testBooks));

      // Act
      final result = await getUploadedBooksUseCase(page: 2, limit: 10);

      // Assert
      expect(result, equals(Right(testBooks)));
      verify(() => mockRepository.getUploadedBooks(page: 2, limit: 10));
    });

    test('should return ServerFailure when repository fails', () async {
      // Arrange
      const serverFailure = ServerFailure();
      when(() => mockRepository.getUploadedBooks(page: any(named: 'page'), limit: any(named: 'limit')))
          .thenAnswer((_) async => const Left(serverFailure));

      // Act
      final result = await getUploadedBooksUseCase();

      // Assert
      expect(result, equals(const Left(serverFailure)));
      verify(() => mockRepository.getUploadedBooks(page: 1, limit: 20));
    });

    test('should return NetworkFailure when network error occurs', () async {
      // Arrange
      const networkFailure = NetworkFailure();
      when(() => mockRepository.getUploadedBooks(page: any(named: 'page'), limit: any(named: 'limit')))
          .thenAnswer((_) async => const Left(networkFailure));

      // Act
      final result = await getUploadedBooksUseCase();

      // Assert
      expect(result, equals(const Left(networkFailure)));
    });

    test('should return empty list when no uploaded books', () async {
      // Arrange
      when(() => mockRepository.getUploadedBooks(page: any(named: 'page'), limit: any(named: 'limit')))
          .thenAnswer((_) async => const Right(<Book>[]));

      // Act
      final result = await getUploadedBooksUseCase();

      // Assert
      expect(result, equals(const Right(<Book>[])));
    });
  });

  group('GetBorrowedBooksUseCase', () {
    final testBooks = [
      createTestBook(
        id: '3',
        title: 'Borrowed Book 1',
        author: 'Borrowed Author 1',
        genres: ['mystery'],
      ),
    ];

    test('should return list of borrowed books from repository', () async {
      // Arrange
      when(() => mockRepository.getBorrowedBooks(page: any(named: 'page'), limit: any(named: 'limit')))
          .thenAnswer((_) async => Right(testBooks));

      // Act
      final result = await getBorrowedBooksUseCase();

      // Assert
      expect(result, equals(Right(testBooks)));
      verify(() => mockRepository.getBorrowedBooks(page: 1, limit: 20));
    });

    test('should return list of borrowed books with custom parameters', () async {
      // Arrange
      when(() => mockRepository.getBorrowedBooks(page: any(named: 'page'), limit: any(named: 'limit')))
          .thenAnswer((_) async => Right(testBooks));

      // Act
      final result = await getBorrowedBooksUseCase(page: 3, limit: 15);

      // Assert
      expect(result, equals(Right(testBooks)));
      verify(() => mockRepository.getBorrowedBooks(page: 3, limit: 15));
    });

    test('should return CacheFailure when cache error occurs', () async {
      // Arrange
      const cacheFailure = CacheFailure('Cache error');
      when(() => mockRepository.getBorrowedBooks(page: any(named: 'page'), limit: any(named: 'limit')))
          .thenAnswer((_) async => const Left(cacheFailure));

      // Act
      final result = await getBorrowedBooksUseCase();

      // Assert
      expect(result, equals(const Left(cacheFailure)));
    });

    test('should handle concurrent calls correctly', () async {
      // Arrange
      when(() => mockRepository.getBorrowedBooks(page: any(named: 'page'), limit: any(named: 'limit')))
          .thenAnswer((_) async => Right(testBooks));

      // Act
      final future1 = getBorrowedBooksUseCase(page: 1);
      final future2 = getBorrowedBooksUseCase(page: 2);
      final results = await Future.wait([future1, future2]);

      // Assert
      expect(results[0], equals(Right(testBooks)));
      expect(results[1], equals(Right(testBooks)));
      verify(() => mockRepository.getBorrowedBooks(page: 1, limit: 20));
      verify(() => mockRepository.getBorrowedBooks(page: 2, limit: 20));
    });
  });

  group('GetAllUploadedBooksUseCase', () {
    final testBooks = [
      createTestBook(
        id: '1',
        title: 'All Upload 1',
        author: 'Author 1',
      ),
      createTestBook(
        id: '2',
        title: 'All Upload 2',
        author: 'Author 2',
        genres: ['non-fiction'],
      ),
      createTestBook(
        id: '3',
        title: 'All Upload 3',
        author: 'Author 3',
        genres: ['biography'],
      ),
    ];

    test('should return all uploaded books from repository', () async {
      // Arrange
      when(() => mockRepository.getAllUploadedBooks())
          .thenAnswer((_) async => Right(testBooks));

      // Act
      final result = await getAllUploadedBooksUseCase();

      // Assert
      expect(result, equals(Right(testBooks)));
      verify(() => mockRepository.getAllUploadedBooks());
    });

    test('should return failure when repository fails', () async {
      // Arrange
      const serverFailure = ServerFailure(message: 'Failed to get all uploaded books');
      when(() => mockRepository.getAllUploadedBooks())
          .thenAnswer((_) async => const Left(serverFailure));

      // Act
      final result = await getAllUploadedBooksUseCase();

      // Assert
      expect(result, equals(const Left(serverFailure)));
    });

    test('should return empty list when no books uploaded', () async {
      // Arrange
      when(() => mockRepository.getAllUploadedBooks())
          .thenAnswer((_) async => const Right(<Book>[]));

      // Act
      final result = await getAllUploadedBooksUseCase();

      // Assert
      expect(result, equals(const Right(<Book>[])));
    });
  });

  group('GetAllBorrowedBooksUseCase', () {
    final testBooks = [
      createTestBook(
        id: '4',
        title: 'All Borrowed 1',
        author: 'Borrowed Author',
        genres: ['romance'],
      ),
    ];

    test('should return all borrowed books from repository', () async {
      // Arrange
      when(() => mockRepository.getAllBorrowedBooks())
          .thenAnswer((_) async => Right(testBooks));

      // Act
      final result = await getAllBorrowedBooksUseCase();

      // Assert
      expect(result, equals(Right(testBooks)));
      verify(() => mockRepository.getAllBorrowedBooks());
    });

    test('should return NetworkFailure when network is unavailable', () async {
      // Arrange
      const networkFailure = NetworkFailure(message: 'No internet connection');
      when(() => mockRepository.getAllBorrowedBooks())
          .thenAnswer((_) async => const Left(networkFailure));

      // Act
      final result = await getAllBorrowedBooksUseCase();

      // Assert
      expect(result, equals(const Left(networkFailure)));
    });

    test('should handle repository timeout', () async {
      // Arrange
      const serverFailure = ServerFailure(message: 'Request timeout');
      when(() => mockRepository.getAllBorrowedBooks())
          .thenAnswer((_) async => const Left(serverFailure));

      // Act
      final result = await getAllBorrowedBooksUseCase();

      // Assert
      expect(result, equals(const Left(serverFailure)));
    });
  });

  group('Edge Cases and Integration', () {
    test('should handle repository returning null gracefully', () async {
      // Arrange
      when(() => mockRepository.getUploadedBooks(page: any(named: 'page'), limit: any(named: 'limit')))
          .thenAnswer((_) async => const Right(<Book>[]));

      // Act
      final result = await getUploadedBooksUseCase();

      // Assert
      expect(result, equals(const Right(<Book>[])));
    });

    test('should handle very large page numbers', () async {
      // Arrange
      when(() => mockRepository.getUploadedBooks(page: any(named: 'page'), limit: any(named: 'limit')))
          .thenAnswer((_) async => const Right(<Book>[]));

      // Act
      final result = await getUploadedBooksUseCase(page: 999999, limit: 1);

      // Assert
      expect(result, equals(const Right(<Book>[])));
      verify(() => mockRepository.getUploadedBooks(page: 999999, limit: 1));
    });

    test('should handle zero and negative limits', () async {
      // Arrange
      when(() => mockRepository.getBorrowedBooks(page: any(named: 'page'), limit: any(named: 'limit')))
          .thenAnswer((_) async => const Right(<Book>[]));

      // Act
      final result1 = await getBorrowedBooksUseCase(page: 1, limit: 0);
      final result2 = await getBorrowedBooksUseCase(page: 1, limit: -5);

      // Assert
      expect(result1, equals(const Right(<Book>[])));
      expect(result2, equals(const Right(<Book>[])));
    });
  });
}
