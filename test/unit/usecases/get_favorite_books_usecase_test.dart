import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_library/features/favorites/domain/usecases/get_favorite_books_usecase.dart';
import 'package:flutter_library/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:flutter_library/features/home/domain/repositories/book_repository.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';
import 'package:flutter_library/core/error/failures.dart';

class MockFavoritesRepository extends Mock implements FavoritesRepository {}
class MockBookRepository extends Mock implements BookRepository {}

void main() {
  group('GetFavoriteBooksUseCase', () {
    late GetFavoriteBooksUseCase useCase;
    late MockFavoritesRepository mockFavoritesRepository;
    late MockBookRepository mockBookRepository;

    setUp(() {
      mockFavoritesRepository = MockFavoritesRepository();
      mockBookRepository = MockBookRepository();
      useCase = GetFavoriteBooksUseCase(
        favoritesRepository: mockFavoritesRepository,
        bookRepository: mockBookRepository,
      );
    });

    const tFavoriteIds = ['book_1', 'book_2'];

    final tBook1 = Book(
      id: 'book_1',
      title: 'Favorite Book 1',
      author: 'Author 1',
      imageUrls: ['https://example.com/book1.jpg'],
      rating: 4.5,
      pricing: const BookPricing(
        salePrice: 29.99,
        rentPrice: 4.99,
      ),
      availability: const BookAvailability(
        totalCopies: 10,
        availableForRentCount: 5,
        availableForSaleCount: 3,
      ),
      metadata: const BookMetadata(
        isbn: '9780123456789',
        publisher: 'Test Publisher',
        ageAppropriateness: AgeAppropriateness.youngAdult,
        genres: ['Fiction'],
        pageCount: 300,
        language: 'English',
      ),
      isFromFriend: false,
      isFavorite: true,
      description: 'Test description',
      publishedYear: 2023,
      createdAt: DateTime(2023, 1, 1),
      updatedAt: DateTime(2023, 1, 1),
    );

    final tBook2 = Book(
      id: 'book_2',
      title: 'Favorite Book 2',
      author: 'Author 2',
      imageUrls: ['https://example.com/book2.jpg'],
      rating: 4.0,
      pricing: const BookPricing(
        salePrice: 19.99,
        rentPrice: 3.99,
      ),
      availability: const BookAvailability(
        totalCopies: 5,
        availableForRentCount: 2,
        availableForSaleCount: 1,
      ),
      metadata: const BookMetadata(
        isbn: '9780987654321',
        publisher: 'Another Publisher',
        ageAppropriateness: AgeAppropriateness.adult,
        genres: ['Non-Fiction'],
        pageCount: 200,
        language: 'English',
      ),
      isFromFriend: false,
      isFavorite: true,
      description: 'Another test description',
      publishedYear: 2022,
      createdAt: DateTime(2022, 6, 1),
      updatedAt: DateTime(2022, 6, 1),
    );

    test('should get favorite books successfully', () async {
      // arrange
      when(() => mockFavoritesRepository.getFavoriteBookIds())
          .thenAnswer((_) async => const Right(tFavoriteIds));
      when(() => mockBookRepository.getBookById('book_1'))
          .thenAnswer((_) async => Right(tBook1));
      when(() => mockBookRepository.getBookById('book_2'))
          .thenAnswer((_) async => Right(tBook2));

      // act
      final result = await useCase();

      // assert
      verify(() => mockFavoritesRepository.getFavoriteBookIds());
      verify(() => mockBookRepository.getBookById('book_1'));
      verify(() => mockBookRepository.getBookById('book_2'));
      expect(result, isA<Right<Failure, List<Book>>>());
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (books) {
          expect(books.length, equals(2));
          expect(books[0].isFavorite, isTrue);
          expect(books[1].isFavorite, isTrue);
        },
      );
    });

    test('should return empty list when no favorites', () async {
      // arrange
      when(() => mockFavoritesRepository.getFavoriteBookIds())
          .thenAnswer((_) async => const Right([]));

      // act
      final result = await useCase();

      // assert
      verify(() => mockFavoritesRepository.getFavoriteBookIds());
      expect(result, equals(const Right<Failure, List<Book>>([])));
    });

    test('should return failure when favorites repository fails', () async {
      // arrange
      const tFailure = CacheFailure('Cache error');
      when(() => mockFavoritesRepository.getFavoriteBookIds())
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await useCase();

      // assert
      verify(() => mockFavoritesRepository.getFavoriteBookIds());
      expect(result, equals(const Left(tFailure)));
    });

    test('should skip books that fail to load and continue with others', () async {
      // arrange
      const tFailure = ServerFailure(message: 'Server error');
      when(() => mockFavoritesRepository.getFavoriteBookIds())
          .thenAnswer((_) async => const Right(tFavoriteIds));
      when(() => mockBookRepository.getBookById('book_1'))
          .thenAnswer((_) async => const Left(tFailure));
      when(() => mockBookRepository.getBookById('book_2'))
          .thenAnswer((_) async => Right(tBook2));

      // act
      final result = await useCase();

      // assert
      verify(() => mockFavoritesRepository.getFavoriteBookIds());
      verify(() => mockBookRepository.getBookById('book_1'));
      verify(() => mockBookRepository.getBookById('book_2'));
      expect(result, isA<Right<Failure, List<Book>>>());
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (books) {
          expect(books.length, equals(1)); // Only book_2 should be included
          expect(books[0].id, equals('book_2'));
          expect(books[0].isFavorite, isTrue);
        },
      );
    });

    test('should handle pagination correctly', () async {
      // arrange
      const tManyFavoriteIds = ['book_1', 'book_2', 'book_3', 'book_4', 'book_5'];
      when(() => mockFavoritesRepository.getFavoriteBookIds())
          .thenAnswer((_) async => const Right(tManyFavoriteIds));
      when(() => mockBookRepository.getBookById('book_3'))
          .thenAnswer((_) async => Right(tBook1));
      when(() => mockBookRepository.getBookById('book_4'))
          .thenAnswer((_) async => Right(tBook2));

      // act
      final result = await useCase(page: 2, limit: 2);

      // assert
      verify(() => mockFavoritesRepository.getFavoriteBookIds());
      verify(() => mockBookRepository.getBookById('book_3'));
      verify(() => mockBookRepository.getBookById('book_4'));
      expect(result, isA<Right<Failure, List<Book>>>());
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (books) => expect(books.length, equals(2)),
      );
    });
  });
}
