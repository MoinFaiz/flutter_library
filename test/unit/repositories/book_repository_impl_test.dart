import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_library/features/home/data/repositories/book_repository_impl.dart';
import 'package:flutter_library/features/home/data/datasources/book_remote_datasource.dart';
import 'package:flutter_library/features/home/data/datasources/book_local_datasource.dart';
import 'package:flutter_library/features/books/data/models/book_model.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';

class MockBookRemoteDataSource extends Mock implements BookRemoteDataSource {}
class MockBookLocalDataSource extends Mock implements BookLocalDataSource {}

class FakeBookModel extends Fake implements BookModel {}

void main() {
  late BookRepositoryImpl repository;
  late MockBookRemoteDataSource mockRemoteDataSource;
  late MockBookLocalDataSource mockLocalDataSource;

  setUpAll(() {
    registerFallbackValue(FakeBookModel());
  });

  setUp(() {
    mockRemoteDataSource = MockBookRemoteDataSource();
    mockLocalDataSource = MockBookLocalDataSource();
    repository = BookRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  // Helper method to create test BookModel (copied from library_repository_impl_test.dart)
  BookModel createTestBookModel({
    required String id,
    required String title,
    required String author,
    String description = 'Test description',
    List<String> imageUrls = const ['https://example.com/image.jpg'],
    double rating = 4.5,
    double salePrice = 29.99,
    double rentPrice = 9.99,
    int totalCopies = 5,
    int availableForRentCount = 3,
    int availableForSaleCount = 2,
    List<String> genres = const ['Fiction'],
    int pageCount = 250,
    String language = 'English',
    AgeAppropriateness ageAppropriateness = AgeAppropriateness.adult,
    bool isFromFriend = false,
    int publishedYear = 2024,
  }) {
    return BookModel(
      id: id,
      title: title,
      author: author,
      description: description,
      imageUrls: imageUrls,
      rating: rating,
      pricing: BookPricing(
        salePrice: salePrice,
        rentPrice: rentPrice,
      ),
      availability: BookAvailability(
        totalCopies: totalCopies,
        availableForRentCount: availableForRentCount,
        availableForSaleCount: availableForSaleCount,
      ),
      metadata: BookMetadata(
        ageAppropriateness: ageAppropriateness,
        genres: genres,
        pageCount: pageCount,
        language: language,
      ),
      isFromFriend: isFromFriend,
      publishedYear: publishedYear,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  final testBooks = [
    createTestBookModel(
      id: '1',
      title: 'Test Book 1',
      author: 'Test Author 1',
    ),
    createTestBookModel(
      id: '2',
      title: 'Test Book 2',
      author: 'Test Author 2',
    ),
  ];

  group('BookRepositoryImpl', () {
    group('getBooks', () {
      test('should return cached books when cache is valid for first page', () async {
        // arrange
        when(() => mockLocalDataSource.isCacheValid()).thenAnswer((_) async => true);
        when(() => mockLocalDataSource.getCachedBooks()).thenAnswer((_) async => testBooks);

        // act
        final result = await repository.getBooks(page: 1, limit: 20);

        // assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected success'),
          (books) => expect(books, equals(testBooks)),
        );
        verify(() => mockLocalDataSource.isCacheValid()).called(1);
        verify(() => mockLocalDataSource.getCachedBooks()).called(1);
        verifyNever(() => mockRemoteDataSource.getBooks(page: any(named: 'page'), limit: any(named: 'limit')));
      });

      test('should fetch from remote when cache is invalid', () async {
        // arrange
        when(() => mockLocalDataSource.isCacheValid()).thenAnswer((_) async => false);
        when(() => mockRemoteDataSource.getBooks(page: 1, limit: 20)).thenAnswer((_) async => testBooks);
        when(() => mockLocalDataSource.cacheBooks(testBooks)).thenAnswer((_) async {});

        // act
        final result = await repository.getBooks(page: 1, limit: 20);

        // assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected success'),
          (books) => expect(books, equals(testBooks)),
        );
        verify(() => mockLocalDataSource.isCacheValid()).called(1);
        verify(() => mockRemoteDataSource.getBooks(page: 1, limit: 20)).called(1);
        verify(() => mockLocalDataSource.cacheBooks(testBooks)).called(1);
      });

      test('should fetch from remote for pages other than first', () async {
        // arrange
        when(() => mockRemoteDataSource.getBooks(page: 2, limit: 20)).thenAnswer((_) async => testBooks);

        // act
        final result = await repository.getBooks(page: 2, limit: 20);

        // assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected success'),
          (books) => expect(books, equals(testBooks)),
        );
        verifyNever(() => mockLocalDataSource.isCacheValid());
        verify(() => mockRemoteDataSource.getBooks(page: 2, limit: 20)).called(1);
        verifyNever(() => mockLocalDataSource.cacheBooks(any()));
      });

      test('should fetch from remote when cache throws exception', () async {
        // arrange
        when(() => mockLocalDataSource.isCacheValid()).thenAnswer((_) async => true);
        when(() => mockLocalDataSource.getCachedBooks()).thenThrow(Exception('Cache error'));
        when(() => mockRemoteDataSource.getBooks(page: 1, limit: 20)).thenAnswer((_) async => testBooks);
        when(() => mockLocalDataSource.cacheBooks(testBooks)).thenAnswer((_) async {});

        // act
        final result = await repository.getBooks(page: 1, limit: 20);

        // assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected success'),
          (books) => expect(books, equals(testBooks)),
        );
        verify(() => mockLocalDataSource.isCacheValid()).called(1);
        verify(() => mockLocalDataSource.getCachedBooks()).called(1);
        verify(() => mockRemoteDataSource.getBooks(page: 1, limit: 20)).called(1);
        verify(() => mockLocalDataSource.cacheBooks(testBooks)).called(1);
      });
    });

    group('searchBooks', () {
      test('should return search results from remote', () async {
        // arrange
        final query = 'test query';
        when(() => mockRemoteDataSource.searchBooks(query)).thenAnswer((_) async => testBooks);

        // act
        final result = await repository.searchBooks(query);

        // assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected success'),
          (books) => expect(books, equals(testBooks)),
        );
        verify(() => mockRemoteDataSource.searchBooks(query)).called(1);
      });
    });

    group('getBookById', () {
      test('should return book from remote', () async {
        // arrange
        final bookId = '1';
        final book = testBooks.first;
        when(() => mockRemoteDataSource.getBookById(bookId)).thenAnswer((_) async => book);

        // act
        final result = await repository.getBookById(bookId);

        // assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected success'),
          (foundBook) => expect(foundBook, equals(book)),
        );
        verify(() => mockRemoteDataSource.getBookById(bookId)).called(1);
      });

      test('should return null when book not found', () async {
        // arrange
        final bookId = 'nonexistent';
        when(() => mockRemoteDataSource.getBookById(bookId)).thenAnswer((_) async => null);

        // act
        final result = await repository.getBookById(bookId);

        // assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected success'),
          (foundBook) => expect(foundBook, isNull),
        );
        verify(() => mockRemoteDataSource.getBookById(bookId)).called(1);
      });
    });

    group('cache management', () {
      test('should invalidate cache', () async {
        // arrange
        when(() => mockLocalDataSource.invalidateCache()).thenAnswer((_) async {});

        // act
        final result = await repository.invalidateCache();

        // assert
        expect(result.isRight(), true);
        verify(() => mockLocalDataSource.invalidateCache()).called(1);
      });

      test('should check cache validity', () async {
        // arrange
        when(() => mockLocalDataSource.isCacheValid()).thenAnswer((_) async => true);

        // act
        final result = await repository.isCacheValid();

        // assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected success'),
          (isValid) => expect(isValid, isTrue),
        );
        verify(() => mockLocalDataSource.isCacheValid()).called(1);
      });
    });
  });
}
