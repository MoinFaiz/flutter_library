import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart' hide Order;
import 'package:flutter_library/features/orders/domain/usecases/get_user_orders_usecase.dart';
import 'package:flutter_library/features/orders/domain/usecases/create_order_usecase.dart';
import 'package:flutter_library/features/orders/domain/usecases/cancel_order_usecase.dart';
import 'package:flutter_library/features/orders/domain/usecases/get_order_by_id_usecase.dart';
import 'package:flutter_library/features/orders/domain/repositories/order_repository.dart';
import 'package:flutter_library/features/orders/domain/entities/order.dart';
import 'package:flutter_library/core/error/failures.dart';

class MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  group('Order Use Cases Tests', () {
    late MockOrderRepository mockRepository;
    late GetUserOrdersUseCase getUserOrdersUseCase;
    late CreateOrderUseCase createOrderUseCase;
    late CancelOrderUseCase cancelOrderUseCase;
    late GetOrderByIdUseCase getOrderByIdUseCase;

    setUp(() {
      mockRepository = MockOrderRepository();
      getUserOrdersUseCase = GetUserOrdersUseCase(repository: mockRepository);
      createOrderUseCase = CreateOrderUseCase(repository: mockRepository);
      cancelOrderUseCase = CancelOrderUseCase(repository: mockRepository);
      getOrderByIdUseCase = GetOrderByIdUseCase(repository: mockRepository);
    });

    final testDateTime = DateTime(2023, 6, 1);
    final mockOrder = Order(
      id: '1',
      bookId: 'book1',
      bookTitle: 'Test Book',
      bookImageUrl: 'https://example.com/book.jpg',
      bookAuthor: 'Test Author',
      type: OrderType.rental,
      status: OrderStatus.pending,
      price: 19.99,
      orderDate: testDateTime,
    );

    final mockOrderList = [
      mockOrder,
      Order(
        id: '2',
        bookId: 'book2',
        bookTitle: 'Test Book 2',
        bookImageUrl: 'https://example.com/book2.jpg',
        bookAuthor: 'Test Author 2',
        type: OrderType.purchase,
        status: OrderStatus.completed,
        price: 29.99,
        orderDate: testDateTime.subtract(const Duration(days: 1)),
      ),
    ];

    group('GetUserOrdersUseCase', () {
      test('should return list of orders when repository call is successful', () async {
        // arrange
        when(() => mockRepository.getUserOrders())
            .thenAnswer((_) async => Right(mockOrderList));

        // act
        final result = await getUserOrdersUseCase();

        // assert
        expect(result, equals(Right(mockOrderList)));
        verify(() => mockRepository.getUserOrders()).called(1);
      });

      test('should return empty list when user has no orders', () async {
        // arrange
        when(() => mockRepository.getUserOrders())
            .thenAnswer((_) async => const Right([]));

        // act
        final result = await getUserOrdersUseCase();

        // assert
        expect(result, equals(const Right(<Order>[])));
        verify(() => mockRepository.getUserOrders()).called(1);
      });

      test('should return ServerFailure when repository call fails', () async {
        // arrange
        when(() => mockRepository.getUserOrders())
            .thenAnswer((_) async => const Left(ServerFailure()));

        // act
        final result = await getUserOrdersUseCase();

        // assert
        expect(result, equals(const Left(ServerFailure())));
        verify(() => mockRepository.getUserOrders()).called(1);
      });

      test('should return NetworkFailure when network error occurs', () async {
        // arrange
        when(() => mockRepository.getUserOrders())
            .thenAnswer((_) async => const Left(NetworkFailure()));

        // act
        final result = await getUserOrdersUseCase();

        // assert
        expect(result, equals(const Left(NetworkFailure())));
        verify(() => mockRepository.getUserOrders()).called(1);
      });
    });

    group('CreateOrderUseCase', () {
      test('should return Order when creation is successful', () async {
        // arrange
        when(() => mockRepository.createOrder(
              bookId: 'book1',
              type: OrderType.rental,
              price: 19.99,
            )).thenAnswer((_) async => Right(mockOrder));

        // act
        final result = await createOrderUseCase(
          bookId: 'book1',
          type: OrderType.rental,
          price: 19.99,
        );

        // assert
        expect(result, equals(Right(mockOrder)));
        verify(() => mockRepository.createOrder(
              bookId: 'book1',
              type: OrderType.rental,
              price: 19.99,
            )).called(1);
      });

      test('should return ValidationFailure for invalid parameters', () async {
        // arrange
        when(() => mockRepository.createOrder(
              bookId: '',
              type: OrderType.rental,
              price: 19.99,
            )).thenAnswer((_) async => const Left(ValidationFailure('Invalid book ID')));

        // act
        final result = await createOrderUseCase(
          bookId: '',
          type: OrderType.rental,
          price: 19.99,
        );

        // assert
        expect(result, equals(const Left(ValidationFailure('Invalid book ID'))));
      });

      test('should return ServerFailure when creation fails', () async {
        // arrange
        when(() => mockRepository.createOrder(
              bookId: 'book1',
              type: OrderType.rental,
              price: 19.99,
            )).thenAnswer((_) async => const Left(ServerFailure()));

        // act
        final result = await createOrderUseCase(
          bookId: 'book1',
          type: OrderType.rental,
          price: 19.99,
        );

        // assert
        expect(result, equals(const Left(ServerFailure())));
      });

      test('should handle different order types correctly', () async {
        final orderTypes = [OrderType.rental, OrderType.purchase];
        
        for (final orderType in orderTypes) {
          final order = Order(
            id: '${orderType.index}',
            bookId: 'book1',
            bookTitle: 'Test Book',
            bookImageUrl: 'https://example.com/book.jpg',
            bookAuthor: 'Test Author',
            type: orderType,
            status: OrderStatus.pending,
            price: orderType == OrderType.rental ? 19.99 : 29.99,
            orderDate: testDateTime,
          );

          when(() => mockRepository.createOrder(
                bookId: 'book1',
                type: orderType,
                price: orderType == OrderType.rental ? 19.99 : 29.99,
              )).thenAnswer((_) async => Right(order));

          // act
          final result = await createOrderUseCase(
            bookId: 'book1',
            type: orderType,
            price: orderType == OrderType.rental ? 19.99 : 29.99,
          );

          // assert
          expect(result, equals(Right(order)));
        }
      });
    });

    group('CancelOrderUseCase', () {
      test('should return void when cancellation is successful', () async {
        // arrange
        when(() => mockRepository.cancelOrder('1'))
            .thenAnswer((_) async => const Right(null));

        // act
        final result = await cancelOrderUseCase('1');

        // assert
        expect(result, equals(const Right(null)));
        verify(() => mockRepository.cancelOrder('1')).called(1);
      });

      test('should return ValidationFailure for invalid order ID', () async {
        // arrange
        when(() => mockRepository.cancelOrder(''))
            .thenAnswer((_) async => const Left(ValidationFailure('Invalid order ID')));

        // act
        final result = await cancelOrderUseCase('');

        // assert
        expect(result, equals(const Left(ValidationFailure('Invalid order ID'))));
        verify(() => mockRepository.cancelOrder('')).called(1);
      });

      test('should return ValidationFailure when order cannot be cancelled', () async {
        // arrange
        when(() => mockRepository.cancelOrder('1'))
            .thenAnswer((_) async => const Left(ValidationFailure('Order cannot be cancelled')));

        // act
        final result = await cancelOrderUseCase('1');

        // assert
        expect(result, equals(const Left(ValidationFailure('Order cannot be cancelled'))));
        verify(() => mockRepository.cancelOrder('1')).called(1);
      });

      test('should return ServerFailure when cancellation fails', () async {
        // arrange
        when(() => mockRepository.cancelOrder('1'))
            .thenAnswer((_) async => const Left(ServerFailure()));

        // act
        final result = await cancelOrderUseCase('1');

        // assert
        expect(result, equals(const Left(ServerFailure())));
        verify(() => mockRepository.cancelOrder('1')).called(1);
      });
    });

    group('GetOrderByIdUseCase', () {
      test('should return Order when found successfully', () async {
        // arrange
        when(() => mockRepository.getOrderById('1'))
            .thenAnswer((_) async => Right(mockOrder));

        // act
        final result = await getOrderByIdUseCase('1');

        // assert
        expect(result, equals(Right(mockOrder)));
        verify(() => mockRepository.getOrderById('1')).called(1);
      });

      test('should return ValidationFailure for invalid order ID', () async {
        // arrange
        when(() => mockRepository.getOrderById(''))
            .thenAnswer((_) async => const Left(ValidationFailure('Invalid order ID')));

        // act
        final result = await getOrderByIdUseCase('');

        // assert
        expect(result, equals(const Left(ValidationFailure('Invalid order ID'))));
        verify(() => mockRepository.getOrderById('')).called(1);
      });

      test('should return ValidationFailure when order not found', () async {
        // arrange
        when(() => mockRepository.getOrderById('invalid'))
            .thenAnswer((_) async => const Left(ValidationFailure('Order not found')));

        // act
        final result = await getOrderByIdUseCase('invalid');

        // assert
        expect(result, equals(const Left(ValidationFailure('Order not found'))));
        verify(() => mockRepository.getOrderById('invalid')).called(1);
      });

      test('should return NetworkFailure when network error occurs', () async {
        // arrange
        when(() => mockRepository.getOrderById('1'))
            .thenAnswer((_) async => const Left(NetworkFailure()));

        // act
        final result = await getOrderByIdUseCase('1');

        // assert
        expect(result, equals(const Left(NetworkFailure())));
        verify(() => mockRepository.getOrderById('1')).called(1);
      });
    });

    group('Integration scenarios', () {
      test('should handle create followed by get order workflow', () async {
        // arrange
        when(() => mockRepository.createOrder(
              bookId: 'book1',
              type: OrderType.rental,
              price: 19.99,
            )).thenAnswer((_) async => Right(mockOrder));
        
        when(() => mockRepository.getOrderById('1'))
            .thenAnswer((_) async => Right(mockOrder));

        // act
        final createResult = await createOrderUseCase(
          bookId: 'book1',
          type: OrderType.rental,
          price: 19.99,
        );
        final getResult = await getOrderByIdUseCase('1');

        // assert
        expect(createResult, equals(Right(mockOrder)));
        expect(getResult, equals(Right(mockOrder)));
      });

      test('should handle multiple concurrent order creations', () async {
        // arrange
        final order1 = mockOrder;
        final order2 = Order(
          id: '2',
          bookId: 'book2',
          bookTitle: 'Test Book 2',
          bookImageUrl: 'https://example.com/book2.jpg',
          bookAuthor: 'Test Author 2',
          type: OrderType.purchase,
          status: OrderStatus.pending,
          price: 29.99,
          orderDate: testDateTime,
        );

        when(() => mockRepository.createOrder(
              bookId: 'book1',
              type: OrderType.rental,
              price: 19.99,
            )).thenAnswer((_) async => Right(order1));
        
        when(() => mockRepository.createOrder(
              bookId: 'book2',
              type: OrderType.purchase,
              price: 29.99,
            )).thenAnswer((_) async => Right(order2));

        // act
        final futures = await Future.wait([
          createOrderUseCase(
            bookId: 'book1',
            type: OrderType.rental,
            price: 19.99,
          ),
          createOrderUseCase(
            bookId: 'book2',
            type: OrderType.purchase,
            price: 29.99,
          ),
        ]);

        // assert
        expect(futures.length, equals(2));
        expect(futures[0], equals(Right(order1)));
        expect(futures[1], equals(Right(order2)));
      });
    });
  });
}
