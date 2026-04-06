import 'package:flutter_library/features/cart/data/models/cart_request_model.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_item.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CartRequestModel', () {
    final testModel = CartRequestModel(
      id: 'req1',
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
      createdAt: DateTime(2025, 10, 31, 12, 0),
      respondedAt: DateTime(2025, 10, 31, 13, 0),
    );

    test('should be a subclass of CartRequest', () {
      expect(testModel, isA<CartRequest>());
    });

    test('fromJson should create instance from JSON', () {
      final json = {
        'id': 'req1',
        'book_id': 'book1',
        'book_title': 'Test Book',
        'book_author': 'Test Author',
        'book_image_url': 'https://example.com/image.jpg',
        'requester_id': 'user1',
        'owner_id': 'owner1',
        'request_type': 'rent',
        'rental_period_in_days': 14,
        'price': 29.99,
        'status': 'pending',
        'created_at': '2025-10-31T12:00:00.000',
        'responded_at': '2025-10-31T13:00:00.000',
      };

      final model = CartRequestModel.fromJson(json);

      expect(model.id, 'req1');
      expect(model.bookId, 'book1');
      expect(model.bookTitle, 'Test Book');
      expect(model.bookAuthor, 'Test Author');
      expect(model.requestType, CartItemType.rent);
      expect(model.rentalPeriodInDays, 14);
      expect(model.price, 29.99);
      expect(model.status, RequestStatus.pending);
    });

    test('fromJson should handle all request types', () {
      expect(CartRequestModel.fromJson({'id': '1', 'book_id': 'b1', 'book_title': 'T', 'book_author': 'A', 'book_image_url': 'url', 'requester_id': 'r', 'owner_id': 'o', 'request_type': 'rent', 'price': 10, 'status': 'pending', 'created_at': '2025-01-01T00:00:00.000'}).requestType, CartItemType.rent);
      expect(CartRequestModel.fromJson({'id': '1', 'book_id': 'b1', 'book_title': 'T', 'book_author': 'A', 'book_image_url': 'url', 'requester_id': 'r', 'owner_id': 'o', 'request_type': 'rental', 'price': 10, 'status': 'pending', 'created_at': '2025-01-01T00:00:00.000'}).requestType, CartItemType.rent);
      expect(CartRequestModel.fromJson({'id': '1', 'book_id': 'b1', 'book_title': 'T', 'book_author': 'A', 'book_image_url': 'url', 'requester_id': 'r', 'owner_id': 'o', 'request_type': 'purchase', 'price': 10, 'status': 'pending', 'created_at': '2025-01-01T00:00:00.000'}).requestType, CartItemType.purchase);
      expect(CartRequestModel.fromJson({'id': '1', 'book_id': 'b1', 'book_title': 'T', 'book_author': 'A', 'book_image_url': 'url', 'requester_id': 'r', 'owner_id': 'o', 'request_type': 'buy', 'price': 10, 'status': 'pending', 'created_at': '2025-01-01T00:00:00.000'}).requestType, CartItemType.purchase);
    });

    test('fromJson should handle all request statuses', () {
      expect(CartRequestModel.fromJson({'id': '1', 'book_id': 'b1', 'book_title': 'T', 'book_author': 'A', 'book_image_url': 'url', 'requester_id': 'r', 'owner_id': 'o', 'request_type': 'rent', 'price': 10, 'status': 'pending', 'created_at': '2025-01-01T00:00:00.000'}).status, RequestStatus.pending);
      expect(CartRequestModel.fromJson({'id': '1', 'book_id': 'b1', 'book_title': 'T', 'book_author': 'A', 'book_image_url': 'url', 'requester_id': 'r', 'owner_id': 'o', 'request_type': 'rent', 'price': 10, 'status': 'accepted', 'created_at': '2025-01-01T00:00:00.000'}).status, RequestStatus.accepted);
      expect(CartRequestModel.fromJson({'id': '1', 'book_id': 'b1', 'book_title': 'T', 'book_author': 'A', 'book_image_url': 'url', 'requester_id': 'r', 'owner_id': 'o', 'request_type': 'rent', 'price': 10, 'status': 'rejected', 'created_at': '2025-01-01T00:00:00.000'}).status, RequestStatus.rejected);
      expect(CartRequestModel.fromJson({'id': '1', 'book_id': 'b1', 'book_title': 'T', 'book_author': 'A', 'book_image_url': 'url', 'requester_id': 'r', 'owner_id': 'o', 'request_type': 'rent', 'price': 10, 'status': 'cancelled', 'created_at': '2025-01-01T00:00:00.000'}).status, RequestStatus.cancelled);
    });

    test('fromJson should default rental period to 14', () {
      final json = {
        'id': 'req1',
        'book_id': 'book1',
        'book_title': 'Test Book',
        'book_author': 'Test Author',
        'book_image_url': 'url',
        'requester_id': 'user1',
        'owner_id': 'owner1',
        'request_type': 'rent',
        'price': 29.99,
        'status': 'pending',
        'created_at': '2025-10-31T12:00:00.000',
      };

      final model = CartRequestModel.fromJson(json);
      expect(model.rentalPeriodInDays, 14);
    });

    test('fromJson should handle null responded_at', () {
      final json = {
        'id': 'req1',
        'book_id': 'book1',
        'book_title': 'Test Book',
        'book_author': 'Test Author',
        'book_image_url': 'url',
        'requester_id': 'user1',
        'owner_id': 'owner1',
        'request_type': 'rent',
        'price': 29.99,
        'status': 'pending',
        'created_at': '2025-10-31T12:00:00.000',
        'responded_at': null,
      };

      final model = CartRequestModel.fromJson(json);
      expect(model.respondedAt, null);
    });

    test('toJson should convert to JSON correctly', () {
      final json = testModel.toJson();

      expect(json['id'], 'req1');
      expect(json['book_id'], 'book1');
      expect(json['book_title'], 'Test Book');
      expect(json['request_type'], 'rent');
      expect(json['status'], 'pending');
      expect(json['price'], 29.99);
      expect(json['rental_period_in_days'], 14);
    });

    test('toJson should handle purchase type', () {
      final purchaseModel = CartRequestModel.fromEntity(testModel.copyWith(requestType: CartItemType.purchase));
      final json = purchaseModel.toJson();
      expect(json['request_type'], 'purchase');
    });

    test('toJson should handle all statuses', () {
      expect(CartRequestModel.fromEntity(testModel.copyWith(status: RequestStatus.pending)).toJson()['status'], 'pending');
      expect(CartRequestModel.fromEntity(testModel.copyWith(status: RequestStatus.accepted)).toJson()['status'], 'accepted');
      expect(CartRequestModel.fromEntity(testModel.copyWith(status: RequestStatus.rejected)).toJson()['status'], 'rejected');
      expect(CartRequestModel.fromEntity(testModel.copyWith(status: RequestStatus.cancelled)).toJson()['status'], 'cancelled');
    });

    test('toJson should handle null respondedAt', () {
      final request = CartRequest(
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
      final model = CartRequestModel.fromEntity(request);
      final json = model.toJson();
      expect(json['responded_at'], null);
    });

    test('fromEntity should create model from entity', () {
      final entity = CartRequest(
        id: 'req1',
        bookId: 'book1',
        bookTitle: 'Test Book',
        bookAuthor: 'Test Author',
        bookImageUrl: 'url',
        requesterId: 'user1',
        ownerId: 'owner1',
        requestType: CartItemType.rent,
        rentalPeriodInDays: 21,
        price: 39.99,
        status: RequestStatus.accepted,
        createdAt: DateTime(2025, 10, 31),
      );

      final model = CartRequestModel.fromEntity(entity);

      expect(model.id, 'req1');
      expect(model.bookId, 'book1');
      expect(model.rentalPeriodInDays, 21);
      expect(model.price, 39.99);
      expect(model.status, RequestStatus.accepted);
    });

    test('should handle JSON serialization round trip', () {
      final json = testModel.toJson();
      final model = CartRequestModel.fromJson(json);

      expect(model.id, testModel.id);
      expect(model.bookId, testModel.bookId);
      expect(model.requestType, testModel.requestType);
      expect(model.price, testModel.price);
      expect(model.status, testModel.status);
    });

    test('should handle type case insensitivity', () {
      final json = {
        'id': 'req1',
        'book_id': 'book1',
        'book_title': 'Test Book',
        'book_author': 'Test Author',
        'book_image_url': 'url',
        'requester_id': 'user1',
        'owner_id': 'owner1',
        'request_type': 'RENT',
        'price': 29.99,
        'status': 'PENDING',
        'created_at': '2025-10-31T12:00:00.000',
      };

      final model = CartRequestModel.fromJson(json);
      expect(model.requestType, CartItemType.rent);
      expect(model.status, RequestStatus.pending);
    });

    test('should default to rent for unknown request type', () {
      final json = {
        'id': 'req1',
        'book_id': 'book1',
        'book_title': 'Test Book',
        'book_author': 'Test Author',
        'book_image_url': 'url',
        'requester_id': 'user1',
        'owner_id': 'owner1',
        'request_type': 'unknown',
        'price': 29.99,
        'status': 'pending',
        'created_at': '2025-10-31T12:00:00.000',
      };

      final model = CartRequestModel.fromJson(json);
      expect(model.requestType, CartItemType.rent);
    });

    test('should default to pending for unknown status', () {
      final json = {
        'id': 'req1',
        'book_id': 'book1',
        'book_title': 'Test Book',
        'book_author': 'Test Author',
        'book_image_url': 'url',
        'requester_id': 'user1',
        'owner_id': 'owner1',
        'request_type': 'rent',
        'price': 29.99,
        'status': 'unknown',
        'created_at': '2025-10-31T12:00:00.000',
      };

      final model = CartRequestModel.fromJson(json);
      expect(model.status, RequestStatus.pending);
    });

    test('should handle numeric price correctly', () {
      final json = {
        'id': 'req1',
        'book_id': 'book1',
        'book_title': 'Test Book',
        'book_author': 'Test Author',
        'book_image_url': 'url',
        'requester_id': 'user1',
        'owner_id': 'owner1',
        'request_type': 'rent',
        'price': 50,
        'status': 'pending',
        'created_at': '2025-10-31T12:00:00.000',
      };

      final model = CartRequestModel.fromJson(json);
      expect(model.price, 50.0);
    });
  });
}
