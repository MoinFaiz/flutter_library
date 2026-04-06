import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:flutter_library/features/book_details/data/datasources/book_operations_remote_datasource.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/book_details/data/models/rental_status_model.dart';

class MockDio extends Mock implements Dio {}

void main() {
  group('BookOperationsRemoteDataSourceImpl', () {
    late BookOperationsRemoteDataSourceImpl dataSource;
    late MockDio mockDio;

    setUp(() {
      mockDio = MockDio();
      dataSource = BookOperationsRemoteDataSourceImpl(dio: mockDio);
    });

    group('rentBook', () {
      test('should return Book when rental is successful', () async {
        // Arrange
        const bookId = 'test-book-id';
        when(() => mockDio.post('/books/$bookId/rent'))
            .thenAnswer((_) async => Response(
                  data: {'success': true},
                  statusCode: 200,
                  requestOptions: RequestOptions(path: '/books/$bookId/rent'),
                ));

        // Act
        final result = await dataSource.rentBook(bookId);

        // Assert
        expect(result, isA<Book>());
        verify(() => mockDio.post('/books/$bookId/rent')).called(1);
      });

      test('should throw exception when rental fails with non-200 status', () async {
        // Arrange
        const bookId = 'test-book-id';
        when(() => mockDio.post('/books/$bookId/rent'))
            .thenAnswer((_) async => Response(
                  data: {'error': 'Book not available'},
                  statusCode: 400,
                  requestOptions: RequestOptions(path: '/books/$bookId/rent'),
                ));

        // Act & Assert
        expect(
          () => dataSource.rentBook(bookId),
          throwsA(isA<Exception>()),
        );
      });

      test('should throw exception when network error occurs', () async {
        // Arrange
        const bookId = 'test-book-id';
        when(() => mockDio.post('/books/$bookId/rent'))
            .thenThrow(DioException(
              requestOptions: RequestOptions(path: '/books/$bookId/rent'),
              message: 'Network error',
            ));

        // Act & Assert
        expect(
          () => dataSource.rentBook(bookId),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('buyBook', () {
      test('should return Book when purchase is successful', () async {
        // Arrange
        const bookId = 'test-book-id';
        when(() => mockDio.post('/books/$bookId/buy'))
            .thenAnswer((_) async => Response(
                  data: {'success': true},
                  statusCode: 200,
                  requestOptions: RequestOptions(path: '/books/$bookId/buy'),
                ));

        // Act
        final result = await dataSource.buyBook(bookId);

        // Assert
        expect(result, isA<Book>());
        verify(() => mockDio.post('/books/$bookId/buy')).called(1);
      });

      test('should throw exception when purchase fails', () async {
        // Arrange
        const bookId = 'test-book-id';
        when(() => mockDio.post('/books/$bookId/buy'))
            .thenAnswer((_) async => Response(
                  data: {'error': 'Payment failed'},
                  statusCode: 402,
                  requestOptions: RequestOptions(path: '/books/$bookId/buy'),
                ));

        // Act & Assert
        expect(
          () => dataSource.buyBook(bookId),
          throwsA(isA<Exception>()),
        );
      });

      test('should throw exception when network error occurs during purchase', () async {
        // Arrange
        const bookId = 'test-book-id';
        when(() => mockDio.post('/books/$bookId/buy'))
            .thenThrow(DioException(
              requestOptions: RequestOptions(path: '/books/$bookId/buy'),
              message: 'Network error',
            ));

        // Act & Assert
        expect(
          () => dataSource.buyBook(bookId),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('returnBook', () {
      test('should return Book when return is successful', () async {
        // Arrange
        const bookId = 'test-book-id';
        when(() => mockDio.post('/books/$bookId/return'))
            .thenAnswer((_) async => Response(
                  data: {'success': true},
                  statusCode: 200,
                  requestOptions: RequestOptions(path: '/books/$bookId/return'),
                ));

        // Act
        final result = await dataSource.returnBook(bookId);

        // Assert
        expect(result, isA<Book>());
        verify(() => mockDio.post('/books/$bookId/return')).called(1);
      });

      test('should throw exception when return fails with non-200 status', () async {
        // Arrange
        const bookId = 'test-book-id';
        when(() => mockDio.post('/books/$bookId/return'))
            .thenAnswer((_) async => Response(
                  data: {'error': 'Book not rented'},
                  statusCode: 400,
                  requestOptions: RequestOptions(path: '/books/$bookId/return'),
                ));

        // Act & Assert
        expect(
          () => dataSource.returnBook(bookId),
          throwsA(isA<Exception>()),
        );
      });

      test('should throw exception when network error occurs during return', () async {
        // Arrange
        const bookId = 'test-book-id';
        when(() => mockDio.post('/books/$bookId/return'))
            .thenThrow(DioException(
              requestOptions: RequestOptions(path: '/books/$bookId/return'),
              message: 'Network error',
            ));

        // Act & Assert
        expect(
          () => dataSource.returnBook(bookId),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('renewBook', () {
      test('should return Book when renewal is successful', () async {
        // Arrange
        const bookId = 'test-book-id';
        when(() => mockDio.post('/books/$bookId/renew'))
            .thenAnswer((_) async => Response(
                  data: {'success': true},
                  statusCode: 200,
                  requestOptions: RequestOptions(path: '/books/$bookId/renew'),
                ));

        // Act
        final result = await dataSource.renewBook(bookId);

        // Assert
        expect(result, isA<Book>());
        verify(() => mockDio.post('/books/$bookId/renew')).called(1);
      });

      test('should throw exception when renewal fails with non-200 status', () async {
        // Arrange
        const bookId = 'test-book-id';
        when(() => mockDio.post('/books/$bookId/renew'))
            .thenAnswer((_) async => Response(
                  data: {'error': 'Book cannot be renewed'},
                  statusCode: 400,
                  requestOptions: RequestOptions(path: '/books/$bookId/renew'),
                ));

        // Act & Assert
        expect(
          () => dataSource.renewBook(bookId),
          throwsA(isA<Exception>()),
        );
      });

      test('should throw exception when network error occurs during renewal', () async {
        // Arrange
        const bookId = 'test-book-id';
        when(() => mockDio.post('/books/$bookId/renew'))
            .thenThrow(DioException(
              requestOptions: RequestOptions(path: '/books/$bookId/renew'),
              message: 'Network error',
            ));

        // Act & Assert
        expect(
          () => dataSource.renewBook(bookId),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('addToCart', () {
      test('should return Book when adding to cart is successful', () async {
        // Arrange
        const bookId = 'test-book-id';
        when(() => mockDio.post('/books/$bookId/cart'))
            .thenAnswer((_) async => Response(
                  data: {'success': true},
                  statusCode: 200,
                  requestOptions: RequestOptions(path: '/books/$bookId/cart'),
                ));

        // Act
        final result = await dataSource.addToCart(bookId);

        // Assert
        expect(result, isA<Book>());
        verify(() => mockDio.post('/books/$bookId/cart')).called(1);
      });

      test('should throw exception when adding to cart fails with non-200 status', () async {
        // Arrange
        const bookId = 'test-book-id';
        when(() => mockDio.post('/books/$bookId/cart'))
            .thenAnswer((_) async => Response(
                  data: {'error': 'Book unavailable'},
                  statusCode: 400,
                  requestOptions: RequestOptions(path: '/books/$bookId/cart'),
                ));

        // Act & Assert
        expect(
          () => dataSource.addToCart(bookId),
          throwsA(isA<Exception>()),
        );
      });

      test('should throw exception when network error occurs while adding to cart', () async {
        // Arrange
        const bookId = 'test-book-id';
        when(() => mockDio.post('/books/$bookId/cart'))
            .thenThrow(DioException(
              requestOptions: RequestOptions(path: '/books/$bookId/cart'),
              message: 'Network error',
            ));

        // Act & Assert
        expect(
          () => dataSource.addToCart(bookId),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('removeFromCart', () {
      test('should return Book when removing from cart is successful', () async {
        // Arrange
        const bookId = 'test-book-id';
        when(() => mockDio.delete('/books/$bookId/cart'))
            .thenAnswer((_) async => Response(
                  data: {'success': true},
                  statusCode: 200,
                  requestOptions: RequestOptions(path: '/books/$bookId/cart'),
                ));

        // Act
        final result = await dataSource.removeFromCart(bookId);

        // Assert
        expect(result, isA<Book>());
        verify(() => mockDio.delete('/books/$bookId/cart')).called(1);
      });

      test('should throw exception when removing from cart fails with non-200 status', () async {
        // Arrange
        const bookId = 'test-book-id';
        when(() => mockDio.delete('/books/$bookId/cart'))
            .thenAnswer((_) async => Response(
                  data: {'error': 'Book not in cart'},
                  statusCode: 400,
                  requestOptions: RequestOptions(path: '/books/$bookId/cart'),
                ));

        // Act & Assert
        expect(
          () => dataSource.removeFromCart(bookId),
          throwsA(isA<Exception>()),
        );
      });

      test('should throw exception when network error occurs while removing from cart', () async {
        // Arrange
        const bookId = 'test-book-id';
        when(() => mockDio.delete('/books/$bookId/cart'))
            .thenThrow(DioException(
              requestOptions: RequestOptions(path: '/books/$bookId/cart'),
              message: 'Network error',
            ));

        // Act & Assert
        expect(
          () => dataSource.removeFromCart(bookId),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getRentalStatus', () {
      test('should return RentalStatusModel when request is successful', () async {
        // Arrange
        const bookId = 'test-book-id';
        when(() => mockDio.get('/books/$bookId/rental-status'))
            .thenAnswer((_) async => Response(
                  data: {
                    'bookId': bookId,
                    'status': 'rented',
                    'rentedAt': '2024-01-01T00:00:00Z',
                    'dueDate': '2024-01-15T00:00:00Z',
                  },
                  statusCode: 200,
                  requestOptions: RequestOptions(path: '/books/$bookId/rental-status'),
                ));

        // Act
        final result = await dataSource.getRentalStatus(bookId);

        // Assert
        expect(result, isA<RentalStatusModel>());
        verify(() => mockDio.get('/books/$bookId/rental-status')).called(1);
      });

      test('should throw exception when rental status request fails', () async {
        // Arrange
        const bookId = 'test-book-id';
        when(() => mockDio.get('/books/$bookId/rental-status'))
            .thenAnswer((_) async => Response(
                  data: {'error': 'Book not found'},
                  statusCode: 404,
                  requestOptions: RequestOptions(path: '/books/$bookId/rental-status'),
                ));

        // Act & Assert
        expect(
          () => dataSource.getRentalStatus(bookId),
          throwsA(isA<Exception>()),
        );
      });

      test('should throw exception when network error occurs during rental status request', () async {
        // Arrange
        const bookId = 'test-book-id';
        when(() => mockDio.get('/books/$bookId/rental-status'))
            .thenThrow(DioException(
              requestOptions: RequestOptions(path: '/books/$bookId/rental-status'),
              message: 'Network error',
            ));

        // Act & Assert
        expect(
          () => dataSource.getRentalStatus(bookId),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('_createMockBook', () {
      test('should create a valid Book entity with correct properties', () async {
        // This test ensures the private _createMockBook method is covered
        // We test it indirectly through a public method that uses it
        const bookId = 'test-book-id';
        when(() => mockDio.post('/books/$bookId/rent'))
            .thenAnswer((_) async => Response(
                  data: {'success': true},
                  statusCode: 200,
                  requestOptions: RequestOptions(path: '/books/$bookId/rent'),
                ));

        final result = await dataSource.rentBook(bookId);

        expect(result.id, equals(bookId));
        expect(result.title, equals('Mock Book Title'));
        expect(result.author, equals('Mock Author'));
        expect(result.imageUrls, equals(['https://example.com/book.jpg']));
        expect(result.rating, equals(4.0));
        expect(result.pricing.salePrice, equals(12.99));
        expect(result.pricing.rentPrice, equals(5.99));
        expect(result.availability.availableForRentCount, equals(10));
        expect(result.availability.availableForSaleCount, equals(5));
        expect(result.availability.totalCopies, equals(15));
        expect(result.metadata.isbn, equals('9781234567890'));
        expect(result.metadata.publisher, equals('Mock Publisher'));
        expect(result.metadata.genres, equals(['Fiction']));
        expect(result.metadata.pageCount, equals(200));
        expect(result.metadata.language, equals('English'));
        expect(result.metadata.edition, equals('1st Edition'));
        expect(result.isFromFriend, isFalse);
        expect(result.isFavorite, isFalse);
        expect(result.description, equals('Mock book description'));
        expect(result.publishedYear, equals(2023));
        expect(result.createdAt, isA<DateTime>());
        expect(result.updatedAt, isA<DateTime>());
      });
    });
  });
}
