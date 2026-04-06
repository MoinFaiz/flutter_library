import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_library/features/book_upload/data/repositories/book_upload_repository_impl.dart';
import 'package:flutter_library/features/book_upload/data/datasources/book_upload_remote_datasource.dart';
import 'package:flutter_library/features/book_upload/data/models/book_upload_form_model.dart';
import 'package:flutter_library/features/book_upload/data/models/book_copy_model.dart';
import 'package:flutter_library/features/book_upload/domain/entities/book_upload_form.dart';
import 'package:flutter_library/features/book_upload/domain/entities/book_copy.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/books/data/models/book_model.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';
import 'package:flutter_library/core/error/failures.dart';

class MockBookUploadRemoteDataSource extends Mock implements BookUploadRemoteDataSource {}

void main() {
  group('BookUploadRepositoryImpl', () {
    late BookUploadRepositoryImpl repository;
    late MockBookUploadRemoteDataSource mockRemoteDataSource;

    setUpAll(() {
      registerFallbackValue(
        BookUploadFormModel(
          id: 'test',
          title: 'test',
          isbn: 'test',
          author: 'test',
          description: 'test',
          genres: ['test'],
          publishedYear: 2023,
          copies: [],
        ),
      );
      registerFallbackValue(
        BookCopyModel(
          id: 'test',
          bookId: 'test',
          imageUrls: ['test'],
          condition: BookCondition.good,
          isForSale: false,
          isForRent: false,
          isForDonate: false,
          notes: 'test',
        ),
      );
    });

    setUp(() {
      mockRemoteDataSource = MockBookUploadRemoteDataSource();
      repository = BookUploadRepositoryImpl(
        remoteDataSource: mockRemoteDataSource,
      );
    });

    const tQuery = 'test book';
    const tIsbn = '9780123456789';
    
    final tBook = Book(
      id: 'book_1',
      title: 'Test Book',
      author: 'Test Author',
      imageUrls: ['https://example.com/book.jpg'],
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
      isFavorite: false,
      description: 'Test description',
      publishedYear: 2023,
      createdAt: DateTime(2023, 1, 1),
      updatedAt: DateTime(2023, 1, 1),
    );

    final tBookModel = BookModel(
      id: 'book_1',
      title: 'Test Book',
      author: 'Test Author',
      imageUrls: ['https://example.com/book.jpg'],
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
      description: 'Test description',
      publishedYear: 2023,
      createdAt: DateTime(2023, 1, 1),
      updatedAt: DateTime(2023, 1, 1),
    );

    final tBookList = [tBook];
    final tBookModelList = [tBookModel];

    final tBookUploadForm = BookUploadForm(
      id: 'form_1',
      title: 'New Book',
      isbn: '9780123456789',
      author: 'New Author',
      description: 'A new book description',
      genres: ['Fiction'],
      publishedYear: 2023,
      copies: [],
    );

    final tBookCopy = BookCopy(
      id: 'copy_1',
      bookId: 'book_1',
      imageUrls: ['https://example.com/copy.jpg'],
      condition: BookCondition.good,
      isForSale: true,
      isForRent: false,
      isForDonate: false,
      notes: 'Copy in good condition',
    );

    final tBookCopyModel = BookCopyModel(
      id: 'copy_1',
      bookId: 'book_1',
      imageUrls: ['https://example.com/copy.jpg'],
      condition: BookCondition.good,
      isForSale: true,
      isForRent: false,
      isForDonate: false,
      notes: 'Copy in good condition',
    );

    group('searchBooks', () {
      test('should return list of books when search is successful', () async {
        // arrange
        when(() => mockRemoteDataSource.searchBooks(tQuery))
            .thenAnswer((_) async => tBookModelList);

        // act
        final result = await repository.searchBooks(tQuery);

        // assert
        verify(() => mockRemoteDataSource.searchBooks(tQuery));
        expect(result, isA<Right<Failure, List<Book>>>());
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (books) => expect(books, equals(tBookList)),
        );
      });

      test('should return ServerFailure when search fails', () async {
        // arrange
        when(() => mockRemoteDataSource.searchBooks(tQuery))
            .thenThrow(Exception('Search failed'));

        // act
        final result = await repository.searchBooks(tQuery);

        // assert
        expect(result, isA<Left<Failure, List<Book>>>());
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (books) => fail('Expected failure'),
        );
      });
    });

    group('getBookByIsbn', () {
      test('should return book when ISBN lookup is successful', () async {
        // arrange
        when(() => mockRemoteDataSource.getBookByIsbn(tIsbn))
            .thenAnswer((_) async => tBookModel);

        // act
        final result = await repository.getBookByIsbn(tIsbn);

        // assert
        verify(() => mockRemoteDataSource.getBookByIsbn(tIsbn));
        expect(result, isA<Right<Failure, Book?>>());
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (book) => expect(book, equals(tBook)),
        );
      });

      test('should return null when book is not found', () async {
        // arrange
        when(() => mockRemoteDataSource.getBookByIsbn(tIsbn))
            .thenAnswer((_) async => null);

        // act
        final result = await repository.getBookByIsbn(tIsbn);

        // assert
        verify(() => mockRemoteDataSource.getBookByIsbn(tIsbn));
        expect(result, isA<Right<Failure, Book?>>());
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (book) => expect(book, isNull),
        );
      });

      test('should return ServerFailure when ISBN lookup fails', () async {
        // arrange
        when(() => mockRemoteDataSource.getBookByIsbn(tIsbn))
            .thenThrow(Exception('ISBN lookup failed'));

        // act
        final result = await repository.getBookByIsbn(tIsbn);

        // assert
        expect(result, isA<Left<Failure, Book?>>());
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (book) => fail('Expected failure'),
        );
      });
    });

    group('uploadBook', () {
      test('should upload book successfully', () async {
        // arrange
        when(() => mockRemoteDataSource.uploadBook(any()))
            .thenAnswer((_) async => tBookModel);

        // act
        final result = await repository.uploadBook(tBookUploadForm);

        // assert
        verify(() => mockRemoteDataSource.uploadBook(any()));
        expect(result, isA<Right<Failure, Book>>());
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (book) => expect(book, equals(tBook)),
        );
      });

      test('should return ServerFailure when upload fails', () async {
        // arrange
        when(() => mockRemoteDataSource.uploadBook(any()))
            .thenThrow(Exception('Upload failed'));

        // act
        final result = await repository.uploadBook(tBookUploadForm);

        // assert
        expect(result, isA<Left<Failure, Book>>());
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (book) => fail('Expected failure'),
        );
      });
    });

    group('updateBook', () {
      test('should update book successfully', () async {
        // arrange
        when(() => mockRemoteDataSource.updateBook(any()))
            .thenAnswer((_) async => tBookModel);

        // act
        final result = await repository.updateBook(tBookUploadForm);

        // assert
        verify(() => mockRemoteDataSource.updateBook(any()));
        expect(result, isA<Right<Failure, Book>>());
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (book) => expect(book, equals(tBook)),
        );
      });

      test('should return ServerFailure when update fails', () async {
        // arrange
        when(() => mockRemoteDataSource.updateBook(any()))
            .thenThrow(Exception('Update failed'));

        // act
        final result = await repository.updateBook(tBookUploadForm);

        // assert
        expect(result, isA<Left<Failure, Book>>());
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (book) => fail('Expected failure'),
        );
      });
    });

    group('uploadCopy', () {
      test('should upload copy successfully', () async {
        // arrange
        when(() => mockRemoteDataSource.uploadCopy(any()))
            .thenAnswer((_) async => tBookCopyModel);

        // act
        final result = await repository.uploadCopy(tBookCopy);

        // assert
        verify(() => mockRemoteDataSource.uploadCopy(any()));
        expect(result, isA<Right<Failure, BookCopy>>());
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (copy) => expect(copy, equals(tBookCopy)),
        );
      });

      test('should return ServerFailure when upload copy fails', () async {
        // arrange
        when(() => mockRemoteDataSource.uploadCopy(any()))
            .thenThrow(Exception('Upload copy failed'));

        // act
        final result = await repository.uploadCopy(tBookCopy);

        // assert
        expect(result, isA<Left<Failure, BookCopy>>());
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (copy) => fail('Expected failure'),
        );
      });
    });

    group('updateCopy', () {
      test('should update copy successfully', () async {
        // arrange
        when(() => mockRemoteDataSource.updateCopy(any()))
            .thenAnswer((_) async => tBookCopyModel);

        // act
        final result = await repository.updateCopy(tBookCopy);

        // assert
        verify(() => mockRemoteDataSource.updateCopy(any()));
        expect(result, isA<Right<Failure, BookCopy>>());
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (copy) => expect(copy, equals(tBookCopy)),
        );
      });

      test('should return ServerFailure when update copy fails', () async {
        // arrange
        when(() => mockRemoteDataSource.updateCopy(any()))
            .thenThrow(Exception('Update copy failed'));

        // act
        final result = await repository.updateCopy(tBookCopy);

        // assert
        expect(result, isA<Left<Failure, BookCopy>>());
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (copy) => fail('Expected failure'),
        );
      });
    });

    group('deleteCopy', () {
      test('should delete copy successfully', () async {
        // arrange
        when(() => mockRemoteDataSource.deleteCopy('copy_1', 'test reason'))
            .thenAnswer((_) async => {});

        // act
        final result = await repository.deleteCopy('copy_1', 'test reason');

        // assert
        verify(() => mockRemoteDataSource.deleteCopy('copy_1', 'test reason'));
        expect(result, isA<Right<Failure, void>>());
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (_) => {}, // void result doesn't need any check
        );
      });

      test('should return ServerFailure when delete copy fails', () async {
        // arrange
        when(() => mockRemoteDataSource.deleteCopy('copy_1', 'test reason'))
            .thenThrow(Exception('Delete copy failed'));

        // act
        final result = await repository.deleteCopy('copy_1', 'test reason');

        // assert
        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Expected failure'),
        );
      });
    });

    group('deleteBook', () {
      test('should delete book successfully', () async {
        // arrange
        when(() => mockRemoteDataSource.deleteBook('book_1', 'no longer available'))
            .thenAnswer((_) async => {});

        // act
        final result = await repository.deleteBook('book_1', 'no longer available');

        // assert
        verify(() => mockRemoteDataSource.deleteBook('book_1', 'no longer available'));
        expect(result, isA<Right<Failure, void>>());
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (_) => {}, // void result doesn't need any check
        );
      });

      test('should return ServerFailure when delete book fails', () async {
        // arrange
        when(() => mockRemoteDataSource.deleteBook('book_1', 'test reason'))
            .thenThrow(Exception('Delete book failed'));

        // act
        final result = await repository.deleteBook('book_1', 'test reason');

        // assert
        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Expected failure'),
        );
      });
    });

    group('getUserBooks', () {
      test('should get user books successfully', () async {
        // arrange
        when(() => mockRemoteDataSource.getUserBooks())
            .thenAnswer((_) async => tBookModelList);

        // act
        final result = await repository.getUserBooks();

        // assert
        verify(() => mockRemoteDataSource.getUserBooks());
        expect(result, isA<Right<Failure, List<Book>>>());
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (books) {
            expect(books.length, equals(1));
            expect(books.first.id, equals(tBook.id));
            expect(books.first.title, equals(tBook.title));
          },
        );
      });

      test('should return empty list when user has no books', () async {
        // arrange
        when(() => mockRemoteDataSource.getUserBooks())
            .thenAnswer((_) async => []);

        // act
        final result = await repository.getUserBooks();

        // assert
        verify(() => mockRemoteDataSource.getUserBooks());
        expect(result, isA<Right<Failure, List<Book>>>());
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (books) => expect(books, isEmpty),
        );
      });

      test('should return ServerFailure when get user books fails', () async {
        // arrange
        when(() => mockRemoteDataSource.getUserBooks())
            .thenThrow(Exception('Failed to get user books'));

        // act
        final result = await repository.getUserBooks();

        // assert
        expect(result, isA<Left<Failure, List<Book>>>());
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (books) => fail('Expected failure'),
        );
      });
    });

    group('uploadImage', () {
      test('should upload image successfully', () async {
        // arrange
        when(() => mockRemoteDataSource.uploadImage('/path/to/image.jpg'))
            .thenAnswer((_) async => 'https://example.com/uploaded-image.jpg');

        // act
        final result = await repository.uploadImage('/path/to/image.jpg');

        // assert
        verify(() => mockRemoteDataSource.uploadImage('/path/to/image.jpg'));
        expect(result, isA<Right<Failure, String>>());
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (url) => expect(url, equals('https://example.com/uploaded-image.jpg')),
        );
      });

      test('should return ServerFailure when image upload fails', () async {
        // arrange
        when(() => mockRemoteDataSource.uploadImage('/path/to/image.jpg'))
            .thenThrow(Exception('Image upload failed'));

        // act
        final result = await repository.uploadImage('/path/to/image.jpg');

        // assert
        expect(result, isA<Left<Failure, String>>());
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (url) => fail('Expected failure'),
        );
      });
    });

    group('getGenres', () {
      test('should return list of genres successfully', () async {
        // arrange
        const tGenres = ['Fiction', 'Non-Fiction', 'Science', 'History'];
        when(() => mockRemoteDataSource.getGenres())
            .thenAnswer((_) async => tGenres);

        // act
        final result = await repository.getGenres();

        // assert
        verify(() => mockRemoteDataSource.getGenres());
        expect(result, isA<Right<Failure, List<String>>>());
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (genres) => expect(genres, equals(tGenres)),
        );
      });

      test('should return ServerFailure when get genres fails', () async {
        // arrange
        when(() => mockRemoteDataSource.getGenres())
            .thenThrow(Exception('Get genres failed'));

        // act
        final result = await repository.getGenres();

        // assert
        expect(result, isA<Left<Failure, List<String>>>());
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (genres) => fail('Expected failure'),
        );
      });
    });

    group('getLanguages', () {
      test('should return list of languages successfully', () async {
        // arrange
        const tLanguages = ['English', 'Spanish', 'French', 'German'];
        when(() => mockRemoteDataSource.getLanguages())
            .thenAnswer((_) async => tLanguages);

        // act
        final result = await repository.getLanguages();

        // assert
        verify(() => mockRemoteDataSource.getLanguages());
        expect(result, isA<Right<Failure, List<String>>>());
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (languages) => expect(languages, equals(tLanguages)),
        );
      });

      test('should return ServerFailure when get languages fails', () async {
        // arrange
        when(() => mockRemoteDataSource.getLanguages())
            .thenThrow(Exception('Get languages failed'));

        // act
        final result = await repository.getLanguages();

        // assert
        expect(result, isA<Left<Failure, List<String>>>());
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (languages) => fail('Expected failure'),
        );
      });
    });
  });
}
