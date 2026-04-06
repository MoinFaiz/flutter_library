import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/orders/data/models/order_model.dart';
import 'package:flutter_library/features/orders/domain/entities/order.dart';

void main() {
  group('OrderModel', () {
    final testDateTime = DateTime(2024, 1, 15, 10, 30, 0);
    final testDeliveryDate = DateTime(2024, 1, 20, 14, 0, 0);
    
    final testOrderModel = OrderModel(
      id: '1',
      bookId: 'book1',
      bookTitle: 'Test Book Title',
      bookImageUrl: 'https://example.com/book.jpg',
      bookAuthor: 'Test Author',
      type: OrderType.purchase,
      status: OrderStatus.pending,
      price: 24.99,
      orderDate: testDateTime,
      deliveryDate: testDeliveryDate,
      notes: 'Test notes',
    );

    final testJson = {
      'id': '1',
      'bookId': 'book1',
      'bookTitle': 'Test Book Title',
      'bookImageUrl': 'https://example.com/book.jpg',
      'bookAuthor': 'Test Author',
      'type': 'purchase',
      'status': 'pending',
      'price': 24.99,
      'orderDate': '2024-01-15T10:30:00.000',
      'deliveryDate': '2024-01-20T14:00:00.000',
      'returnDate': null,
      'notes': 'Test notes',
    };

    group('Entity Extension', () {
      test('should be a subclass of Order entity', () {
        expect(testOrderModel, isA<Order>());
      });

      test('should have correct properties from parent entity', () {
        expect(testOrderModel.id, equals('1'));
        expect(testOrderModel.bookId, equals('book1'));
        expect(testOrderModel.bookTitle, equals('Test Book Title'));
        expect(testOrderModel.bookImageUrl, equals('https://example.com/book.jpg'));
        expect(testOrderModel.bookAuthor, equals('Test Author'));
        expect(testOrderModel.type, equals(OrderType.purchase));
        expect(testOrderModel.status, equals(OrderStatus.pending));
        expect(testOrderModel.price, equals(24.99));
        expect(testOrderModel.orderDate, equals(testDateTime));
        expect(testOrderModel.deliveryDate, equals(testDeliveryDate));
        expect(testOrderModel.notes, equals('Test notes'));
      });

      test('should correctly identify active orders', () {
        // Active statuses
        final pendingOrder = testOrderModel.copyWith(status: OrderStatus.pending);
        final processingOrder = testOrderModel.copyWith(status: OrderStatus.processing);
        final shippedOrder = testOrderModel.copyWith(status: OrderStatus.shipped);

        expect(pendingOrder.isActive, isTrue);
        expect(processingOrder.isActive, isTrue);
        expect(shippedOrder.isActive, isTrue);

        // Inactive statuses
        final completedOrder = testOrderModel.copyWith(status: OrderStatus.completed);
        final cancelledOrder = testOrderModel.copyWith(status: OrderStatus.cancelled);
        final deliveredOrder = testOrderModel.copyWith(status: OrderStatus.delivered);

        expect(completedOrder.isActive, isFalse);
        expect(cancelledOrder.isActive, isFalse);
        expect(deliveredOrder.isActive, isFalse);
      });
    });

    group('fromJson', () {
      test('should return a valid OrderModel from JSON', () {
        // Act
        final result = OrderModel.fromJson(testJson);

        // Assert
        expect(result, isA<OrderModel>());
        expect(result.id, equals('1'));
        expect(result.bookId, equals('book1'));
        expect(result.bookTitle, equals('Test Book Title'));
        expect(result.bookImageUrl, equals('https://example.com/book.jpg'));
        expect(result.bookAuthor, equals('Test Author'));
        expect(result.type, equals(OrderType.purchase));
        expect(result.status, equals(OrderStatus.pending));
        expect(result.price, equals(24.99));
        expect(result.orderDate, equals(testDateTime));
        expect(result.deliveryDate, equals(testDeliveryDate));
        expect(result.notes, equals('Test notes'));
      });

      test('should handle all OrderType values correctly', () {
        for (final type in OrderType.values) {
          final json = {
            'id': '1',
            'bookId': 'book1',
            'bookTitle': 'Test Book',
            'bookImageUrl': 'image.jpg',
            'bookAuthor': 'Author',
            'type': type.name,
            'status': 'pending',
            'price': 10.0,
            'orderDate': '2024-01-15T10:30:00.000',
          };

          final result = OrderModel.fromJson(json);

          expect(result.type, equals(type));
        }
      });

      test('should handle all OrderStatus values correctly', () {
        for (final status in OrderStatus.values) {
          final json = {
            'id': '1',
            'bookId': 'book1',
            'bookTitle': 'Test Book',
            'bookImageUrl': 'image.jpg',
            'bookAuthor': 'Author',
            'type': 'purchase',
            'status': status.name,
            'price': 10.0,
            'orderDate': '2024-01-15T10:30:00.000',
          };

          final result = OrderModel.fromJson(json);

          expect(result.status, equals(status));
        }
      });

      test('should default to purchase type for unknown order type', () {
        // Arrange
        final jsonWithUnknownType = {
          'id': '1',
          'bookId': 'book1',
          'bookTitle': 'Test Book',
          'bookImageUrl': 'image.jpg',
          'bookAuthor': 'Author',
          'type': 'unknownType',
          'status': 'pending',
          'price': 10.0,
          'orderDate': '2024-01-15T10:30:00.000',
        };

        // Act
        final result = OrderModel.fromJson(jsonWithUnknownType);

        // Assert
        expect(result.type, equals(OrderType.purchase));
      });

      test('should default to pending status for unknown status', () {
        // Arrange
        final jsonWithUnknownStatus = {
          'id': '1',
          'bookId': 'book1',
          'bookTitle': 'Test Book',
          'bookImageUrl': 'image.jpg',
          'bookAuthor': 'Author',
          'type': 'purchase',
          'status': 'unknownStatus',
          'price': 10.0,
          'orderDate': '2024-01-15T10:30:00.000',
        };

        // Act
        final result = OrderModel.fromJson(jsonWithUnknownStatus);

        // Assert
        expect(result.status, equals(OrderStatus.pending));
      });

      test('should handle null optional fields correctly', () {
        // Arrange
        final jsonWithNulls = {
          'id': '1',
          'bookId': 'book1',
          'bookTitle': 'Test Book',
          'bookImageUrl': 'image.jpg',
          'bookAuthor': 'Author',
          'type': 'purchase',
          'status': 'pending',
          'price': 10.0,
          'orderDate': '2024-01-15T10:30:00.000',
          'deliveryDate': null,
          'returnDate': null,
          'notes': null,
        };

        // Act
        final result = OrderModel.fromJson(jsonWithNulls);

        // Assert
        expect(result.deliveryDate, isNull);
        expect(result.returnDate, isNull);
        expect(result.notes, isNull);
      });

      test('should handle different price formats', () {
        // Test int price
        final jsonWithIntPrice = {
          'id': '1',
          'bookId': 'book1',
          'bookTitle': 'Test Book',
          'bookImageUrl': 'image.jpg',
          'bookAuthor': 'Author',
          'type': 'purchase',
          'status': 'pending',
          'price': 25,
          'orderDate': '2024-01-15T10:30:00.000',
        };

        final resultInt = OrderModel.fromJson(jsonWithIntPrice);
        expect(resultInt.price, equals(25.0));

        // Test very high precision price
        final jsonWithPrecisePrice = {
          'id': '1',
          'bookId': 'book1',
          'bookTitle': 'Test Book',
          'bookImageUrl': 'image.jpg',
          'bookAuthor': 'Author',
          'type': 'purchase',
          'status': 'pending',
          'price': 24.999999,
          'orderDate': '2024-01-15T10:30:00.000',
        };

        final resultPrecise = OrderModel.fromJson(jsonWithPrecisePrice);
        expect(resultPrecise.price, equals(24.999999));
      });

      test('should handle special characters in text fields', () {
        // Arrange
        final jsonWithSpecialChars = {
          'id': '1',
          'bookId': 'book1',
          'bookTitle': 'Test Book: A Story of "Success" & Failure!',
          'bookImageUrl': 'https://example.com/books/test%20book.jpg',
          'bookAuthor': 'O\'Reilly, John & Jane',
          'type': 'purchase',
          'status': 'pending',
          'price': 10.0,
          'orderDate': '2024-01-15T10:30:00.000',
          'notes': 'Notes with special chars: !@#\$%^&*(){}[]|\\:";\'<>?,./',
        };

        // Act
        final result = OrderModel.fromJson(jsonWithSpecialChars);

        // Assert
        expect(result.bookTitle, equals('Test Book: A Story of "Success" & Failure!'));
        expect(result.bookImageUrl, equals('https://example.com/books/test%20book.jpg'));
        expect(result.bookAuthor, equals('O\'Reilly, John & Jane'));
        expect(result.notes, equals('Notes with special chars: !@#\$%^&*(){}[]|\\:";\'<>?,./')); 
      });
    });

    group('toJson', () {
      test('should return a valid JSON map', () {
        // Act
        final result = testOrderModel.toJson();

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['id'], equals('1'));
        expect(result['bookId'], equals('book1'));
        expect(result['bookTitle'], equals('Test Book Title'));
        expect(result['bookImageUrl'], equals('https://example.com/book.jpg'));
        expect(result['bookAuthor'], equals('Test Author'));
        expect(result['type'], equals('purchase'));
        expect(result['status'], equals('pending'));
        expect(result['price'], equals(24.99));
        expect(result['orderDate'], equals('2024-01-15T10:30:00.000'));
        expect(result['deliveryDate'], equals('2024-01-20T14:00:00.000'));
        expect(result['notes'], equals('Test notes'));
      });

      test('should convert all OrderType values correctly', () {
        for (final type in OrderType.values) {
          final model = testOrderModel.copyWith(type: type);
          final json = model.toJson();

          expect(json['type'], equals(type.name));
        }
      });

      test('should convert all OrderStatus values correctly', () {
        for (final status in OrderStatus.values) {
          final model = testOrderModel.copyWith(status: status);
          final json = model.toJson();

          expect(json['status'], equals(status.name));
        }
      });

      test('should handle null optional fields correctly', () {
        // Arrange
        final modelWithNulls = OrderModel(
          id: '1',
          bookId: 'book1',
          bookTitle: 'Test Book',
          bookImageUrl: 'image.jpg',
          bookAuthor: 'Author',
          type: OrderType.purchase,
          status: OrderStatus.pending,
          price: 10.0,
          orderDate: testDateTime,
          deliveryDate: null,
          returnDate: null,
          notes: null,
        );

        // Act
        final result = modelWithNulls.toJson();

        // Assert
        expect(result['deliveryDate'], isNull);
        expect(result['returnDate'], isNull);
        expect(result['notes'], isNull);
      });

      test('should handle edge case prices correctly', () {
        // Zero price
        final zeroModel = testOrderModel.copyWith(price: 0.0);
        expect(zeroModel.toJson()['price'], equals(0.0));

        // Very high price
        final highModel = testOrderModel.copyWith(price: 999999.99);
        expect(highModel.toJson()['price'], equals(999999.99));

        // Negative price (edge case)
        final negativeModel = testOrderModel.copyWith(price: -10.0);
        expect(negativeModel.toJson()['price'], equals(-10.0));
      });
    });

    group('copyWith', () {
      test('should return OrderModel with updated values', () {
        // Act
        final result = testOrderModel.copyWith(
          id: '2',
          bookTitle: 'Updated Title',
          status: OrderStatus.completed,
          price: 35.99,
        );

        // Assert
        expect(result, isA<OrderModel>());
        expect(result.id, equals('2'));
        expect(result.bookTitle, equals('Updated Title'));
        expect(result.status, equals(OrderStatus.completed));
        expect(result.price, equals(35.99));
        // Unchanged values
        expect(result.bookId, equals(testOrderModel.bookId));
        expect(result.bookAuthor, equals(testOrderModel.bookAuthor));
        expect(result.type, equals(testOrderModel.type));
        expect(result.orderDate, equals(testOrderModel.orderDate));
      });

      test('should return OrderModel with original values when no parameters provided', () {
        // Act
        final result = testOrderModel.copyWith();

        // Assert
        expect(result, isA<OrderModel>());
        expect(result.id, equals(testOrderModel.id));
        expect(result.bookId, equals(testOrderModel.bookId));
        expect(result.bookTitle, equals(testOrderModel.bookTitle));
        expect(result.type, equals(testOrderModel.type));
        expect(result.status, equals(testOrderModel.status));
        expect(result.price, equals(testOrderModel.price));
      });
    });

    group('JSON Serialization Round Trip', () {
      test('should maintain data integrity through fromJson -> toJson cycle', () {
        // Act
        final json = testOrderModel.toJson();
        final fromJson = OrderModel.fromJson(json);
        final backToJson = fromJson.toJson();

        // Assert
        expect(fromJson.id, equals(testOrderModel.id));
        expect(fromJson.bookId, equals(testOrderModel.bookId));
        expect(fromJson.bookTitle, equals(testOrderModel.bookTitle));
        expect(fromJson.bookAuthor, equals(testOrderModel.bookAuthor));
        expect(fromJson.type, equals(testOrderModel.type));
        expect(fromJson.status, equals(testOrderModel.status));
        expect(fromJson.price, equals(testOrderModel.price));
        expect(fromJson.orderDate, equals(testOrderModel.orderDate));
        expect(backToJson, equals(json));
      });

      test('should handle all enum combinations in round trip', () {
        for (final type in OrderType.values) {
          for (final status in OrderStatus.values) {
            final model = OrderModel(
              id: 'test',
              bookId: 'book1',
              bookTitle: 'Test Book',
              bookImageUrl: 'image.jpg',
              bookAuthor: 'Author',
              type: type,
              status: status,
              price: 10.0,
              orderDate: testDateTime,
            );

            final json = model.toJson();
            final fromJson = OrderModel.fromJson(json);

            expect(fromJson.type, equals(type));
            expect(fromJson.status, equals(status));
          }
        }
      });
    });

    group('Display Methods', () {
      test('should return correct type display text', () {
        final purchaseOrder = testOrderModel.copyWith(type: OrderType.purchase);
        final rentalOrder = testOrderModel.copyWith(type: OrderType.rental);

        expect(purchaseOrder.typeDisplayText, equals('Purchase'));
        expect(rentalOrder.typeDisplayText, equals('Rental'));
      });

      test('should return correct status display text', () {
        final statuses = {
          OrderStatus.pending: 'Pending',
          OrderStatus.processing: 'Processing',
          OrderStatus.shipped: 'Shipped',
          OrderStatus.delivered: 'Delivered',
          OrderStatus.returned: 'Returned',
          OrderStatus.completed: 'Completed',
          OrderStatus.cancelled: 'Cancelled',
        };

        for (final entry in statuses.entries) {
          final order = testOrderModel.copyWith(status: entry.key);
          expect(order.statusDisplayText, equals(entry.value));
        }
      });
    });

    group('fromEntity', () {
      test('should create OrderModel from Order entity', () {
        // Arrange
        final order = Order(
          id: 'entity_1',
          bookId: 'book_entity',
          bookTitle: 'Entity Book Title',
          bookImageUrl: 'https://example.com/entity.jpg',
          bookAuthor: 'Entity Author',
          type: OrderType.rental,
          status: OrderStatus.processing,
          price: 15.99,
          orderDate: testDateTime,
          deliveryDate: testDeliveryDate,
          notes: 'Entity notes',
        );

        // Act
        final result = OrderModel.fromEntity(order);

        // Assert
        expect(result, isA<OrderModel>());
        expect(result.id, equals('entity_1'));
        expect(result.bookId, equals('book_entity'));
        expect(result.bookTitle, equals('Entity Book Title'));
        expect(result.bookImageUrl, equals('https://example.com/entity.jpg'));
        expect(result.bookAuthor, equals('Entity Author'));
        expect(result.type, equals(OrderType.rental));
        expect(result.status, equals(OrderStatus.processing));
        expect(result.price, equals(15.99));
        expect(result.orderDate, equals(testDateTime));
        expect(result.deliveryDate, equals(testDeliveryDate));
        expect(result.notes, equals('Entity notes'));
      });

      test('should handle entity with null optional fields', () {
        // Arrange
        final order = Order(
          id: 'entity_2',
          bookId: 'book_2',
          bookTitle: 'Book',
          bookImageUrl: 'image.jpg',
          bookAuthor: 'Author',
          type: OrderType.purchase,
          status: OrderStatus.pending,
          price: 10.0,
          orderDate: testDateTime,
        );

        // Act
        final result = OrderModel.fromEntity(order);

        // Assert
        expect(result.deliveryDate, isNull);
        expect(result.returnDate, isNull);
        expect(result.notes, isNull);
      });

      test('should preserve all order types when converting from entity', () {
        for (final type in OrderType.values) {
          final order = Order(
            id: 'test',
            bookId: 'book',
            bookTitle: 'Title',
            bookImageUrl: 'image.jpg',
            bookAuthor: 'Author',
            type: type,
            status: OrderStatus.pending,
            price: 10.0,
            orderDate: testDateTime,
          );

          final result = OrderModel.fromEntity(order);

          expect(result.type, equals(type));
        }
      });

      test('should preserve all order statuses when converting from entity', () {
        for (final status in OrderStatus.values) {
          final order = Order(
            id: 'test',
            bookId: 'book',
            bookTitle: 'Title',
            bookImageUrl: 'image.jpg',
            bookAuthor: 'Author',
            type: OrderType.purchase,
            status: status,
            price: 10.0,
            orderDate: testDateTime,
          );

          final result = OrderModel.fromEntity(order);

          expect(result.status, equals(status));
        }
      });
    });

    group('Equality and Props', () {
      test('should be equal when all properties are the same', () {
        // Arrange
        final anotherModel = OrderModel(
          id: '1',
          bookId: 'book1',
          bookTitle: 'Test Book Title',
          bookImageUrl: 'https://example.com/book.jpg',
          bookAuthor: 'Test Author',
          type: OrderType.purchase,
          status: OrderStatus.pending,
          price: 24.99,
          orderDate: testDateTime,
          deliveryDate: testDeliveryDate,
          notes: 'Test notes',
        );

        // Assert
        expect(testOrderModel, equals(anotherModel));
        expect(testOrderModel.hashCode, equals(anotherModel.hashCode));
      });

      test('should not be equal when properties differ', () {
        // Arrange
        final differentModel = testOrderModel.copyWith(id: '2');

        // Assert
        expect(testOrderModel, isNot(equals(differentModel)));
        expect(testOrderModel.hashCode, isNot(equals(differentModel.hashCode)));
      });
    });
  });
}
