import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/orders/domain/entities/order.dart';

void main() {
  group('Order Entity Tests', () {
    final mockOrder = Order(
      id: 'order_1',
      bookId: 'book_123',
      bookTitle: 'The Great Adventure',
      bookImageUrl: 'https://example.com/book.jpg',
      bookAuthor: 'John Author',
      type: OrderType.rental,
      status: OrderStatus.processing,
      price: 15.99,
      orderDate: DateTime(2023, 6, 1),
      deliveryDate: DateTime(2023, 6, 3),
      returnDate: DateTime(2023, 6, 30),
      notes: 'Handle with care',
    );

    group('Constructor and Properties', () {
      test('should create Order with all required properties', () {
        expect(mockOrder.id, 'order_1');
        expect(mockOrder.bookId, 'book_123');
        expect(mockOrder.bookTitle, 'The Great Adventure');
        expect(mockOrder.bookImageUrl, 'https://example.com/book.jpg');
        expect(mockOrder.bookAuthor, 'John Author');
        expect(mockOrder.type, OrderType.rental);
        expect(mockOrder.status, OrderStatus.processing);
        expect(mockOrder.price, 15.99);
        expect(mockOrder.orderDate, DateTime(2023, 6, 1));
        expect(mockOrder.deliveryDate, DateTime(2023, 6, 3));
        expect(mockOrder.returnDate, DateTime(2023, 6, 30));
        expect(mockOrder.notes, 'Handle with care');
      });

      test('should create Order with minimal required properties', () {
        final minimalOrder = Order(
          id: 'order_2',
          bookId: 'book_456',
          bookTitle: 'Simple Book',
          bookImageUrl: 'https://example.com/simple.jpg',
          bookAuthor: 'Simple Author',
          type: OrderType.purchase,
          status: OrderStatus.pending,
          price: 25.99,
          orderDate: DateTime(2023, 6, 1),
        );

        expect(minimalOrder.id, 'order_2');
        expect(minimalOrder.type, OrderType.purchase);
        expect(minimalOrder.status, OrderStatus.pending);
        expect(minimalOrder.deliveryDate, isNull);
        expect(minimalOrder.returnDate, isNull);
        expect(minimalOrder.notes, isNull);
      });
    });

    group('Order Status Logic', () {
      test('isActive should return true for pending orders', () {
        final pendingOrder = mockOrder.copyWith(status: OrderStatus.pending);
        expect(pendingOrder.isActive, true);
      });

      test('isActive should return true for processing orders', () {
        final processingOrder = mockOrder.copyWith(status: OrderStatus.processing);
        expect(processingOrder.isActive, true);
      });

      test('isActive should return true for shipped orders', () {
        final shippedOrder = mockOrder.copyWith(status: OrderStatus.shipped);
        expect(shippedOrder.isActive, true);
      });

      test('isActive should return false for delivered orders', () {
        final deliveredOrder = mockOrder.copyWith(status: OrderStatus.delivered);
        expect(deliveredOrder.isActive, false);
      });

      test('isActive should return false for completed orders', () {
        final completedOrder = mockOrder.copyWith(status: OrderStatus.completed);
        expect(completedOrder.isActive, false);
      });

      test('isActive should return false for cancelled orders', () {
        final cancelledOrder = mockOrder.copyWith(status: OrderStatus.cancelled);
        expect(cancelledOrder.isActive, false);
      });

      test('isActive should return false for returned orders', () {
        final returnedOrder = mockOrder.copyWith(status: OrderStatus.returned);
        expect(returnedOrder.isActive, false);
      });
    });

    group('Display Text Logic', () {
      test('typeDisplayText should return correct text for purchase', () {
        final purchaseOrder = mockOrder.copyWith(type: OrderType.purchase);
        expect(purchaseOrder.typeDisplayText, 'Purchase');
      });

      test('typeDisplayText should return correct text for rental', () {
        final rentalOrder = mockOrder.copyWith(type: OrderType.rental);
        expect(rentalOrder.typeDisplayText, 'Rental');
      });

      test('statusDisplayText should return correct text for all statuses', () {
        expect(mockOrder.copyWith(status: OrderStatus.pending).statusDisplayText, 'Pending');
        expect(mockOrder.copyWith(status: OrderStatus.processing).statusDisplayText, 'Processing');
        expect(mockOrder.copyWith(status: OrderStatus.shipped).statusDisplayText, 'Shipped');
        expect(mockOrder.copyWith(status: OrderStatus.delivered).statusDisplayText, 'Delivered');
        expect(mockOrder.copyWith(status: OrderStatus.returned).statusDisplayText, 'Returned');
        expect(mockOrder.copyWith(status: OrderStatus.completed).statusDisplayText, 'Completed');
        expect(mockOrder.copyWith(status: OrderStatus.cancelled).statusDisplayText, 'Cancelled');
      });
    });

    group('copyWith Method', () {
      test('should create new instance with updated properties', () {
        final updatedOrder = mockOrder.copyWith(
          status: OrderStatus.delivered,
          price: 20.99,
          notes: 'Updated notes',
        );

        expect(updatedOrder.status, OrderStatus.delivered);
        expect(updatedOrder.price, 20.99);
        expect(updatedOrder.notes, 'Updated notes');
        // Other properties should remain unchanged
        expect(updatedOrder.id, mockOrder.id);
        expect(updatedOrder.bookTitle, mockOrder.bookTitle);
        expect(updatedOrder.type, mockOrder.type);
      });

      test('should return identical instance when no parameters provided', () {
        final copiedOrder = mockOrder.copyWith();
        
        expect(copiedOrder.id, mockOrder.id);
        expect(copiedOrder.bookId, mockOrder.bookId);
        expect(copiedOrder.status, mockOrder.status);
        expect(copiedOrder.price, mockOrder.price);
      });

      test('should allow setting nullable fields to different values', () {
        final updatedOrder = mockOrder.copyWith(
          deliveryDate: DateTime(2023, 6, 5),
          returnDate: DateTime(2023, 7, 5),
          notes: 'New notes',
        );

        expect(updatedOrder.deliveryDate, DateTime(2023, 6, 5));
        expect(updatedOrder.returnDate, DateTime(2023, 7, 5));
        expect(updatedOrder.notes, 'New notes');
      });
    });

    group('Equatable Implementation', () {
      test('should be equal when all properties are identical', () {
        final order1 = Order(
          id: 'order_1',
          bookId: 'book_123',
          bookTitle: 'Test Book',
          bookImageUrl: 'image.jpg',
          bookAuthor: 'Test Author',
          type: OrderType.purchase,
          status: OrderStatus.pending,
          price: 19.99,
          orderDate: DateTime(2023, 1, 1),
          deliveryDate: DateTime(2023, 1, 5),
          notes: 'Test notes',
        );

        final order2 = Order(
          id: 'order_1',
          bookId: 'book_123',
          bookTitle: 'Test Book',
          bookImageUrl: 'image.jpg',
          bookAuthor: 'Test Author',
          type: OrderType.purchase,
          status: OrderStatus.pending,
          price: 19.99,
          orderDate: DateTime(2023, 1, 1),
          deliveryDate: DateTime(2023, 1, 5),
          notes: 'Test notes',
        );

        expect(order1, equals(order2));
        expect(order1.hashCode, equals(order2.hashCode));
      });

      test('should not be equal when properties differ', () {
        final order1 = mockOrder;
        final order2 = mockOrder.copyWith(status: OrderStatus.delivered);

        expect(order1, isNot(equals(order2)));
        expect(order1.hashCode, isNot(equals(order2.hashCode)));
      });
    });

    group('Order Type Enum Tests', () {
      test('OrderType enum should have correct values', () {
        expect(OrderType.values, containsAll([OrderType.purchase, OrderType.rental]));
        expect(OrderType.values.length, 2);
      });
    });

    group('Order Status Enum Tests', () {
      test('OrderStatus enum should have all expected values', () {
        expect(OrderStatus.values, containsAll([
          OrderStatus.pending,
          OrderStatus.processing,
          OrderStatus.shipped,
          OrderStatus.delivered,
          OrderStatus.returned,
          OrderStatus.completed,
          OrderStatus.cancelled,
        ]));
        expect(OrderStatus.values.length, 7);
      });
    });

    group('Business Logic Edge Cases', () {
      test('should handle purchase orders without return date', () {
        final purchaseOrder = Order(
          id: 'purchase_1',
          bookId: 'book_789',
          bookTitle: 'Purchase Book',
          bookImageUrl: 'purchase.jpg',
          bookAuthor: 'Purchase Author',
          type: OrderType.purchase,
          status: OrderStatus.delivered,
          price: 29.99,
          orderDate: DateTime(2023, 6, 1),
          deliveryDate: DateTime(2023, 6, 5),
          // No return date for purchases
        );

        expect(purchaseOrder.type, OrderType.purchase);
        expect(purchaseOrder.returnDate, isNull);
        expect(purchaseOrder.isActive, false); // Delivered
      });

      test('should handle rental orders with return date', () {
        final rentalOrder = Order(
          id: 'rental_1',
          bookId: 'book_456',
          bookTitle: 'Rental Book',
          bookImageUrl: 'rental.jpg',
          bookAuthor: 'Rental Author',
          type: OrderType.rental,
          status: OrderStatus.delivered,
          price: 9.99,
          orderDate: DateTime(2023, 6, 1),
          deliveryDate: DateTime(2023, 6, 3),
          returnDate: DateTime(2023, 6, 30),
        );

        expect(rentalOrder.type, OrderType.rental);
        expect(rentalOrder.returnDate, isNotNull);
        expect(rentalOrder.isActive, false); // Delivered
      });

      test('should handle orders with zero price', () {
        final freeOrder = mockOrder.copyWith(price: 0.0);
        expect(freeOrder.price, 0.0);
        expect(freeOrder.isActive, true); // Processing status
      });

      test('should handle orders with very high price', () {
        final expensiveOrder = mockOrder.copyWith(price: 999.99);
        expect(expensiveOrder.price, 999.99);
      });
    });
  });
}
