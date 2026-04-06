import 'package:flutter_library/features/cart/domain/entities/cart_item.dart';
import 'package:flutter_library/features/cart/presentation/bloc/cart_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CartEvent', () {
    group('LoadCartItems', () {
      test('should have empty props', () {
        final event = LoadCartItems();
        expect(event.props, []);
      });

      test('should support value equality', () {
        final event1 = LoadCartItems();
        final event2 = LoadCartItems();
        expect(event1, event2);
      });
    });

    group('AddItemToCart', () {
      test('should create instance with required parameters', () {
        final event = const AddItemToCart(
          bookId: 'book1',
          type: CartItemType.rent,
          rentalPeriodInDays: 21,
        );

        expect(event.bookId, 'book1');
        expect(event.type, CartItemType.rent);
        expect(event.rentalPeriodInDays, 21);
      });

      test('should default rental period to 14', () {
        final event = const AddItemToCart(
          bookId: 'book1',
          type: CartItemType.rent,
        );

        expect(event.rentalPeriodInDays, 14);
      });

      test('should support value equality', () {
        final event1 = const AddItemToCart(
          bookId: 'book1',
          type: CartItemType.rent,
          rentalPeriodInDays: 14,
        );
        final event2 = const AddItemToCart(
          bookId: 'book1',
          type: CartItemType.rent,
          rentalPeriodInDays: 14,
        );

        expect(event1, event2);
      });

      test('should not be equal if properties differ', () {
        final event1 = const AddItemToCart(
          bookId: 'book1',
          type: CartItemType.rent,
        );
        final event2 = const AddItemToCart(
          bookId: 'book2',
          type: CartItemType.rent,
        );

        expect(event1, isNot(event2));
      });

      test('should include all properties in props', () {
        final event = const AddItemToCart(
          bookId: 'book1',
          type: CartItemType.purchase,
          rentalPeriodInDays: 30,
        );

        expect(event.props, ['book1', CartItemType.purchase, 30]);
      });

      test('should handle purchase type', () {
        final event = const AddItemToCart(
          bookId: 'book1',
          type: CartItemType.purchase,
        );

        expect(event.type, CartItemType.purchase);
      });
    });

    group('RemoveItemFromCart', () {
      test('should create instance with cart item ID', () {
        final event = const RemoveItemFromCart('cart1');
        expect(event.cartItemId, 'cart1');
      });

      test('should support value equality', () {
        final event1 = const RemoveItemFromCart('cart1');
        final event2 = const RemoveItemFromCart('cart1');
        expect(event1, event2);
      });

      test('should include ID in props', () {
        final event = const RemoveItemFromCart('cart1');
        expect(event.props, ['cart1']);
      });
    });

    group('SendRentalRequest', () {
      test('should create instance with required parameters', () {
        final event = const SendRentalRequest(
          bookId: 'book1',
          rentalPeriodInDays: 21,
        );

        expect(event.bookId, 'book1');
        expect(event.rentalPeriodInDays, 21);
      });

      test('should default rental period to 14', () {
        final event = const SendRentalRequest(bookId: 'book1');
        expect(event.rentalPeriodInDays, 14);
      });

      test('should support value equality', () {
        final event1 = const SendRentalRequest(bookId: 'book1', rentalPeriodInDays: 14);
        final event2 = const SendRentalRequest(bookId: 'book1', rentalPeriodInDays: 14);
        expect(event1, event2);
      });

      test('should include all properties in props', () {
        final event = const SendRentalRequest(bookId: 'book1', rentalPeriodInDays: 30);
        expect(event.props, ['book1', 30]);
      });
    });

    group('SendPurchaseRequest', () {
      test('should create instance with book ID', () {
        final event = const SendPurchaseRequest('book1');
        expect(event.bookId, 'book1');
      });

      test('should support value equality', () {
        final event1 = const SendPurchaseRequest('book1');
        final event2 = const SendPurchaseRequest('book1');
        expect(event1, event2);
      });

      test('should include book ID in props', () {
        final event = const SendPurchaseRequest('book1');
        expect(event.props, ['book1']);
      });
    });

    group('AcceptBookRequest', () {
      test('should create instance with request ID', () {
        final event = const AcceptBookRequest('req1');
        expect(event.requestId, 'req1');
      });

      test('should support value equality', () {
        final event1 = const AcceptBookRequest('req1');
        final event2 = const AcceptBookRequest('req1');
        expect(event1, event2);
      });

      test('should include request ID in props', () {
        final event = const AcceptBookRequest('req1');
        expect(event.props, ['req1']);
      });
    });

    group('RejectBookRequest', () {
      test('should create instance with request ID', () {
        final event = const RejectBookRequest('req1');
        expect(event.requestId, 'req1');
      });

      test('should support value equality', () {
        final event1 = const RejectBookRequest('req1');
        final event2 = const RejectBookRequest('req1');
        expect(event1, event2);
      });

      test('should include request ID in props', () {
        final event = const RejectBookRequest('req1');
        expect(event.props, ['req1']);
      });
    });

    group('LoadReceivedRequests', () {
      test('should have empty props', () {
        final event = LoadReceivedRequests();
        expect(event.props, []);
      });

      test('should support value equality', () {
        final event1 = LoadReceivedRequests();
        final event2 = LoadReceivedRequests();
        expect(event1, event2);
      });
    });

    group('RefreshCart', () {
      test('should have empty props', () {
        final event = RefreshCart();
        expect(event.props, []);
      });

      test('should support value equality', () {
        final event1 = RefreshCart();
        final event2 = RefreshCart();
        expect(event1, event2);
      });
    });

    group('ClearCart', () {
      test('should have empty props', () {
        final event = ClearCart();
        expect(event.props, []);
      });

      test('should support value equality', () {
        final event1 = ClearCart();
        final event2 = ClearCart();
        expect(event1, event2);
      });
    });
  });
}
