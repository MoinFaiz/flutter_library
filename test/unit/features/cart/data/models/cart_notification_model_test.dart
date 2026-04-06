import 'package:flutter_library/features/cart/data/models/cart_notification_model.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_item.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_notification.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CartNotificationModel', () {
    final testModel = CartNotificationModel(
      id: 'notif1',
      requestId: 'req1',
      bookId: 'book1',
      bookTitle: 'Test Book',
      bookAuthor: 'Test Author',
      bookImageUrl: 'https://example.com/image.jpg',
      type: NotificationType.requestReceived,
      requestType: CartItemType.rent,
      message: 'You have a new rental request',
      isRead: false,
      createdAt: DateTime(2025, 10, 31, 12, 0),
      actionUserId: 'user1',
      actionUserName: 'John Doe',
    );

    test('should be a subclass of CartNotification', () {
      expect(testModel, isA<CartNotification>());
    });

    test('fromJson should create instance from JSON', () {
      final json = {
        'id': 'notif1',
        'request_id': 'req1',
        'book_id': 'book1',
        'book_title': 'Test Book',
        'book_author': 'Test Author',
        'book_image_url': 'https://example.com/image.jpg',
        'type': 'request_received',
        'request_type': 'rent',
        'message': 'You have a new rental request',
        'is_read': false,
        'created_at': '2025-10-31T12:00:00.000',
        'action_user_id': 'user1',
        'action_user_name': 'John Doe',
      };

      final model = CartNotificationModel.fromJson(json);

      expect(model.id, 'notif1');
      expect(model.requestId, 'req1');
      expect(model.bookId, 'book1');
      expect(model.bookTitle, 'Test Book');
      expect(model.type, NotificationType.requestReceived);
      expect(model.requestType, CartItemType.rent);
      expect(model.message, 'You have a new rental request');
      expect(model.isRead, false);
      expect(model.actionUserId, 'user1');
      expect(model.actionUserName, 'John Doe');
    });

    test('fromJson should handle all notification types', () {
      expect(CartNotificationModel.fromJson({'id': '1', 'request_id': 'r', 'book_id': 'b', 'book_title': 'T', 'book_author': 'A', 'book_image_url': 'url', 'type': 'request_sent', 'request_type': 'rent', 'message': 'msg', 'is_read': false, 'created_at': '2025-01-01T00:00:00.000'}).type, NotificationType.requestSent);
      expect(CartNotificationModel.fromJson({'id': '1', 'request_id': 'r', 'book_id': 'b', 'book_title': 'T', 'book_author': 'A', 'book_image_url': 'url', 'type': 'request_received', 'request_type': 'rent', 'message': 'msg', 'is_read': false, 'created_at': '2025-01-01T00:00:00.000'}).type, NotificationType.requestReceived);
      expect(CartNotificationModel.fromJson({'id': '1', 'request_id': 'r', 'book_id': 'b', 'book_title': 'T', 'book_author': 'A', 'book_image_url': 'url', 'type': 'request_accepted', 'request_type': 'rent', 'message': 'msg', 'is_read': false, 'created_at': '2025-01-01T00:00:00.000'}).type, NotificationType.requestAccepted);
      expect(CartNotificationModel.fromJson({'id': '1', 'request_id': 'r', 'book_id': 'b', 'book_title': 'T', 'book_author': 'A', 'book_image_url': 'url', 'type': 'request_rejected', 'request_type': 'rent', 'message': 'msg', 'is_read': false, 'created_at': '2025-01-01T00:00:00.000'}).type, NotificationType.requestRejected);
    });

    test('fromJson should handle all request types', () {
      expect(CartNotificationModel.fromJson({'id': '1', 'request_id': 'r', 'book_id': 'b', 'book_title': 'T', 'book_author': 'A', 'book_image_url': 'url', 'type': 'request_sent', 'request_type': 'rent', 'message': 'msg', 'is_read': false, 'created_at': '2025-01-01T00:00:00.000'}).requestType, CartItemType.rent);
      expect(CartNotificationModel.fromJson({'id': '1', 'request_id': 'r', 'book_id': 'b', 'book_title': 'T', 'book_author': 'A', 'book_image_url': 'url', 'type': 'request_sent', 'request_type': 'rental', 'message': 'msg', 'is_read': false, 'created_at': '2025-01-01T00:00:00.000'}).requestType, CartItemType.rent);
      expect(CartNotificationModel.fromJson({'id': '1', 'request_id': 'r', 'book_id': 'b', 'book_title': 'T', 'book_author': 'A', 'book_image_url': 'url', 'type': 'request_sent', 'request_type': 'purchase', 'message': 'msg', 'is_read': false, 'created_at': '2025-01-01T00:00:00.000'}).requestType, CartItemType.purchase);
      expect(CartNotificationModel.fromJson({'id': '1', 'request_id': 'r', 'book_id': 'b', 'book_title': 'T', 'book_author': 'A', 'book_image_url': 'url', 'type': 'request_sent', 'request_type': 'buy', 'message': 'msg', 'is_read': false, 'created_at': '2025-01-01T00:00:00.000'}).requestType, CartItemType.purchase);
    });

    test('fromJson should handle null optional fields', () {
      final json = {
        'id': 'notif1',
        'request_id': 'req1',
        'book_id': 'book1',
        'book_title': 'Test Book',
        'book_author': 'Test Author',
        'book_image_url': 'url',
        'type': 'request_sent',
        'request_type': 'rent',
        'message': 'message',
        'is_read': true,
        'created_at': '2025-10-31T12:00:00.000',
        'action_user_id': null,
        'action_user_name': null,
      };

      final model = CartNotificationModel.fromJson(json);
      expect(model.actionUserId, null);
      expect(model.actionUserName, null);
    });

    test('toJson should convert to JSON correctly', () {
      final json = testModel.toJson();

      expect(json['id'], 'notif1');
      expect(json['request_id'], 'req1');
      expect(json['book_id'], 'book1');
      expect(json['type'], 'request_received');
      expect(json['request_type'], 'rent');
      expect(json['message'], 'You have a new rental request');
      expect(json['is_read'], false);
      expect(json['action_user_id'], 'user1');
      expect(json['action_user_name'], 'John Doe');
    });

    test('toJson should handle all notification types', () {
      expect(CartNotificationModel.fromEntity(testModel.copyWith(type: NotificationType.requestSent)).toJson()['type'], 'request_sent');
      expect(CartNotificationModel.fromEntity(testModel.copyWith(type: NotificationType.requestReceived)).toJson()['type'], 'request_received');
      expect(CartNotificationModel.fromEntity(testModel.copyWith(type: NotificationType.requestAccepted)).toJson()['type'], 'request_accepted');
      expect(CartNotificationModel.fromEntity(testModel.copyWith(type: NotificationType.requestRejected)).toJson()['type'], 'request_rejected');
    });

    test('toJson should handle all request types', () {
      expect(CartNotificationModel.fromEntity(testModel.copyWith(requestType: CartItemType.rent)).toJson()['request_type'], 'rent');
      expect(CartNotificationModel.fromEntity(testModel.copyWith(requestType: CartItemType.purchase)).toJson()['request_type'], 'purchase');
    });

    test('toJson should handle null optional fields', () {
      final notification = CartNotification(
        id: 'notif1',
        requestId: 'req1',
        bookId: 'book1',
        bookTitle: 'Test Book',
        bookAuthor: 'Test Author',
        bookImageUrl: 'url',
        type: NotificationType.requestSent,
        requestType: CartItemType.rent,
        message: 'message',
        isRead: false,
        createdAt: DateTime(2025, 10, 31),
      );
      final model = CartNotificationModel.fromEntity(notification);
      final json = model.toJson();
      expect(json['action_user_id'], null);
      expect(json['action_user_name'], null);
    });

    test('fromEntity should create model from entity', () {
      final entity = CartNotification(
        id: 'notif1',
        requestId: 'req1',
        bookId: 'book1',
        bookTitle: 'Test Book',
        bookAuthor: 'Test Author',
        bookImageUrl: 'url',
        type: NotificationType.requestAccepted,
        requestType: CartItemType.purchase,
        message: 'Request accepted',
        isRead: true,
        createdAt: DateTime(2025, 10, 31),
        actionUserId: 'user2',
        actionUserName: 'Jane',
      );

      final model = CartNotificationModel.fromEntity(entity);

      expect(model.id, 'notif1');
      expect(model.type, NotificationType.requestAccepted);
      expect(model.requestType, CartItemType.purchase);
      expect(model.isRead, true);
      expect(model.actionUserId, 'user2');
    });

    test('should handle JSON serialization round trip', () {
      final json = testModel.toJson();
      final model = CartNotificationModel.fromJson(json);

      expect(model.id, testModel.id);
      expect(model.requestId, testModel.requestId);
      expect(model.type, testModel.type);
      expect(model.requestType, testModel.requestType);
      expect(model.isRead, testModel.isRead);
    });

    test('should handle type case insensitivity', () {
      final json = {
        'id': 'notif1',
        'request_id': 'req1',
        'book_id': 'book1',
        'book_title': 'Test Book',
        'book_author': 'Test Author',
        'book_image_url': 'url',
        'type': 'REQUEST_SENT',
        'request_type': 'RENT',
        'message': 'message',
        'is_read': false,
        'created_at': '2025-10-31T12:00:00.000',
      };

      final model = CartNotificationModel.fromJson(json);
      expect(model.type, NotificationType.requestSent);
      expect(model.requestType, CartItemType.rent);
    });

    test('should default to requestSent for unknown notification type', () {
      final json = {
        'id': 'notif1',
        'request_id': 'req1',
        'book_id': 'book1',
        'book_title': 'Test Book',
        'book_author': 'Test Author',
        'book_image_url': 'url',
        'type': 'unknown',
        'request_type': 'rent',
        'message': 'message',
        'is_read': false,
        'created_at': '2025-10-31T12:00:00.000',
      };

      final model = CartNotificationModel.fromJson(json);
      expect(model.type, NotificationType.requestSent);
    });

    test('should default to rent for unknown request type', () {
      final json = {
        'id': 'notif1',
        'request_id': 'req1',
        'book_id': 'book1',
        'book_title': 'Test Book',
        'book_author': 'Test Author',
        'book_image_url': 'url',
        'type': 'request_sent',
        'request_type': 'unknown',
        'message': 'message',
        'is_read': false,
        'created_at': '2025-10-31T12:00:00.000',
      };

      final model = CartNotificationModel.fromJson(json);
      expect(model.requestType, CartItemType.rent);
    });
  });
}
