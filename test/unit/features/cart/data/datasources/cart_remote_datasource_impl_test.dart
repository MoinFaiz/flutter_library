import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_library/core/constants/app_constants.dart';
import 'package:flutter_library/core/error/exceptions.dart';
import 'package:flutter_library/features/cart/data/datasources/cart_remote_datasource_impl.dart';
import 'package:flutter_library/features/cart/data/models/cart_item_model.dart';
import 'package:flutter_library/features/cart/data/models/cart_request_model.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_item.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_request.dart';
import 'package:flutter_library/features/books/data/models/book_model.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late CartRemoteDataSourceImpl dataSource;
  late MockDio mockDio;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() {
    mockDio = MockDio();
    dataSource = CartRemoteDataSourceImpl(dio: mockDio);
  });

  group('CartRemoteDataSourceImpl', () {
    final testBook = BookModel(
      id: 'book1',
      title: 'Test Book',
      author: 'Test Author',
      imageUrls: const ['https://example.com/image.jpg'],
      rating: 4.5,
      pricing: const BookPricing(
        salePrice: 29.99,
        rentPrice: 9.99,
        minimumCostToBuy: 29.99,
        maximumCostToBuy: 29.99,
      ),
      availability: const BookAvailability(
        availableForRentCount: 5,
        availableForSaleCount: 3,
        totalCopies: 8,
      ),
      metadata: BookMetadata(
        isbn: '978-1234567890',
        publisher: 'Test Publisher',
        ageAppropriateness: AgeAppropriateness.adult,
        genres: const ['Fiction'],
        pageCount: 300,
        language: 'English',
        edition: '1st',
      ),
      isFromFriend: false,      description: 'Test',
      publishedYear: 2024,
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    );

    final testCartItem = CartItemModel(
      id: 'cart1',
      book: testBook.toEntity(),
      type: CartItemType.rent,
      addedAt: DateTime.now(),
      rentalPeriodInDays: 14,
    );

    final testRequest = CartRequestModel(
      id: 'req1',
      bookId: 'book1',
      bookTitle: 'Test Book',
      bookAuthor: 'Test Author',
      bookImageUrl: 'https://example.com/image.jpg',
      requesterId: 'user1',
      ownerId: 'owner1',
      requestType: CartItemType.rent,
      rentalPeriodInDays: 14,
      price: 10.0,
      status: RequestStatus.pending,
      createdAt: DateTime.now(),
    );

    group('getCartItems', () {
      test('should return list of cart items on success', () async {
        // Arrange
        when(() => mockDio.get(any())).thenAnswer((_) async => Response(
              data: {'data': [testCartItem.toJson()]},
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        // Act
        final result = await dataSource.getCartItems();

        // Assert
        expect(result, isA<List<CartItemModel>>());
        verify(() => mockDio.get('${AppConstants.baseUrl}/cart/items')).called(1);
      });

      test('should throw ServerException on non-200 status', () async {
        // Arrange
        when(() => mockDio.get(any())).thenAnswer((_) async => Response(
              statusCode: 404,
              requestOptions: RequestOptions(path: ''),
            ));

        // Act & Assert
        expect(() => dataSource.getCartItems(), throwsA(isA<ServerException>()));
      });

      test('should throw ServerException on DioException', () async {
        // Arrange
        when(() => mockDio.get(any())).thenThrow(DioException(
          requestOptions: RequestOptions(path: ''),
        ));

        // Act & Assert
        expect(() => dataSource.getCartItems(), throwsA(isA<ServerException>()));
      });

      test('should throw ServerException on generic exception', () async {
        // Arrange
        when(() => mockDio.get(any())).thenThrow(Exception('Error'));

        // Act & Assert
        expect(() => dataSource.getCartItems(), throwsA(isA<ServerException>()));
      });
    });

    group('addToCart', () {
      test('should return CartItemModel on success (200)', () async {
        // Arrange
        when(() => mockDio.post(any(), data: any(named: 'data')))
            .thenAnswer((_) async => Response(
                  data: {'data': testCartItem.toJson()},
                  statusCode: 200,
                  requestOptions: RequestOptions(path: ''),
                ));

        // Act
        final result = await dataSource.addToCart(
          bookId: 'book1',
          type: CartItemType.rent,
          rentalPeriodInDays: 14,
        );

        // Assert
        expect(result, isA<CartItemModel>());
      });

      test('should return CartItemModel on success (201)', () async {
        // Arrange
        when(() => mockDio.post(any(), data: any(named: 'data')))
            .thenAnswer((_) async => Response(
                  data: {'data': testCartItem.toJson()},
                  statusCode: 201,
                  requestOptions: RequestOptions(path: ''),
                ));

        // Act
        final result = await dataSource.addToCart(
          bookId: 'book1',
          type: CartItemType.rent,
        );

        // Assert
        expect(result, isA<CartItemModel>());
      });

      test('should throw ServerException on non-success status', () async {
        // Arrange
        when(() => mockDio.post(any(), data: any(named: 'data')))
            .thenAnswer((_) async => Response(
                  statusCode: 400,
                  requestOptions: RequestOptions(path: ''),
                ));

        // Act & Assert
        expect(
          () => dataSource.addToCart(bookId: 'book1', type: CartItemType.rent),
          throwsA(isA<ServerException>()),
        );
      });

      test('should throw ServerException on DioException', () async {
        // Arrange
        when(() => mockDio.post(any(), data: any(named: 'data')))
            .thenThrow(DioException(requestOptions: RequestOptions(path: '')));

        // Act & Assert
        expect(
          () => dataSource.addToCart(bookId: 'book1', type: CartItemType.rent),
          throwsA(isA<ServerException>()),
        );
      });

      test('should throw ServerException on generic exception', () async {
        // Arrange
        when(() => mockDio.post(any(), data: any(named: 'data')))
            .thenThrow(Exception('Error'));

        // Act & Assert
        expect(
          () => dataSource.addToCart(bookId: 'book1', type: CartItemType.rent),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('removeFromCart', () {
      test('should complete successfully on 200', () async {
        // Arrange
        when(() => mockDio.delete(any())).thenAnswer((_) async => Response(
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        // Act & Assert
        expect(() => dataSource.removeFromCart('cart1'), returnsNormally);
      });

      test('should complete successfully on 204', () async {
        // Arrange
        when(() => mockDio.delete(any())).thenAnswer((_) async => Response(
              statusCode: 204,
              requestOptions: RequestOptions(path: ''),
            ));

        // Act & Assert
        expect(() => dataSource.removeFromCart('cart1'), returnsNormally);
      });

      test('should throw ServerException on non-success status', () async {
        // Arrange
        when(() => mockDio.delete(any())).thenAnswer((_) async => Response(
              statusCode: 400,
              requestOptions: RequestOptions(path: ''),
            ));

        // Act & Assert
        expect(() => dataSource.removeFromCart('cart1'), throwsA(isA<ServerException>()));
      });

      test('should throw ServerException on DioException', () async {
        // Arrange
        when(() => mockDio.delete(any()))
            .thenThrow(DioException(requestOptions: RequestOptions(path: '')));

        // Act & Assert
        expect(() => dataSource.removeFromCart('cart1'), throwsA(isA<ServerException>()));
      });

      test('should throw ServerException on generic exception', () async {
        // Arrange
        when(() => mockDio.delete(any())).thenThrow(Exception('Error'));

        // Act & Assert
        expect(() => dataSource.removeFromCart('cart1'), throwsA(isA<ServerException>()));
      });
    });

    group('sendRentalRequest', () {
      test('should return CartRequestModel on success', () async {
        // Arrange
        when(() => mockDio.post(any(), data: any(named: 'data')))
            .thenAnswer((_) async => Response(
                  data: {'data': testRequest.toJson()},
                  statusCode: 200,
                  requestOptions: RequestOptions(path: ''),
                ));

        // Act
        final result = await dataSource.sendRentalRequest(
          bookId: 'book1',
          rentalPeriodInDays: 14,
        );

        // Assert
        expect(result, isA<CartRequestModel>());
      });

      test('should throw ServerException on error', () async {
        // Arrange
        when(() => mockDio.post(any(), data: any(named: 'data')))
            .thenThrow(DioException(requestOptions: RequestOptions(path: '')));

        // Act & Assert
        expect(
          () => dataSource.sendRentalRequest(bookId: 'book1', rentalPeriodInDays: 14),
          throwsA(isA<ServerException>()),
        );
      });

      test('should throw ServerException on generic exception', () async {
        // Arrange
        when(() => mockDio.post(any(), data: any(named: 'data')))
            .thenThrow(Exception('Error'));

        // Act & Assert
        expect(
          () => dataSource.sendRentalRequest(bookId: 'book1', rentalPeriodInDays: 14),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('sendPurchaseRequest', () {
      test('should return CartRequestModel on success', () async {
        // Arrange
        when(() => mockDio.post(any(), data: any(named: 'data')))
            .thenAnswer((_) async => Response(
                  data: {'data': testRequest.toJson()},
                  statusCode: 201,
                  requestOptions: RequestOptions(path: ''),
                ));

        // Act
        final result = await dataSource.sendPurchaseRequest(bookId: 'book1');

        // Assert
        expect(result, isA<CartRequestModel>());
      });

      test('should throw ServerException on DioException', () async {
        // Arrange
        when(() => mockDio.post(any(), data: any(named: 'data')))
            .thenThrow(DioException(requestOptions: RequestOptions(path: '')));

        // Act & Assert
        expect(
          () => dataSource.sendPurchaseRequest(bookId: 'book1'),
          throwsA(isA<ServerException>()),
        );
      });

      test('should throw ServerException on generic exception', () async {
        // Arrange
        when(() => mockDio.post(any(), data: any(named: 'data')))
            .thenThrow(Exception('Error'));

        // Act & Assert
        expect(
          () => dataSource.sendPurchaseRequest(bookId: 'book1'),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('getMyRequests', () {
      test('should return list of requests on success', () async {
        // Arrange
        when(() => mockDio.get(any())).thenAnswer((_) async => Response(
              data: {'data': [testRequest.toJson()]},
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        // Act
        final result = await dataSource.getMyRequests();

        // Assert
        expect(result, isA<List<CartRequestModel>>());
      });

      test('should throw ServerException on error', () async {
        // Arrange
        when(() => mockDio.get(any()))
            .thenThrow(DioException(requestOptions: RequestOptions(path: '')));

        // Act & Assert
        expect(() => dataSource.getMyRequests(), throwsA(isA<ServerException>()));
      });

      test('should throw ServerException on generic exception', () async {
        // Arrange
        when(() => mockDio.get(any())).thenThrow(Exception('Error'));

        // Act & Assert
        expect(() => dataSource.getMyRequests(), throwsA(isA<ServerException>()));
      });
    });

    group('getReceivedRequests', () {
      test('should return list of requests on success', () async {
        // Arrange
        when(() => mockDio.get(any())).thenAnswer((_) async => Response(
              data: {'data': [testRequest.toJson()]},
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        // Act
        final result = await dataSource.getReceivedRequests();

        // Assert
        expect(result, isA<List<CartRequestModel>>());
      });

      test('should throw ServerException on DioException', () async {
        // Arrange
        when(() => mockDio.get(any()))
            .thenThrow(DioException(requestOptions: RequestOptions(path: '')));

        // Act & Assert
        expect(() => dataSource.getReceivedRequests(), throwsA(isA<ServerException>()));
      });

      test('should throw ServerException on generic exception', () async {
        // Arrange
        when(() => mockDio.get(any())).thenThrow(Exception('Error'));

        // Act & Assert
        expect(() => dataSource.getReceivedRequests(), throwsA(isA<ServerException>()));
      });
    });

    group('acceptRequest', () {
      test('should complete successfully', () async {
        // Arrange
        when(() => mockDio.post(any())).thenAnswer((_) async => Response(
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        // Act & Assert
        expect(() => dataSource.acceptRequest('req1'), returnsNormally);
      });

      test('should throw ServerException on error', () async {
        // Arrange
        when(() => mockDio.post(any()))
            .thenThrow(DioException(requestOptions: RequestOptions(path: '')));

        // Act & Assert
        expect(() => dataSource.acceptRequest('req1'), throwsA(isA<ServerException>()));
      });

      test('should throw ServerException on generic exception', () async {
        // Arrange
        when(() => mockDio.post(any())).thenThrow(Exception('Error'));

        // Act & Assert
        expect(() => dataSource.acceptRequest('req1'), throwsA(isA<ServerException>()));
      });
    });

    group('rejectRequest', () {
      test('should complete successfully', () async {
        // Arrange
        when(() => mockDio.post(any())).thenAnswer((_) async => Response(
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        // Act & Assert
        expect(() => dataSource.rejectRequest('req1'), returnsNormally);
      });

      test('should throw ServerException on DioException', () async {
        // Arrange
        when(() => mockDio.post(any()))
            .thenThrow(DioException(requestOptions: RequestOptions(path: '')));

        // Act & Assert
        expect(() => dataSource.rejectRequest('req1'), throwsA(isA<ServerException>()));
      });

      test('should throw ServerException on generic exception', () async {
        // Arrange
        when(() => mockDio.post(any())).thenThrow(Exception('Error'));

        // Act & Assert
        expect(() => dataSource.rejectRequest('req1'), throwsA(isA<ServerException>()));
      });
    });

    group('cancelRequest', () {
      test('should complete successfully', () async {
        // Arrange
        when(() => mockDio.post(any())).thenAnswer((_) async => Response(
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        // Act & Assert
        expect(() => dataSource.cancelRequest('req1'), returnsNormally);
      });

      test('should throw ServerException on DioException', () async {
        // Arrange
        when(() => mockDio.post(any()))
            .thenThrow(DioException(requestOptions: RequestOptions(path: '')));

        // Act & Assert
        expect(() => dataSource.cancelRequest('req1'), throwsA(isA<ServerException>()));
      });

      test('should throw ServerException on generic exception', () async {
        // Arrange
        when(() => mockDio.post(any())).thenThrow(Exception('Error'));

        // Act & Assert
        expect(() => dataSource.cancelRequest('req1'), throwsA(isA<ServerException>()));
      });
    });

    group('clearCart', () {
      test('should complete successfully', () async {
        // Arrange
        when(() => mockDio.delete(any())).thenAnswer((_) async => Response(
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        // Act & Assert
        expect(() => dataSource.clearCart(), returnsNormally);
      });

      test('should throw ServerException on DioException', () async {
        // Arrange
        when(() => mockDio.delete(any()))
            .thenThrow(DioException(requestOptions: RequestOptions(path: '')));

        // Act & Assert
        expect(() => dataSource.clearCart(), throwsA(isA<ServerException>()));
      });

      test('should throw ServerException on generic exception', () async {
        // Arrange
        when(() => mockDio.delete(any())).thenThrow(Exception('Error'));

        // Act & Assert
        expect(() => dataSource.clearCart(), throwsA(isA<ServerException>()));
      });
    });

    group('getCartTotal', () {
      test('should return double on success', () async {
        // Arrange
        when(() => mockDio.get(any())).thenAnswer((_) async => Response(
              data: {'total': 99.99},
              statusCode: 200,
              requestOptions: RequestOptions(path: ''),
            ));

        // Act
        final result = await dataSource.getCartTotal();

        // Assert
        expect(result, equals(99.99));
      });

      test('should throw ServerException on error', () async {
        // Arrange
        when(() => mockDio.get(any()))
            .thenThrow(DioException(requestOptions: RequestOptions(path: '')));

        // Act & Assert
        expect(() => dataSource.getCartTotal(), throwsA(isA<ServerException>()));
      });

      test('should throw ServerException on generic exception', () async {
        // Arrange
        when(() => mockDio.get(any())).thenThrow(Exception('Error'));

        // Act & Assert
        expect(() => dataSource.getCartTotal(), throwsA(isA<ServerException>()));
      });
    });
  });
}
