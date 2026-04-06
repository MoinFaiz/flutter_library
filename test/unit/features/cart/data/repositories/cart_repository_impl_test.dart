import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/exceptions.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';
import 'package:flutter_library/features/cart/data/datasources/cart_local_datasource.dart';
import 'package:flutter_library/features/cart/data/datasources/cart_remote_datasource.dart';
import 'package:flutter_library/features/cart/data/models/cart_item_model.dart';
import 'package:flutter_library/features/cart/data/models/cart_request_model.dart';
import 'package:flutter_library/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_item.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_request.dart';

class MockCartRemoteDataSource extends Mock implements CartRemoteDataSource {}
class MockCartLocalDataSource extends Mock implements CartLocalDataSource {}

void main() {
  late CartRepositoryImpl repository;
  late MockCartRemoteDataSource mockRemoteDataSource;
  late MockCartLocalDataSource mockLocalDataSource;

  setUpAll(() {
    registerFallbackValue(CartItemType.rent);
  });

  setUp(() {
    mockRemoteDataSource = MockCartRemoteDataSource();
    mockLocalDataSource = MockCartLocalDataSource();
    repository = CartRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  final testBook = Book(
    id: 'book1',
    title: 'Test Book',
    author: 'Test Author',
    imageUrls: const ['url'],
    rating: 4.5,
    pricing: const BookPricing(salePrice: 20.0, rentPrice: 5.0),
    availability: const BookAvailability(
      availableForRentCount: 1,
      availableForSaleCount: 1,
      totalCopies: 1,
    ),
    metadata: const BookMetadata(
      genres: ['Fiction'],
      pageCount: 200,
      language: 'English',
      ageAppropriateness: AgeAppropriateness.adult,
    ),
    isFromFriend: false,
    isFavorite: false,
    description: 'Test',
    publishedYear: 2025,
    createdAt: DateTime(2025),
    updatedAt: DateTime(2025),
  );

  final testCartItem = CartItemModel(
    id: '1',
    book: testBook,
    type: CartItemType.rent,
    addedAt: DateTime.now(),
    rentalPeriodInDays: 14,
  );

  final testCartRequest = CartRequestModel(
    id: 'req1',
    bookId: 'book1',
    bookTitle: 'Test Book',
    bookAuthor: 'Author',
    bookImageUrl: '',
    requesterId: 'user1',
    ownerId: 'owner1',
    requestType: CartItemType.rent,
    rentalPeriodInDays: 14,
    price: 10.0,
    status: RequestStatus.pending,
    createdAt: DateTime.now(),
  );

  group('getCartItems', () {
    test('should return cart items from remote datasource on success', () async {
      // Arrange
      when(() => mockRemoteDataSource.getCartItems())
          .thenAnswer((_) async => [testCartItem]);
      when(() => mockLocalDataSource.cacheCartItems(any()))
          .thenAnswer((_) async => Future.value());

      // Act
      final result = await repository.getCartItems();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('Expected Right but got Left'),
        (r) => expect(r, equals([testCartItem])),
      );
      verify(() => mockRemoteDataSource.getCartItems()).called(1);
      verify(() => mockLocalDataSource.cacheCartItems([testCartItem])).called(1);
    });

    test('should return cached cart items when remote fails but cache has data', () async {
      // Arrange
      when(() => mockRemoteDataSource.getCartItems())
          .thenThrow(const ServerException('Server error'));
      when(() => mockLocalDataSource.getCachedCartItems())
          .thenAnswer((_) async => [testCartItem]);

      // Act
      final result = await repository.getCartItems();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('Expected Right but got Left'),
        (r) => expect(r, equals([testCartItem])),
      );
      verify(() => mockRemoteDataSource.getCartItems()).called(1);
      verify(() => mockLocalDataSource.getCachedCartItems()).called(1);
    });

    test('should return ServerFailure when remote fails and cache is empty', () async {
      // Arrange
      when(() => mockRemoteDataSource.getCartItems())
          .thenThrow(const ServerException('Server error'));
      when(() => mockLocalDataSource.getCachedCartItems())
          .thenAnswer((_) async => []);

      // Act
      final result = await repository.getCartItems();

      // Assert
      expect(result, equals(const Left(ServerFailure(message: 'Server error'))));
    });

    test('should return ServerFailure when remote fails and cache throws', () async {
      // Arrange
      when(() => mockRemoteDataSource.getCartItems())
          .thenThrow(const ServerException('Server error'));
      when(() => mockLocalDataSource.getCachedCartItems())
          .thenThrow(Exception('Cache error'));

      // Act
      final result = await repository.getCartItems();

      // Assert
      expect(result, equals(const Left<Failure, List<CartItem>>(ServerFailure(message: 'Server error'))));
    });

    test('should return ServerFailure when generic exception is thrown', () async {
      // Arrange
      when(() => mockRemoteDataSource.getCartItems())
          .thenThrow(Exception('Generic error'));

      // Act
      final result = await repository.getCartItems();

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<ServerFailure>()),
        (r) => fail('Expected Left but got Right'),
      );
    });
  });

  group('addToCart', () {
    test('should return cart item when remote datasource succeeds', () async {
      // Arrange
      when(() => mockRemoteDataSource.addToCart(
            bookId: any(named: 'bookId'),
            type: any(named: 'type'),
            rentalPeriodInDays: any(named: 'rentalPeriodInDays'),
          )).thenAnswer((_) async => testCartItem);

      // Act
      final result = await repository.addToCart(
        bookId: 'book1',
        type: CartItemType.rent,
        rentalPeriodInDays: 14,
      );

      // Assert
      expect(result, equals(Right(testCartItem)));
      verify(() => mockRemoteDataSource.addToCart(
            bookId: 'book1',
            type: CartItemType.rent,
            rentalPeriodInDays: 14,
          )).called(1);
    });

    test('should return ServerFailure when remote datasource throws ServerException', () async {
      // Arrange
      when(() => mockRemoteDataSource.addToCart(
            bookId: any(named: 'bookId'),
            type: any(named: 'type'),
            rentalPeriodInDays: any(named: 'rentalPeriodInDays'),
          )).thenThrow(const ServerException('Failed to add'));

      // Act
      final result = await repository.addToCart(
        bookId: 'book1',
        type: CartItemType.rent,
      );

      // Assert
      expect(result, equals(const Left(ServerFailure(message: 'Failed to add'))));
    });

    test('should return ServerFailure when generic exception is thrown', () async {
      // Arrange
      when(() => mockRemoteDataSource.addToCart(
            bookId: any(named: 'bookId'),
            type: any(named: 'type'),
            rentalPeriodInDays: any(named: 'rentalPeriodInDays'),
          )).thenThrow(Exception('Network error'));

      // Act
      final result = await repository.addToCart(
        bookId: 'book1',
        type: CartItemType.rent,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<ServerFailure>()),
        (r) => fail('Expected Left but got Right'),
      );
    });
  });

  group('removeFromCart', () {
    test('should return Right(null) when remote datasource succeeds', () async {
      // Arrange
      when(() => mockRemoteDataSource.removeFromCart(any()))
          .thenAnswer((_) async => Future.value());

      // Act
      final result = await repository.removeFromCart('item1');

      // Assert
      expect(result, equals(const Right(null)));
      verify(() => mockRemoteDataSource.removeFromCart('item1')).called(1);
    });

    test('should return ServerFailure when remote datasource throws ServerException', () async {
      // Arrange
      when(() => mockRemoteDataSource.removeFromCart(any()))
          .thenThrow(const ServerException('Failed to remove'));

      // Act
      final result = await repository.removeFromCart('item1');

      // Assert
      expect(result, equals(const Left(ServerFailure(message: 'Failed to remove'))));
    });

    test('should return ServerFailure when generic exception is thrown', () async {
      // Arrange
      when(() => mockRemoteDataSource.removeFromCart(any()))
          .thenThrow(Exception('Network error'));

      // Act
      final result = await repository.removeFromCart('item1');

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<ServerFailure>()),
        (r) => fail('Expected Left but got Right'),
      );
    });
  });

  group('sendRentalRequest', () {
    test('should return cart request when remote datasource succeeds', () async {
      // Arrange
      when(() => mockRemoteDataSource.sendRentalRequest(
            bookId: any(named: 'bookId'),
            rentalPeriodInDays: any(named: 'rentalPeriodInDays'),
          )).thenAnswer((_) async => testCartRequest);

      // Act
      final result = await repository.sendRentalRequest(
        bookId: 'book1',
        rentalPeriodInDays: 14,
      );

      // Assert
      expect(result, equals(Right(testCartRequest)));
      verify(() => mockRemoteDataSource.sendRentalRequest(
            bookId: 'book1',
            rentalPeriodInDays: 14,
          )).called(1);
    });

    test('should return ServerFailure when remote datasource throws ServerException', () async {
      // Arrange
      when(() => mockRemoteDataSource.sendRentalRequest(
            bookId: any(named: 'bookId'),
            rentalPeriodInDays: any(named: 'rentalPeriodInDays'),
          )).thenThrow(const ServerException('Request failed'));

      // Act
      final result = await repository.sendRentalRequest(
        bookId: 'book1',
        rentalPeriodInDays: 14,
      );

      // Assert
      expect(result, equals(const Left(ServerFailure(message: 'Request failed'))));
    });

    test('should return ServerFailure when generic exception is thrown', () async {
      // Arrange
      when(() => mockRemoteDataSource.sendRentalRequest(
            bookId: any(named: 'bookId'),
            rentalPeriodInDays: any(named: 'rentalPeriodInDays'),
          )).thenThrow(Exception('Network error'));

      // Act
      final result = await repository.sendRentalRequest(
        bookId: 'book1',
        rentalPeriodInDays: 14,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<ServerFailure>()),
        (r) => fail('Expected Left but got Right'),
      );
    });
  });

  group('sendPurchaseRequest', () {
    test('should return cart request when remote datasource succeeds', () async {
      // Arrange
      when(() => mockRemoteDataSource.sendPurchaseRequest(bookId: any(named: 'bookId')))
          .thenAnswer((_) async => testCartRequest);

      // Act
      final result = await repository.sendPurchaseRequest(bookId: 'book1');

      // Assert
      expect(result, equals(Right(testCartRequest)));
      verify(() => mockRemoteDataSource.sendPurchaseRequest(bookId: 'book1')).called(1);
    });

    test('should return ServerFailure when remote datasource throws ServerException', () async {
      // Arrange
      when(() => mockRemoteDataSource.sendPurchaseRequest(bookId: any(named: 'bookId')))
          .thenThrow(const ServerException('Request failed'));

      // Act
      final result = await repository.sendPurchaseRequest(bookId: 'book1');

      // Assert
      expect(result, equals(const Left(ServerFailure(message: 'Request failed'))));
    });

    test('should return ServerFailure when generic exception is thrown', () async {
      // Arrange
      when(() => mockRemoteDataSource.sendPurchaseRequest(bookId: any(named: 'bookId')))
          .thenThrow(Exception('Network error'));

      // Act
      final result = await repository.sendPurchaseRequest(bookId: 'book1');

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<ServerFailure>()),
        (r) => fail('Expected Left but got Right'),
      );
    });
  });

  group('getMyRequests', () {
    test('should return list of requests when remote datasource succeeds', () async {
      // Arrange
      when(() => mockRemoteDataSource.getMyRequests())
          .thenAnswer((_) async => [testCartRequest]);

      // Act
      final result = await repository.getMyRequests();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('Expected Right but got Left'),
        (r) => expect(r, equals([testCartRequest])),
      );
      verify(() => mockRemoteDataSource.getMyRequests()).called(1);
    });

    test('should return ServerFailure when remote datasource throws ServerException', () async {
      // Arrange
      when(() => mockRemoteDataSource.getMyRequests())
          .thenThrow(const ServerException('Failed to get requests'));

      // Act
      final result = await repository.getMyRequests();

      // Assert
      expect(result, equals(const Left(ServerFailure(message: 'Failed to get requests'))));
    });

    test('should return ServerFailure when generic exception is thrown', () async {
      // Arrange
      when(() => mockRemoteDataSource.getMyRequests())
          .thenThrow(Exception('Network error'));

      // Act
      final result = await repository.getMyRequests();

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<ServerFailure>()),
        (r) => fail('Expected Left but got Right'),
      );
    });
  });

  group('getReceivedRequests', () {
    test('should return list of requests when remote datasource succeeds', () async {
      // Arrange
      when(() => mockRemoteDataSource.getReceivedRequests())
          .thenAnswer((_) async => [testCartRequest]);

      // Act
      final result = await repository.getReceivedRequests();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('Expected Right but got Left'),
        (r) => expect(r, equals([testCartRequest])),
      );
      verify(() => mockRemoteDataSource.getReceivedRequests()).called(1);
    });

    test('should return ServerFailure when remote datasource throws ServerException', () async {
      // Arrange
      when(() => mockRemoteDataSource.getReceivedRequests())
          .thenThrow(const ServerException('Failed to get requests'));

      // Act
      final result = await repository.getReceivedRequests();

      // Assert
      expect(result, equals(const Left(ServerFailure(message: 'Failed to get requests'))));
    });

    test('should return ServerFailure when generic exception is thrown', () async {
      // Arrange
      when(() => mockRemoteDataSource.getReceivedRequests())
          .thenThrow(Exception('Network error'));

      // Act
      final result = await repository.getReceivedRequests();

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<ServerFailure>()),
        (r) => fail('Expected Left but got Right'),
      );
    });
  });

  group('acceptRequest', () {
    test('should return Right(null) when remote datasource succeeds', () async {
      // Arrange
      when(() => mockRemoteDataSource.acceptRequest(any()))
          .thenAnswer((_) async => Future.value());

      // Act
      final result = await repository.acceptRequest('req1');

      // Assert
      expect(result, equals(const Right(null)));
      verify(() => mockRemoteDataSource.acceptRequest('req1')).called(1);
    });

    test('should return ServerFailure when remote datasource throws ServerException', () async {
      // Arrange
      when(() => mockRemoteDataSource.acceptRequest(any()))
          .thenThrow(const ServerException('Failed to accept'));

      // Act
      final result = await repository.acceptRequest('req1');

      // Assert
      expect(result, equals(const Left(ServerFailure(message: 'Failed to accept'))));
    });

    test('should return ServerFailure when generic exception is thrown', () async {
      // Arrange
      when(() => mockRemoteDataSource.acceptRequest(any()))
          .thenThrow(Exception('Network error'));

      // Act
      final result = await repository.acceptRequest('req1');

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<ServerFailure>()),
        (r) => fail('Expected Left but got Right'),
      );
    });
  });

  group('rejectRequest', () {
    test('should return Right(null) when remote datasource succeeds', () async {
      // Arrange
      when(() => mockRemoteDataSource.rejectRequest(any()))
          .thenAnswer((_) async => Future.value());

      // Act
      final result = await repository.rejectRequest('req1');

      // Assert
      expect(result, equals(const Right(null)));
      verify(() => mockRemoteDataSource.rejectRequest('req1')).called(1);
    });

    test('should return ServerFailure when remote datasource throws ServerException', () async {
      // Arrange
      when(() => mockRemoteDataSource.rejectRequest(any()))
          .thenThrow(const ServerException('Failed to reject'));

      // Act
      final result = await repository.rejectRequest('req1');

      // Assert
      expect(result, equals(const Left(ServerFailure(message: 'Failed to reject'))));
    });

    test('should return ServerFailure when generic exception is thrown', () async {
      // Arrange
      when(() => mockRemoteDataSource.rejectRequest(any()))
          .thenThrow(Exception('Network error'));

      // Act
      final result = await repository.rejectRequest('req1');

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<ServerFailure>()),
        (r) => fail('Expected Left but got Right'),
      );
    });
  });

  group('cancelRequest', () {
    test('should return Right(null) when remote datasource succeeds', () async {
      // Arrange
      when(() => mockRemoteDataSource.cancelRequest(any()))
          .thenAnswer((_) async => Future.value());

      // Act
      final result = await repository.cancelRequest('req1');

      // Assert
      expect(result, equals(const Right(null)));
      verify(() => mockRemoteDataSource.cancelRequest('req1')).called(1);
    });

    test('should return ServerFailure when remote datasource throws ServerException', () async {
      // Arrange
      when(() => mockRemoteDataSource.cancelRequest(any()))
          .thenThrow(const ServerException('Failed to cancel'));

      // Act
      final result = await repository.cancelRequest('req1');

      // Assert
      expect(result, equals(const Left(ServerFailure(message: 'Failed to cancel'))));
    });

    test('should return ServerFailure when generic exception is thrown', () async {
      // Arrange
      when(() => mockRemoteDataSource.cancelRequest(any()))
          .thenThrow(Exception('Network error'));

      // Act
      final result = await repository.cancelRequest('req1');

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<ServerFailure>()),
        (r) => fail('Expected Left but got Right'),
      );
    });
  });

  group('clearCart', () {
    test('should clear both remote and local when successful', () async {
      // Arrange
      when(() => mockRemoteDataSource.clearCart())
          .thenAnswer((_) async => Future.value());
      when(() => mockLocalDataSource.clearCache())
          .thenAnswer((_) async => Future.value());

      // Act
      final result = await repository.clearCart();

      // Assert
      expect(result, equals(const Right(null)));
      verify(() => mockRemoteDataSource.clearCart()).called(1);
      verify(() => mockLocalDataSource.clearCache()).called(1);
    });

    test('should return ServerFailure when remote datasource throws ServerException', () async {
      // Arrange
      when(() => mockRemoteDataSource.clearCart())
          .thenThrow(const ServerException('Failed to clear'));

      // Act
      final result = await repository.clearCart();

      // Assert
      expect(result, equals(const Left(ServerFailure(message: 'Failed to clear'))));
    });

    test('should return ServerFailure when generic exception is thrown', () async {
      // Arrange
      when(() => mockRemoteDataSource.clearCart())
          .thenThrow(Exception('Network error'));

      // Act
      final result = await repository.clearCart();

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<ServerFailure>()),
        (r) => fail('Expected Left but got Right'),
      );
    });
  });

  group('getCartTotal', () {
    test('should return total when remote datasource succeeds', () async {
      // Arrange
      when(() => mockRemoteDataSource.getCartTotal())
          .thenAnswer((_) async => 99.99);

      // Act
      final result = await repository.getCartTotal();

      // Assert
      expect(result, equals(const Right(99.99)));
      verify(() => mockRemoteDataSource.getCartTotal()).called(1);
    });

    test('should return ServerFailure when remote datasource throws ServerException', () async {
      // Arrange
      when(() => mockRemoteDataSource.getCartTotal())
          .thenThrow(const ServerException('Failed to get total'));

      // Act
      final result = await repository.getCartTotal();

      // Assert
      expect(result, equals(const Left(ServerFailure(message: 'Failed to get total'))));
    });

    test('should return ServerFailure when generic exception is thrown', () async {
      // Arrange
      when(() => mockRemoteDataSource.getCartTotal())
          .thenThrow(Exception('Network error'));

      // Act
      final result = await repository.getCartTotal();

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<ServerFailure>()),
        (r) => fail('Expected Left but got Right'),
      );
    });
  });
}
