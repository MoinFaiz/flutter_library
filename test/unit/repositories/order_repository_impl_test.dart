import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_library/features/orders/data/repositories/order_repository_impl.dart';
import 'package:flutter_library/features/orders/data/datasources/order_remote_datasource.dart';
import 'package:flutter_library/features/orders/data/models/order_model.dart';
import 'package:flutter_library/features/orders/domain/entities/order.dart';
import 'package:flutter_library/core/error/failures.dart';

class MockOrderRemoteDataSource extends Mock implements OrderRemoteDataSource {}

void main() {
  setUpAll(() {
    registerFallbackValue(OrderStatus.pending);
    registerFallbackValue(OrderType.purchase);
  });

  group('OrderRepositoryImpl', () {
    late OrderRepositoryImpl repository;
    late MockOrderRemoteDataSource mockRemoteDataSource;

    setUp(() {
      mockRemoteDataSource = MockOrderRemoteDataSource();
      repository = OrderRepositoryImpl(remoteDataSource: mockRemoteDataSource);
    });

    final testOrder1 = OrderModel(
      id: '1',
      bookId: 'book1',
      bookTitle: 'Test Book 1',
      bookImageUrl: 'image1.jpg',
      bookAuthor: 'Author 1',
      type: OrderType.rental,
      status: OrderStatus.pending,
      price: 5.99,
      orderDate: DateTime.now(),
    );

    final testOrder2 = OrderModel(
      id: '2',
      bookId: 'book2',
      bookTitle: 'Test Book 2',
      bookImageUrl: 'image2.jpg',
      bookAuthor: 'Author 2',
      type: OrderType.purchase,
      status: OrderStatus.completed,
      price: 24.99,
      orderDate: DateTime.now().subtract(const Duration(days: 1)),
    );

    final testOrder3 = OrderModel(
      id: '3',
      bookId: 'book3',
      bookTitle: 'Test Book 3',
      bookImageUrl: 'image3.jpg',
      bookAuthor: 'Author 3',
      type: OrderType.rental,
      status: OrderStatus.cancelled,
      price: 5.99,
      orderDate: DateTime.now().subtract(const Duration(days: 2)),
    );

    final testOrders = [testOrder1, testOrder2, testOrder3];

    group('getUserOrders', () {
      test('should return sorted orders when remote data source succeeds', () async {
        // Arrange
        when(() => mockRemoteDataSource.getUserOrders())
            .thenAnswer((_) async => testOrders);

        // Act
        final result = await repository.getUserOrders();

        // Assert
        expect(result, isA<Right>());
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (orders) {
            expect(orders.length, equals(3));
            
            // Verify sorting: active orders first, then by date (latest first)
            expect(orders[0].isActive, isTrue); // testOrder1 (pending - active)
            expect(orders[1].status, equals(OrderStatus.completed)); // testOrder2 (latest inactive)
            expect(orders[2].status, equals(OrderStatus.cancelled)); // testOrder3 (oldest inactive)
          },
        );
        verify(() => mockRemoteDataSource.getUserOrders()).called(1);
      });

      test('should return ServerFailure when remote data source throws exception', () async {
        // Arrange
        when(() => mockRemoteDataSource.getUserOrders())
            .thenThrow(Exception('Network error'));

        // Act
        final result = await repository.getUserOrders();

        // Assert
        expect(result, isA<Left>());
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, contains('Failed to load orders'));
            expect(failure.message, contains('Network error'));
          },
          (orders) => fail('Expected Left but got Right'),
        );
        verify(() => mockRemoteDataSource.getUserOrders()).called(1);
      });

      test('should return empty list when no orders exist', () async {
        // Arrange
        when(() => mockRemoteDataSource.getUserOrders())
            .thenAnswer((_) async => []);

        // Act
        final result = await repository.getUserOrders();

        // Assert
        expect(result, isA<Right>());
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (orders) => expect(orders, isEmpty),
        );
        verify(() => mockRemoteDataSource.getUserOrders()).called(1);
      });

      test('should handle orders with same dates correctly', () async {
        // Arrange
        final sameDateTime = DateTime.now();
        final ordersWithSameDate = [
          testOrder1.copyWith(orderDate: sameDateTime, status: OrderStatus.pending),
          testOrder2.copyWith(orderDate: sameDateTime, status: OrderStatus.completed),
          testOrder3.copyWith(orderDate: sameDateTime, status: OrderStatus.processing),
        ];

        when(() => mockRemoteDataSource.getUserOrders())
            .thenAnswer((_) async => ordersWithSameDate);

        // Act
        final result = await repository.getUserOrders();

        // Assert
        expect(result, isA<Right>());
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (orders) {
            expect(orders.length, equals(3));
            // Active orders should come first
            expect(orders[0].isActive, isTrue);
            expect(orders[1].isActive, isTrue);
            expect(orders[2].isActive, isFalse);
          },
        );
      });
    });

    group('getOrderById', () {
      test('should return order when remote data source succeeds', () async {
        // Arrange
        const orderId = '1';
        when(() => mockRemoteDataSource.getOrderById(orderId))
            .thenAnswer((_) async => testOrder1);

        // Act
        final result = await repository.getOrderById(orderId);

        // Assert
        expect(result, isA<Right>());
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (order) {
            expect(order.id, equals('1'));
            expect(order.bookId, equals('book1'));
            expect(order.type, equals(OrderType.rental));
          },
        );
        verify(() => mockRemoteDataSource.getOrderById(orderId)).called(1);
      });

      test('should return ServerFailure when remote data source throws exception', () async {
        // Arrange
        const orderId = 'non-existent';
        when(() => mockRemoteDataSource.getOrderById(orderId))
            .thenThrow(Exception('Order not found'));

        // Act
        final result = await repository.getOrderById(orderId);

        // Assert
        expect(result, isA<Left>());
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, contains('Failed to load order'));
            expect(failure.message, contains('Order not found'));
          },
          (order) => fail('Expected Left but got Right'),
        );
        verify(() => mockRemoteDataSource.getOrderById(orderId)).called(1);
      });

      test('should handle empty or null order ID', () async {
        // Arrange
        const emptyOrderId = '';
        when(() => mockRemoteDataSource.getOrderById(emptyOrderId))
            .thenThrow(Exception('Invalid order ID'));

        // Act
        final result = await repository.getOrderById(emptyOrderId);

        // Assert
        expect(result, isA<Left>());
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, contains('Failed to load order'));
          },
          (order) => fail('Expected Left but got Right'),
        );
      });
    });

    group('createOrder', () {
      test('should return created order when remote data source succeeds', () async {
        // Arrange
        const bookId = 'book1';
        final type = OrderType.rental;
        const price = 5.99;
        
        when(() => mockRemoteDataSource.createOrder(
          bookId: bookId,
          type: type.name,
          price: price,
        )).thenAnswer((_) async => testOrder1);

        // Act
        final result = await repository.createOrder(
          bookId: bookId,
          type: type,
          price: price,
        );

        // Assert
        expect(result, isA<Right>());
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (order) {
            expect(order.bookId, equals(bookId));
            expect(order.type, equals(type));
            expect(order.price, equals(price));
          },
        );
        verify(() => mockRemoteDataSource.createOrder(
          bookId: bookId,
          type: type.name,
          price: price,
        )).called(1);
      });

      test('should return ServerFailure when remote data source throws exception', () async {
        // Arrange
        const bookId = 'book1';
        final type = OrderType.rental;
        const price = 5.99;
        
        when(() => mockRemoteDataSource.createOrder(
          bookId: any(named: 'bookId'),
          type: any(named: 'type'),
          price: any(named: 'price'),
        )).thenThrow(Exception('Failed to create order'));

        // Act
        final result = await repository.createOrder(
          bookId: bookId,
          type: type,
          price: price,
        );

        // Assert
        expect(result, isA<Left>());
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, contains('Failed to create order'));
          },
          (order) => fail('Expected Left but got Right'),
        );
      });

      test('should handle different order types correctly', () async {
        // Test rent order
        when(() => mockRemoteDataSource.createOrder(
          bookId: 'book1',
          type: 'rental',
          price: 5.99,
        )).thenAnswer((_) async => testOrder1);

        final rentResult = await repository.createOrder(
          bookId: 'book1',
          type: OrderType.rental,
          price: 5.99,
        );

        expect(rentResult, isA<Right>());

        // Test purchase order
        when(() => mockRemoteDataSource.createOrder(
          bookId: 'book2',
          type: 'purchase',
          price: 24.99,
        )).thenAnswer((_) async => testOrder2);

        final purchaseResult = await repository.createOrder(
          bookId: 'book2',
          type: OrderType.purchase,
          price: 24.99,
        );

        expect(purchaseResult, isA<Right>());
      });

      test('should handle edge case prices', () async {
        // Test zero price
        when(() => mockRemoteDataSource.createOrder(
          bookId: 'book1',
          type: 'rental',
          price: 0.0,
        )).thenAnswer((_) async => testOrder1.copyWith(price: 0.0));

        final zeroResult = await repository.createOrder(
          bookId: 'book1',
          type: OrderType.rental,
          price: 0.0,
        );

        expect(zeroResult, isA<Right>());

        // Test very high price
        const highPrice = 999999.99;
        when(() => mockRemoteDataSource.createOrder(
          bookId: 'book1',
          type: 'purchase',
          price: highPrice,
        )).thenAnswer((_) async => testOrder1.copyWith(price: highPrice));

        final highPriceResult = await repository.createOrder(
          bookId: 'book1',
          type: OrderType.purchase,
          price: highPrice,
        );

        expect(highPriceResult, isA<Right>());
      });
    });

    group('updateOrderStatus', () {
      test('should return updated order when remote data source succeeds', () async {
        // Arrange
        const orderId = '1';
        const newStatus = OrderStatus.shipped;
        final updatedOrder = testOrder1.copyWith(status: newStatus);
        
        when(() => mockRemoteDataSource.updateOrderStatus(
          orderId: orderId,
          status: newStatus.name,
        )).thenAnswer((_) async => updatedOrder);

        // Act
        final result = await repository.updateOrderStatus(
          orderId: orderId,
          status: newStatus,
        );

        // Assert
        expect(result, isA<Right>());
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (order) {
            expect(order.id, equals('1'));
            expect(order.status, equals(newStatus));
          },
        );
        verify(() => mockRemoteDataSource.updateOrderStatus(
          orderId: orderId,
          status: newStatus.name,
        )).called(1);
      });

      test('should return ServerFailure when remote data source throws exception', () async {
        // Arrange
        const orderId = 'non-existent';
        const newStatus = OrderStatus.shipped;
        when(() => mockRemoteDataSource.updateOrderStatus(
          orderId: orderId,
          status: newStatus.name,
        )).thenThrow(Exception('Order not found'));

        // Act
        final result = await repository.updateOrderStatus(
          orderId: orderId,
          status: newStatus,
        );

        // Assert
        expect(result, isA<Left>());
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, contains('Failed to update order'));
            expect(failure.message, contains('Order not found'));
          },
          (order) => fail('Expected Left but got Right'),
        );
      });

      test('should handle all order status types correctly', () async {
        // Test all status transitions
        final statuses = [
          OrderStatus.pending,
          OrderStatus.processing,
          OrderStatus.shipped,
          OrderStatus.delivered,
          OrderStatus.completed,
          OrderStatus.cancelled,
        ];

        for (final status in statuses) {
          when(() => mockRemoteDataSource.updateOrderStatus(
            orderId: '1',
            status: status.name,
          )).thenAnswer((_) async => testOrder1.copyWith(status: status));

          final result = await repository.updateOrderStatus(
            orderId: '1',
            status: status,
          );

          expect(result, isA<Right>());
          result.fold(
            (failure) => fail('Expected Right but got Left for status $status'),
            (order) => expect(order.status, equals(status)),
          );
        }
      });
    });

    group('getActiveOrders', () {
      test('should return only active orders when remote data source succeeds', () async {
        // Arrange
        final allOrders = [
          testOrder1.copyWith(status: OrderStatus.pending), // active
          testOrder2.copyWith(status: OrderStatus.completed), // inactive
          testOrder3.copyWith(status: OrderStatus.processing), // active
        ];
        
        when(() => mockRemoteDataSource.getUserOrders())
            .thenAnswer((_) async => allOrders);

        // Act
        final result = await repository.getActiveOrders();

        // Assert
        expect(result, isA<Right>());
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (orders) {
            expect(orders.length, equals(2));
            expect(orders.every((order) => order.isActive), isTrue);
            // Should be sorted by date (latest first)
            expect(orders[0].orderDate.isAfter(orders[1].orderDate) || 
                   orders[0].orderDate.isAtSameMomentAs(orders[1].orderDate), isTrue);
          },
        );
        verify(() => mockRemoteDataSource.getUserOrders()).called(1);
      });

      test('should return empty list when no active orders exist', () async {
        // Arrange
        final inactiveOrders = [
          testOrder1.copyWith(status: OrderStatus.completed),
          testOrder2.copyWith(status: OrderStatus.cancelled),
        ];
        
        when(() => mockRemoteDataSource.getUserOrders())
            .thenAnswer((_) async => inactiveOrders);

        // Act
        final result = await repository.getActiveOrders();

        // Assert
        expect(result, isA<Right>());
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (orders) => expect(orders, isEmpty),
        );
      });

      test('should return ServerFailure when remote data source throws exception', () async {
        // Arrange
        when(() => mockRemoteDataSource.getUserOrders())
            .thenThrow(Exception('Network error'));

        // Act
        final result = await repository.getActiveOrders();

        // Assert
        expect(result, isA<Left>());
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, contains('Failed to load active orders'));
          },
          (orders) => fail('Expected Left but got Right'),
        );
      });
    });

    group('getOrderHistory', () {
      test('should return only inactive orders when remote data source succeeds', () async {
        // Arrange
        final allOrders = [
          testOrder1.copyWith(status: OrderStatus.pending), // active
          testOrder2.copyWith(status: OrderStatus.completed), // inactive
          testOrder3.copyWith(status: OrderStatus.cancelled), // inactive
        ];
        
        when(() => mockRemoteDataSource.getUserOrders())
            .thenAnswer((_) async => allOrders);

        // Act
        final result = await repository.getOrderHistory();

        // Assert
        expect(result, isA<Right>());
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (orders) {
            expect(orders.length, equals(2));
            expect(orders.every((order) => !order.isActive), isTrue);
            // Should be sorted by date (latest first)
            expect(orders[0].orderDate.isAfter(orders[1].orderDate) || 
                   orders[0].orderDate.isAtSameMomentAs(orders[1].orderDate), isTrue);
          },
        );
        verify(() => mockRemoteDataSource.getUserOrders()).called(1);
      });

      test('should return empty list when no order history exists', () async {
        // Arrange
        final activeOrders = [
          testOrder1.copyWith(status: OrderStatus.pending),
          testOrder2.copyWith(status: OrderStatus.processing),
        ];
        
        when(() => mockRemoteDataSource.getUserOrders())
            .thenAnswer((_) async => activeOrders);

        // Act
        final result = await repository.getOrderHistory();

        // Assert
        expect(result, isA<Right>());
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (orders) => expect(orders, isEmpty),
        );
      });

      test('should return ServerFailure when remote data source throws exception', () async {
        // Arrange
        when(() => mockRemoteDataSource.getUserOrders())
            .thenThrow(Exception('Database error'));

        // Act
        final result = await repository.getOrderHistory();

        // Assert
        expect(result, isA<Left>());
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, contains('Failed to load order history'));
          },
          (orders) => fail('Expected Left but got Right'),
        );
      });

      test('should handle mixed order statuses correctly', () async {
        // Arrange
        final mixedOrders = [
          testOrder1.copyWith(status: OrderStatus.pending), // active
          testOrder1.copyWith(status: OrderStatus.processing), // active
          testOrder1.copyWith(status: OrderStatus.shipped), // active
          testOrder1.copyWith(status: OrderStatus.delivered), // inactive
          testOrder1.copyWith(status: OrderStatus.completed), // inactive
          testOrder1.copyWith(status: OrderStatus.cancelled), // inactive
        ];
        
        when(() => mockRemoteDataSource.getUserOrders())
            .thenAnswer((_) async => mixedOrders);

        // Act
        final result = await repository.getOrderHistory();

        // Assert
        expect(result, isA<Right>());
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (orders) {
            expect(orders.length, equals(3));
            expect(orders.every((order) => !order.isActive), isTrue);
            // Verify specific statuses
            final statuses = orders.map((o) => o.status).toSet();
            expect(statuses.contains(OrderStatus.delivered), isTrue);
            expect(statuses.contains(OrderStatus.completed), isTrue);
            expect(statuses.contains(OrderStatus.cancelled), isTrue);
          },
        );
      });
    });

    group('cancelOrder', () {
      test('should return cancelled order when remote data source succeeds', () async {
        // Arrange
        const orderId = '1';
        final cancelledOrder = testOrder1.copyWith(status: OrderStatus.cancelled);
        
        when(() => mockRemoteDataSource.cancelOrder(orderId))
            .thenAnswer((_) async => cancelledOrder);

        // Act
        final result = await repository.cancelOrder(orderId);

        // Assert
        expect(result, isA<Right>());
        expect(result.fold((l) => false, (r) => true), isTrue);
        verify(() => mockRemoteDataSource.cancelOrder(orderId)).called(1);
      });

      test('should return ServerFailure when remote data source throws exception', () async {
        // Arrange
        const orderId = 'non-existent';
        when(() => mockRemoteDataSource.cancelOrder(orderId))
            .thenThrow(Exception('Order cannot be cancelled'));

        // Act
        final result = await repository.cancelOrder(orderId);

        // Assert
        expect(result, isA<Left>());
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, contains('Failed to cancel order'));
          },
          (order) => fail('Expected Left but got Right'),
        );
      });

      test('should handle different cancellation scenarios', () async {
        // Test cancelling pending order
        when(() => mockRemoteDataSource.cancelOrder('pending_order'))
            .thenAnswer((_) async => testOrder1.copyWith(status: OrderStatus.cancelled));

        final pendingResult = await repository.cancelOrder('pending_order');
        expect(pendingResult, isA<Right>());

        // Test cancelling processing order
        when(() => mockRemoteDataSource.cancelOrder('processing_order'))
            .thenAnswer((_) async => testOrder2.copyWith(status: OrderStatus.cancelled));

        final processingResult = await repository.cancelOrder('processing_order');
        expect(processingResult, isA<Right>());

        // Test cancelling already shipped order (should fail)
        when(() => mockRemoteDataSource.cancelOrder('shipped_order'))
            .thenThrow(Exception('Cannot cancel shipped order'));

        final shippedResult = await repository.cancelOrder('shipped_order');
        expect(shippedResult, isA<Left>());
      });
    });

    group('Edge Cases and Integration', () {
      test('should handle large number of orders efficiently', () async {
        // Arrange
        final largeOrderList = List.generate(1000, (index) => OrderModel(
          id: 'order_$index',
          bookId: 'book_$index',
          bookTitle: 'Book Title $index',
          bookImageUrl: 'image_$index.jpg',
          bookAuthor: 'Author $index',
          type: index.isEven ? OrderType.rental : OrderType.purchase,
          status: index % 3 == 0 ? OrderStatus.pending : OrderStatus.completed,
          price: index * 1.99,
          orderDate: DateTime.now().subtract(Duration(days: index)),
        ));

        when(() => mockRemoteDataSource.getUserOrders())
            .thenAnswer((_) async => largeOrderList);

        // Act
        final stopwatch = Stopwatch()..start();
        final result = await repository.getUserOrders();
        stopwatch.stop();

        // Assert
        expect(result, isA<Right>());
        expect(stopwatch.elapsedMilliseconds, lessThan(1000)); // Should be fast
        
        result.fold(
          (failure) => fail('Expected Right but got Left'),
          (orders) {
            expect(orders.length, equals(1000));
            // Verify sorting is maintained even with large dataset
            bool activeOrdersFirst = true;
            bool previousWasActive = true;
            
            for (int i = 0; i < orders.length; i++) {
              if (!orders[i].isActive && previousWasActive) {
                activeOrdersFirst = false;
                break;
              }
              if (orders[i].isActive) {
                previousWasActive = true;
              } else {
                previousWasActive = false;
              }
            }
            
            expect(activeOrdersFirst, isFalse); // We expect some inactive orders in the mix
          },
        );
      });

      test('should handle concurrent operations gracefully', () async {
        // Arrange
        when(() => mockRemoteDataSource.getUserOrders())
            .thenAnswer((_) async => testOrders);
        when(() => mockRemoteDataSource.getOrderById(any()))
            .thenAnswer((_) async => testOrder1);

        // Act - Simulate concurrent calls
        final futures = [
          repository.getUserOrders(),
          repository.getOrderById('1'),
          repository.getUserOrders(),
          repository.getOrderById('2'),
        ];

        final results = await Future.wait(futures);

        // Assert
        for (final result in results) {
          expect(result, isA<Right>());
        }
      });
    });
  });
}
