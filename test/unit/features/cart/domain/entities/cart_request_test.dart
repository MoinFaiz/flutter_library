import 'package:flutter_library/features/cart/domain/entities/cart_item.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RequestStatus', () {
    test('should have correct number of statuses', () {
      expect(RequestStatus.values.length, 4);
    });

    test('should contain all required statuses', () {
      expect(RequestStatus.values, contains(RequestStatus.pending));
      expect(RequestStatus.values, contains(RequestStatus.accepted));
      expect(RequestStatus.values, contains(RequestStatus.rejected));
      expect(RequestStatus.values, contains(RequestStatus.cancelled));
    });
  });

  group('CartRequest', () {
    final now = DateTime(2025, 10, 31, 12, 0);
    final respondedAt = DateTime(2025, 10, 31, 13, 0);
    
    final testRequest = CartRequest(
      id: '1',
      bookId: 'book1',
      bookTitle: 'Test Book',
      bookAuthor: 'Test Author',
      bookImageUrl: 'https://example.com/image.jpg',
      requesterId: 'user1',
      ownerId: 'owner1',
      requestType: CartItemType.rent,
      rentalPeriodInDays: 14,
      price: 29.99,
      status: RequestStatus.pending,
      createdAt: now,
      respondedAt: respondedAt,
    );

    test('should create instance with all parameters', () {
      expect(testRequest.id, '1');
      expect(testRequest.bookId, 'book1');
      expect(testRequest.bookTitle, 'Test Book');
      expect(testRequest.bookAuthor, 'Test Author');
      expect(testRequest.bookImageUrl, 'https://example.com/image.jpg');
      expect(testRequest.requesterId, 'user1');
      expect(testRequest.ownerId, 'owner1');
      expect(testRequest.requestType, CartItemType.rent);
      expect(testRequest.rentalPeriodInDays, 14);
      expect(testRequest.price, 29.99);
      expect(testRequest.status, RequestStatus.pending);
      expect(testRequest.createdAt, now);
      expect(testRequest.respondedAt, respondedAt);
    });

    test('should create instance without optional respondedAt', () {
      final request = CartRequest(
        id: '1',
        bookId: 'book1',
        bookTitle: 'Test Book',
        bookAuthor: 'Test Author',
        bookImageUrl: 'https://example.com/image.jpg',
        requesterId: 'user1',
        ownerId: 'owner1',
        requestType: CartItemType.purchase,
        rentalPeriodInDays: 0,
        price: 49.99,
        status: RequestStatus.pending,
        createdAt: now,
      );

      expect(request.respondedAt, null);
    });

    test('isPending should return true for pending status', () {
      expect(testRequest.isPending, true);
      expect(testRequest.isAccepted, false);
      expect(testRequest.isRejected, false);
      expect(testRequest.isCancelled, false);
    });

    test('isAccepted should return true for accepted status', () {
      final request = testRequest.copyWith(status: RequestStatus.accepted);
      expect(request.isAccepted, true);
      expect(request.isPending, false);
      expect(request.isRejected, false);
      expect(request.isCancelled, false);
    });

    test('isRejected should return true for rejected status', () {
      final request = testRequest.copyWith(status: RequestStatus.rejected);
      expect(request.isRejected, true);
      expect(request.isPending, false);
      expect(request.isAccepted, false);
      expect(request.isCancelled, false);
    });

    test('isCancelled should return true for cancelled status', () {
      final request = testRequest.copyWith(status: RequestStatus.cancelled);
      expect(request.isCancelled, true);
      expect(request.isPending, false);
      expect(request.isAccepted, false);
      expect(request.isRejected, false);
    });

    test('isRental should return true for rent type', () {
      expect(testRequest.isRental, true);
      expect(testRequest.isPurchase, false);
    });

    test('isPurchase should return true for purchase type', () {
      final request = testRequest.copyWith(requestType: CartItemType.purchase);
      expect(request.isPurchase, true);
      expect(request.isRental, false);
    });

    test('requestTypeLabel should return correct label for rental', () {
      expect(testRequest.requestTypeLabel, 'Rental');
    });

    test('requestTypeLabel should return correct label for purchase', () {
      final request = testRequest.copyWith(requestType: CartItemType.purchase);
      expect(request.requestTypeLabel, 'Purchase');
    });

    test('copyWith should create new instance with updated values', () {
      final updated = testRequest.copyWith(
        id: '2',
        bookTitle: 'Updated Book',
        price: 39.99,
        status: RequestStatus.accepted,
      );

      expect(updated.id, '2');
      expect(updated.bookTitle, 'Updated Book');
      expect(updated.price, 39.99);
      expect(updated.status, RequestStatus.accepted);
      // Other values should remain unchanged
      expect(updated.bookId, 'book1');
      expect(updated.requesterId, 'user1');
    });

    test('copyWith should preserve original values when parameters are null', () {
      final updated = testRequest.copyWith();
      expect(updated, testRequest);
    });

    test('copyWith should update respondedAt', () {
      final newRespondedAt = DateTime(2025, 11, 1);
      final updated = testRequest.copyWith(respondedAt: newRespondedAt);
      expect(updated.respondedAt, newRespondedAt);
    });

    test('should support value equality', () {
      final request1 = CartRequest(
        id: '1',
        bookId: 'book1',
        bookTitle: 'Test Book',
        bookAuthor: 'Test Author',
        bookImageUrl: 'https://example.com/image.jpg',
        requesterId: 'user1',
        ownerId: 'owner1',
        requestType: CartItemType.rent,
        rentalPeriodInDays: 14,
        price: 29.99,
        status: RequestStatus.pending,
        createdAt: now,
      );

      final request2 = CartRequest(
        id: '1',
        bookId: 'book1',
        bookTitle: 'Test Book',
        bookAuthor: 'Test Author',
        bookImageUrl: 'https://example.com/image.jpg',
        requesterId: 'user1',
        ownerId: 'owner1',
        requestType: CartItemType.rent,
        rentalPeriodInDays: 14,
        price: 29.99,
        status: RequestStatus.pending,
        createdAt: now,
      );

      expect(request1, request2);
    });

    test('should not be equal if any property differs', () {
      final request1 = testRequest;
      final request2 = testRequest.copyWith(price: 39.99);

      expect(request1, isNot(request2));
    });

    test('should include all properties in props', () {
      expect(testRequest.props.length, 13);
      expect(testRequest.props, contains('1'));
      expect(testRequest.props, contains('book1'));
      expect(testRequest.props, contains('Test Book'));
      expect(testRequest.props, contains('user1'));
      expect(testRequest.props, contains('owner1'));
      expect(testRequest.props, contains(CartItemType.rent));
      expect(testRequest.props, contains(14));
      expect(testRequest.props, contains(29.99));
      expect(testRequest.props, contains(RequestStatus.pending));
    });

    test('should handle zero price', () {
      final request = testRequest.copyWith(price: 0.0);
      expect(request.price, 0.0);
    });

    test('should handle zero rental period', () {
      final request = testRequest.copyWith(rentalPeriodInDays: 0);
      expect(request.rentalPeriodInDays, 0);
    });

    test('should handle large rental period', () {
      final request = testRequest.copyWith(rentalPeriodInDays: 365);
      expect(request.rentalPeriodInDays, 365);
    });

    test('should handle large price', () {
      final request = testRequest.copyWith(price: 9999.99);
      expect(request.price, 9999.99);
    });

    test('should handle empty strings', () {
      final request = CartRequest(
        id: '',
        bookId: '',
        bookTitle: '',
        bookAuthor: '',
        bookImageUrl: '',
        requesterId: '',
        ownerId: '',
        requestType: CartItemType.rent,
        rentalPeriodInDays: 14,
        price: 0.0,
        status: RequestStatus.pending,
        createdAt: now,
      );

      expect(request.id, '');
      expect(request.bookTitle, '');
      expect(request.requesterId, '');
    });

    test('should handle special characters in strings', () {
      final request = CartRequest(
        id: 'req-123',
        bookId: 'book_abc',
        bookTitle: 'Test @ Book #1',
        bookAuthor: 'O\'Brien & Smith',
        bookImageUrl: 'https://example.com/image?id=1&format=jpg',
        requesterId: 'user-1',
        ownerId: 'owner_2',
        requestType: CartItemType.rent,
        rentalPeriodInDays: 14,
        price: 29.99,
        status: RequestStatus.pending,
        createdAt: now,
      );

      expect(request.bookTitle, 'Test @ Book #1');
      expect(request.bookAuthor, 'O\'Brien & Smith');
      expect(request.bookImageUrl, contains('?id=1&format=jpg'));
    });

    test('should handle all status transitions', () {
      final pending = testRequest;
      expect(pending.status, RequestStatus.pending);

      final accepted = pending.copyWith(status: RequestStatus.accepted);
      expect(accepted.status, RequestStatus.accepted);

      final rejected = pending.copyWith(status: RequestStatus.rejected);
      expect(rejected.status, RequestStatus.rejected);

      final cancelled = pending.copyWith(status: RequestStatus.cancelled);
      expect(cancelled.status, RequestStatus.cancelled);
    });

    test('should handle decimal prices correctly', () {
      final request1 = testRequest.copyWith(price: 19.99);
      expect(request1.price, 19.99);

      final request2 = testRequest.copyWith(price: 0.99);
      expect(request2.price, 0.99);

      final request3 = testRequest.copyWith(price: 100.00);
      expect(request3.price, 100.00);
    });
  });
}
