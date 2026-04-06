import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_library/features/book_details/data/repositories/book_operations_repository_impl.dart';
import 'package:flutter_library/features/book_details/data/datasources/book_operations_remote_datasource.dart';
import 'package:flutter_library/features/book_details/data/datasources/rental_status_local_datasource.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';
import 'package:flutter_library/core/error/failures.dart';

class MockBookOperationsRemoteDataSource extends Mock implements BookOperationsRemoteDataSource {}
class MockRentalStatusLocalDataSource extends Mock implements RentalStatusLocalDataSource {}

void main() {
  group('BookOperationsRepositoryImpl', () {
    late BookOperationsRepositoryImpl repository;
    late MockBookOperationsRemoteDataSource mockRemoteDataSource;
    late MockRentalStatusLocalDataSource mockLocalDataSource;

    setUp(() {
      mockRemoteDataSource = MockBookOperationsRemoteDataSource();
      mockLocalDataSource = MockRentalStatusLocalDataSource();
      repository = BookOperationsRepositoryImpl(
        remoteDataSource: mockRemoteDataSource,
        rentalStatusLocalDataSource: mockLocalDataSource,
      );
    });

    const tBookId = 'test_book_id';
    
    final tBook = Book(
      id: tBookId,
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
        isbn: '1234567890',
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

    group('rentBook', () {
      test('should rent book successfully and invalidate cache', () async {
        // arrange
        when(() => mockRemoteDataSource.rentBook(tBookId))
            .thenAnswer((_) async => tBook);
        when(() => mockLocalDataSource.clearCacheForBook(tBookId))
            .thenAnswer((_) async => {});

        // act
        final result = await repository.rentBook(tBookId);

        // assert
        verify(() => mockRemoteDataSource.rentBook(tBookId));
        verify(() => mockLocalDataSource.clearCacheForBook(tBookId));
        expect(result, equals(Right(tBook)));
      });

      test('should return NetworkFailure when DioException occurs during rent', () async {
        // arrange
        when(() => mockRemoteDataSource.rentBook(tBookId))
            .thenThrow(DioException(requestOptions: RequestOptions(path: '')));

        // act
        final result = await repository.rentBook(tBookId);

        // assert
        expect(result, isA<Left<Failure, Book>>());
        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (book) => fail('Expected failure'),
        );
      });

      test('should return UnknownFailure when unknown exception occurs during rent', () async {
        // arrange
        when(() => mockRemoteDataSource.rentBook(tBookId))
            .thenThrow(Exception('Unknown error'));

        // act
        final result = await repository.rentBook(tBookId);

        // assert
        expect(result, isA<Left<Failure, Book>>());
        result.fold(
          (failure) => expect(failure, isA<UnknownFailure>()),
          (book) => fail('Expected failure'),
        );
      });
    });

    group('buyBook', () {
      test('should buy book successfully and invalidate cache', () async {
        // arrange
        when(() => mockRemoteDataSource.buyBook(tBookId))
            .thenAnswer((_) async => tBook);
        when(() => mockLocalDataSource.clearCacheForBook(tBookId))
            .thenAnswer((_) async => {});

        // act
        final result = await repository.buyBook(tBookId);

        // assert
        verify(() => mockRemoteDataSource.buyBook(tBookId));
        verify(() => mockLocalDataSource.clearCacheForBook(tBookId));
        expect(result, equals(Right(tBook)));
      });

      test('should return NetworkFailure when DioException occurs during buy', () async {
        // arrange
        when(() => mockRemoteDataSource.buyBook(tBookId))
            .thenThrow(DioException(requestOptions: RequestOptions(path: '')));

        // act
        final result = await repository.buyBook(tBookId);

        // assert
        expect(result, isA<Left<Failure, Book>>());
        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (book) => fail('Expected failure'),
        );
      });

      test('should return UnknownFailure when unknown exception occurs during buy', () async {
        // arrange
        when(() => mockRemoteDataSource.buyBook(tBookId))
            .thenThrow(Exception('Unknown error'));

        // act
        final result = await repository.buyBook(tBookId);

        // assert
        expect(result, isA<Left<Failure, Book>>());
        result.fold(
          (failure) => expect(failure, isA<UnknownFailure>()),
          (book) => fail('Expected failure'),
        );
      });
    });

    group('returnBook', () {
      test('should return book successfully and invalidate cache', () async {
        // arrange
        when(() => mockRemoteDataSource.returnBook(tBookId))
            .thenAnswer((_) async => tBook);
        when(() => mockLocalDataSource.clearCacheForBook(tBookId))
            .thenAnswer((_) async => {});

        // act
        final result = await repository.returnBook(tBookId);

        // assert
        verify(() => mockRemoteDataSource.returnBook(tBookId));
        verify(() => mockLocalDataSource.clearCacheForBook(tBookId));
        expect(result, equals(Right(tBook)));
      });

      test('should return NetworkFailure when DioException occurs during return', () async {
        // arrange
        when(() => mockRemoteDataSource.returnBook(tBookId))
            .thenThrow(DioException(requestOptions: RequestOptions(path: '')));

        // act
        final result = await repository.returnBook(tBookId);

        // assert
        expect(result, isA<Left<Failure, Book>>());
        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (book) => fail('Expected failure'),
        );
      });
    });

    group('renewBook', () {
      test('should renew book successfully and invalidate cache', () async {
        // arrange
        when(() => mockRemoteDataSource.renewBook(tBookId))
            .thenAnswer((_) async => tBook);
        when(() => mockLocalDataSource.clearCacheForBook(tBookId))
            .thenAnswer((_) async => {});

        // act
        final result = await repository.renewBook(tBookId);

        // assert
        verify(() => mockRemoteDataSource.renewBook(tBookId));
        verify(() => mockLocalDataSource.clearCacheForBook(tBookId));
        expect(result, equals(Right(tBook)));
      });

      test('should return NetworkFailure when DioException occurs during renew', () async {
        // arrange
        when(() => mockRemoteDataSource.renewBook(tBookId))
            .thenThrow(DioException(requestOptions: RequestOptions(path: '')));

        // act
        final result = await repository.renewBook(tBookId);

        // assert
        expect(result, isA<Left<Failure, Book>>());
        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (book) => fail('Expected failure'),
        );
      });
    });

    group('addToCart', () {
      test('should add book to cart successfully and invalidate cache', () async {
        // arrange
        when(() => mockRemoteDataSource.addToCart(tBookId))
            .thenAnswer((_) async => tBook);
        when(() => mockLocalDataSource.clearCacheForBook(tBookId))
            .thenAnswer((_) async => {});

        // act
        final result = await repository.addToCart(tBookId);

        // assert
        verify(() => mockRemoteDataSource.addToCart(tBookId));
        verify(() => mockLocalDataSource.clearCacheForBook(tBookId));
        expect(result, equals(Right(tBook)));
      });

      test('should return ServerFailure when DioException with bad response occurs', () async {
        // arrange
        when(() => mockRemoteDataSource.addToCart(tBookId))
            .thenThrow(DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 400,
            data: {'error': 'Book already in cart'},
          ),
        ));

        // act
        final result = await repository.addToCart(tBookId);

        // assert
        expect(result, isA<Left<Failure, Book>>());
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, contains('Client error'));
          },
          (book) => fail('Expected failure'),
        );
      });

      test('should return NetworkFailure when DioException with connection timeout occurs', () async {
        // arrange
        when(() => mockRemoteDataSource.addToCart(tBookId))
            .thenThrow(DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.connectionTimeout,
        ));

        // act
        final result = await repository.addToCart(tBookId);

        // assert
        expect(result, isA<Left<Failure, Book>>());
        result.fold(
          (failure) {
            expect(failure, isA<NetworkFailure>());
            expect(failure.message, equals('Connection timeout'));
          },
          (book) => fail('Expected failure'),
        );
      });

      test('should return UnknownFailure when unknown exception occurs', () async {
        // arrange
        when(() => mockRemoteDataSource.addToCart(tBookId))
            .thenThrow(Exception('Unknown error'));

        // act
        final result = await repository.addToCart(tBookId);

        // assert
        expect(result, isA<Left<Failure, Book>>());
        result.fold(
          (failure) {
            expect(failure, isA<UnknownFailure>());
            expect(failure.message, contains('Failed to add book to cart'));
          },
          (book) => fail('Expected failure'),
        );
      });
    });

    group('removeFromCart', () {
      test('should remove book from cart successfully and invalidate cache', () async {
        // arrange
        when(() => mockRemoteDataSource.removeFromCart(tBookId))
            .thenAnswer((_) async => tBook);
        when(() => mockLocalDataSource.clearCacheForBook(tBookId))
            .thenAnswer((_) async => {});

        // act
        final result = await repository.removeFromCart(tBookId);

        // assert
        verify(() => mockRemoteDataSource.removeFromCart(tBookId));
        verify(() => mockLocalDataSource.clearCacheForBook(tBookId));
        expect(result, equals(Right(tBook)));
      });

      test('should return ServerFailure when DioException with server error occurs', () async {
        // arrange
        when(() => mockRemoteDataSource.removeFromCart(tBookId))
            .thenThrow(DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 500,
            data: {'error': 'Internal server error'},
          ),
        ));

        // act
        final result = await repository.removeFromCart(tBookId);

        // assert
        expect(result, isA<Left<Failure, Book>>());
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, equals('Server error'));
          },
          (book) => fail('Expected failure'),
        );
      });

      test('should return NetworkFailure when DioException with connection error occurs', () async {
        // arrange
        when(() => mockRemoteDataSource.removeFromCart(tBookId))
            .thenThrow(DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.connectionError,
        ));

        // act
        final result = await repository.removeFromCart(tBookId);

        // assert
        expect(result, isA<Left<Failure, Book>>());
        result.fold(
          (failure) {
            expect(failure, isA<NetworkFailure>());
            expect(failure.message, equals('No internet connection'));
          },
          (book) => fail('Expected failure'),
        );
      });

      test('should return UnknownFailure when unknown exception occurs', () async {
        // arrange
        when(() => mockRemoteDataSource.removeFromCart(tBookId))
            .thenThrow(Exception('Unknown error'));

        // act
        final result = await repository.removeFromCart(tBookId);

        // assert
        expect(result, isA<Left<Failure, Book>>());
        result.fold(
          (failure) {
            expect(failure, isA<UnknownFailure>());
            expect(failure.message, contains('Failed to remove book from cart'));
          },
          (book) => fail('Expected failure'),
        );
      });
    });

    group('Error Handling Comprehensive', () {
      test('should handle all DioException types correctly', () async {
        final testCases = [
          (DioExceptionType.sendTimeout, 'Connection timeout'),
          (DioExceptionType.receiveTimeout, 'Connection timeout'),
          (DioExceptionType.badCertificate, 'Certificate error'),
          (DioExceptionType.cancel, 'Request cancelled'),
          (DioExceptionType.connectionError, 'No internet connection'),
          (DioExceptionType.unknown, 'Network error'),
        ];

        for (final testCase in testCases) {
          // arrange
          when(() => mockRemoteDataSource.rentBook(tBookId))
              .thenThrow(DioException(
            requestOptions: RequestOptions(path: ''),
            type: testCase.$1,
            message: 'Test error',
          ));

          // act
          final result = await repository.rentBook(tBookId);

          // assert
          expect(result, isA<Left<Failure, Book>>());
          result.fold(
            (failure) {
              expect(failure, isA<NetworkFailure>());
              expect(failure.message, contains(testCase.$2));
            },
            (book) => fail('Expected failure for ${testCase.$1}'),
          );
        }
      });
    });

    group('Repository without local datasource', () {
      late BookOperationsRepositoryImpl repositoryWithoutLocal;

      setUp(() {
        repositoryWithoutLocal = BookOperationsRepositoryImpl(
          remoteDataSource: mockRemoteDataSource,
          // No local datasource provided
        );
      });

      test('should handle all operations correctly without local datasource', () async {
        // arrange
        when(() => mockRemoteDataSource.rentBook(tBookId))
            .thenAnswer((_) async => tBook);
        when(() => mockRemoteDataSource.buyBook(tBookId))
            .thenAnswer((_) async => tBook);
        when(() => mockRemoteDataSource.returnBook(tBookId))
            .thenAnswer((_) async => tBook);
        when(() => mockRemoteDataSource.renewBook(tBookId))
            .thenAnswer((_) async => tBook);
        when(() => mockRemoteDataSource.addToCart(tBookId))
            .thenAnswer((_) async => tBook);
        when(() => mockRemoteDataSource.removeFromCart(tBookId))
            .thenAnswer((_) async => tBook);

        // act
        final results = await Future.wait([
          repositoryWithoutLocal.rentBook(tBookId),
          repositoryWithoutLocal.buyBook(tBookId),
          repositoryWithoutLocal.returnBook(tBookId),
          repositoryWithoutLocal.renewBook(tBookId),
          repositoryWithoutLocal.addToCart(tBookId),
          repositoryWithoutLocal.removeFromCart(tBookId),
        ]);

        // assert
        for (final result in results) {
          expect(result, equals(Right(tBook)));
        }
        verifyNever(() => mockLocalDataSource.clearCacheForBook(any()));
      });
    });
  });
}
