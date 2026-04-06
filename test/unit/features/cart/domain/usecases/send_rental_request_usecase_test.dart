import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_item.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_request.dart';
import 'package:flutter_library/features/cart/domain/repositories/cart_repository.dart';
import 'package:flutter_library/features/cart/domain/usecases/send_rental_request_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCartRepository extends Mock implements CartRepository {}

void main() {
  late SendRentalRequestUseCase usecase;
  late MockCartRepository mockRepository;

  setUp(() {
    mockRepository = MockCartRepository();
    usecase = SendRentalRequestUseCase(repository: mockRepository);
  });

  final testRequest = CartRequest(
    id: 'req1',
    bookId: 'book1',
    bookTitle: 'Test Book',
    bookAuthor: 'Test Author',
    bookImageUrl: 'url',
    requesterId: 'user1',
    ownerId: 'owner1',
    requestType: CartItemType.rent,
    rentalPeriodInDays: 14,
    price: 29.99,
    status: RequestStatus.pending,
    createdAt: DateTime(2025, 10, 31),
  );

  group('SendRentalRequestUseCase', () {
    test('should send rental request with default period', () async {
      // Arrange
      final params = SendRentalRequestParams(bookId: 'book1');
      when(() => mockRepository.sendRentalRequest(
            bookId: any(named: 'bookId'),
            rentalPeriodInDays: any(named: 'rentalPeriodInDays'),
          )).thenAnswer((_) async => Right(testRequest));

      // Act
      final result = await usecase(params);

      // Assert
      expect(result, Right(testRequest));
      verify(() => mockRepository.sendRentalRequest(
            bookId: 'book1',
            rentalPeriodInDays: 14,
          )).called(1);
    });

    test('should send rental request with custom period', () async {
      // Arrange
      final params = SendRentalRequestParams(
        bookId: 'book1',
        rentalPeriodInDays: 30,
      );
      when(() => mockRepository.sendRentalRequest(
            bookId: any(named: 'bookId'),
            rentalPeriodInDays: any(named: 'rentalPeriodInDays'),
          )).thenAnswer((_) async => Right(testRequest));

      // Act
      final result = await usecase(params);

      // Assert
      expect(result, Right(testRequest));
      verify(() => mockRepository.sendRentalRequest(
            bookId: 'book1',
            rentalPeriodInDays: 30,
          )).called(1);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      final params = SendRentalRequestParams(bookId: 'book1');
      const failure = ServerFailure(message: 'Server error');
      when(() => mockRepository.sendRentalRequest(
            bookId: any(named: 'bookId'),
            rentalPeriodInDays: any(named: 'rentalPeriodInDays'),
          )).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(params);

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.sendRentalRequest(
            bookId: 'book1',
            rentalPeriodInDays: 14,
          )).called(1);
    });

    test('SendRentalRequestParams should have correct default value', () {
      final params = SendRentalRequestParams(bookId: 'book1');
      expect(params.bookId, 'book1');
      expect(params.rentalPeriodInDays, 14);
    });

    test('SendRentalRequestParams should accept custom rental period', () {
      final params = SendRentalRequestParams(
        bookId: 'book1',
        rentalPeriodInDays: 21,
      );
      expect(params.bookId, 'book1');
      expect(params.rentalPeriodInDays, 21);
    });
  });
}
