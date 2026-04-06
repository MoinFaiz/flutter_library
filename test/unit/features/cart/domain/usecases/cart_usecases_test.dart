import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_item.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_request.dart';
import 'package:flutter_library/features/cart/domain/repositories/cart_repository.dart';
import 'package:flutter_library/features/cart/domain/usecases/accept_request_usecase.dart';
import 'package:flutter_library/features/cart/domain/usecases/get_cart_total_usecase.dart';
import 'package:flutter_library/features/cart/domain/usecases/get_received_requests_usecase.dart';
import 'package:flutter_library/features/cart/domain/usecases/reject_request_usecase.dart';
import 'package:flutter_library/features/cart/domain/usecases/remove_from_cart_usecase.dart';
import 'package:flutter_library/features/cart/domain/usecases/send_purchase_request_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCartRepository extends Mock implements CartRepository {}

void main() {
  late MockCartRepository mockRepository;

  setUp(() {
    mockRepository = MockCartRepository();
  });

  final testRequest = CartRequest(
    id: 'req1',
    bookId: 'book1',
    bookTitle: 'Test Book',
    bookAuthor: 'Test Author',
    bookImageUrl: 'url',
    requesterId: 'user1',
    ownerId: 'owner1',
    requestType: CartItemType.purchase,
    rentalPeriodInDays: 0,
    price: 49.99,
    status: RequestStatus.pending,
    createdAt: DateTime(2025, 10, 31),
  );

  group('SendPurchaseRequestUseCase', () {
    late SendPurchaseRequestUseCase usecase;

    setUp(() {
      usecase = SendPurchaseRequestUseCase(repository: mockRepository);
    });

    test('should send purchase request successfully', () async {
      // Arrange
      when(() => mockRepository.sendPurchaseRequest(bookId: any(named: 'bookId')))
          .thenAnswer((_) async => Right(testRequest));

      // Act
      final result = await usecase('book1');

      // Assert
      expect(result, Right(testRequest));
      verify(() => mockRepository.sendPurchaseRequest(bookId: 'book1')).called(1);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      const failure = ServerFailure(message: 'Server error');
      when(() => mockRepository.sendPurchaseRequest(bookId: any(named: 'bookId')))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase('book1');

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.sendPurchaseRequest(bookId: 'book1')).called(1);
    });

    test('should handle network failure', () async {
      // Arrange
      const failure = NetworkFailure();
      when(() => mockRepository.sendPurchaseRequest(bookId: any(named: 'bookId')))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase('book1');

      // Assert
      expect(result, const Left(failure));
    });
  });

  group('RemoveFromCartUseCase', () {
    late RemoveFromCartUseCase usecase;

    setUp(() {
      usecase = RemoveFromCartUseCase(repository: mockRepository);
    });

    test('should remove item from cart successfully', () async {
      // Arrange
      when(() => mockRepository.removeFromCart(any()))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await usecase('cart1');

      // Assert
      expect(result, const Right(null));
      verify(() => mockRepository.removeFromCart('cart1')).called(1);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      const failure = ServerFailure(message: 'Failed to remove item');
      when(() => mockRepository.removeFromCart(any()))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase('cart1');

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.removeFromCart('cart1')).called(1);
    });

    test('should handle not found failure', () async {
      // Arrange
      const failure = NotFoundFailure(message: 'Item not found');
      when(() => mockRepository.removeFromCart(any()))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase('cart1');

      // Assert
      expect(result, const Left(failure));
    });
  });

  group('GetCartTotalUseCase', () {
    late GetCartTotalUseCase usecase;

    setUp(() {
      usecase = GetCartTotalUseCase(repository: mockRepository);
    });

    test('should get cart total successfully', () async {
      // Arrange
      when(() => mockRepository.getCartTotal())
          .thenAnswer((_) async => const Right(129.99));

      // Act
      final result = await usecase();

      // Assert
      expect(result, const Right(129.99));
      verify(() => mockRepository.getCartTotal()).called(1);
    });

    test('should return zero when cart is empty', () async {
      // Arrange
      when(() => mockRepository.getCartTotal())
          .thenAnswer((_) async => const Right(0.0));

      // Act
      final result = await usecase();

      // Assert
      expect(result, const Right(0.0));
    });

    test('should return failure when repository fails', () async {
      // Arrange
      const failure = ServerFailure(message: 'Failed to calculate total');
      when(() => mockRepository.getCartTotal())
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase();

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.getCartTotal()).called(1);
    });
  });

  group('AcceptRequestUseCase', () {
    late AcceptRequestUseCase usecase;

    setUp(() {
      usecase = AcceptRequestUseCase(repository: mockRepository);
    });

    test('should accept request successfully', () async {
      // Arrange
      when(() => mockRepository.acceptRequest(any()))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await usecase('req1');

      // Assert
      expect(result, const Right(null));
      verify(() => mockRepository.acceptRequest('req1')).called(1);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      const failure = ServerFailure(message: 'Failed to accept request');
      when(() => mockRepository.acceptRequest(any()))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase('req1');

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.acceptRequest('req1')).called(1);
    });

    test('should handle permission failure', () async {
      // Arrange
      const failure = PermissionFailure(message: 'Not authorized');
      when(() => mockRepository.acceptRequest(any()))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase('req1');

      // Assert
      expect(result, const Left(failure));
    });
  });

  group('RejectRequestUseCase', () {
    late RejectRequestUseCase usecase;

    setUp(() {
      usecase = RejectRequestUseCase(repository: mockRepository);
    });

    test('should reject request successfully', () async {
      // Arrange
      when(() => mockRepository.rejectRequest(any()))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await usecase('req1');

      // Assert
      expect(result, const Right(null));
      verify(() => mockRepository.rejectRequest('req1')).called(1);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      const failure = ServerFailure(message: 'Failed to reject request');
      when(() => mockRepository.rejectRequest(any()))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase('req1');

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.rejectRequest('req1')).called(1);
    });
  });

  group('GetReceivedRequestsUseCase', () {
    late GetReceivedRequestsUseCase usecase;

    setUp(() {
      usecase = GetReceivedRequestsUseCase(repository: mockRepository);
    });

    test('should get received requests successfully', () async {
      // Arrange
      final requests = [testRequest];
      when(() => mockRepository.getReceivedRequests())
          .thenAnswer((_) async => Right(requests));

      // Act
      final result = await usecase();

      // Assert
      expect(result, Right(requests));
      verify(() => mockRepository.getReceivedRequests()).called(1);
    });

    test('should return empty list when no requests', () async {
      // Arrange
      when(() => mockRepository.getReceivedRequests())
          .thenAnswer((_) async => const Right(<CartRequest>[]));

      // Act
      final result = await usecase();

      // Assert
      result.fold(
        (l) => fail('Should return right'),
        (requests) => expect(requests, <CartRequest>[]),
      );
    });

    test('should return failure when repository fails', () async {
      // Arrange
      const failure = ServerFailure(message: 'Failed to fetch requests');
      when(() => mockRepository.getReceivedRequests())
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase();

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.getReceivedRequests()).called(1);
    });

    test('should handle multiple requests', () async {
      // Arrange
      final request2 = testRequest.copyWith(id: 'req2');
      final requests = [testRequest, request2];
      when(() => mockRepository.getReceivedRequests())
          .thenAnswer((_) async => Right(requests));

      // Act
      final result = await usecase();

      // Assert
      result.fold(
        (l) => fail('Should return right'),
        (requests) => expect(requests.length, 2),
      );
    });
  });
}
