import 'package:flutter_library/features/cart/domain/entities/cart_item.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_notification.dart';
import 'package:flutter_library/features/cart/presentation/bloc/cart_notification_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CartNotificationState', () {
    final testNotification = CartNotification(
      id: 'notif1',
      requestId: 'req1',
      bookId: 'book1',
      bookTitle: 'Test Book',
      bookAuthor: 'Test Author',
      bookImageUrl: 'url',
      type: NotificationType.requestReceived,
      requestType: CartItemType.rent,
      message: 'New request',
      isRead: false,
      createdAt: DateTime(2025, 10, 31),
    );

    group('CartNotificationInitial', () {
      test('should have empty props', () {
        final state = CartNotificationInitial();
        expect(state.props, []);
      });

      test('should support value equality', () {
        final state1 = CartNotificationInitial();
        final state2 = CartNotificationInitial();
        expect(state1, state2);
      });
    });

    group('CartNotificationLoading', () {
      test('should have empty props', () {
        final state = CartNotificationLoading();
        expect(state.props, []);
      });

      test('should support value equality', () {
        final state1 = CartNotificationLoading();
        final state2 = CartNotificationLoading();
        expect(state1, state2);
      });
    });

    group('CartNotificationLoaded', () {
      test('should create with default unread count', () {
        final state = CartNotificationLoaded(notifications: [testNotification]);
        expect(state.notifications, [testNotification]);
        expect(state.unreadCount, 0);
      });

      test('should create with all parameters', () {
        final state = CartNotificationLoaded(
          notifications: [testNotification],
          unreadCount: 5,
        );

        expect(state.notifications, [testNotification]);
        expect(state.unreadCount, 5);
      });

      test('should include all properties in props', () {
        final state = CartNotificationLoaded(
          notifications: [testNotification],
          unreadCount: 3,
        );

        expect(state.props.length, 2);
        expect(state.props[0], [testNotification]);
        expect(state.props[1], 3);
      });

      test('copyWith should create new state with updated data', () {
        final state = CartNotificationLoaded(notifications: [testNotification], unreadCount: 1);
        final newNotification = testNotification.copyWith(id: 'notif2');
        final newState = state.copyWith([newNotification]);

        expect(newState.notifications, [newNotification]);
        expect(newState.unreadCount, 1); // Preserved
      });

      test('copyWithState should update specific fields', () {
        final state = CartNotificationLoaded(
          notifications: [testNotification],
          unreadCount: 1,
        );

        final newState = state.copyWithState(unreadCount: 5);

        expect(newState.notifications, [testNotification]); // Preserved
        expect(newState.unreadCount, 5); // Updated
      });

      test('copyWithState should preserve values when parameters are null', () {
        final state = CartNotificationLoaded(
          notifications: [testNotification],
          unreadCount: 3,
        );

        final newState = state.copyWithState();

        expect(newState.notifications, state.notifications);
        expect(newState.unreadCount, state.unreadCount);
      });

      test('should support value equality', () {
        final state1 = CartNotificationLoaded(
          notifications: [testNotification],
          unreadCount: 2,
        );
        final state2 = CartNotificationLoaded(
          notifications: [testNotification],
          unreadCount: 2,
        );

        expect(state1, state2);
      });

      test('should not be equal if properties differ', () {
        final state1 = CartNotificationLoaded(notifications: [testNotification], unreadCount: 1);
        final state2 = CartNotificationLoaded(notifications: [testNotification], unreadCount: 2);

        expect(state1, isNot(state2));
      });

      test('should handle empty notifications list', () {
        final state = const CartNotificationLoaded(notifications: []);
        expect(state.notifications, []);
      });

      test('should handle multiple notifications', () {
        final notif2 = testNotification.copyWith(id: 'notif2');
        final state = CartNotificationLoaded(notifications: [testNotification, notif2]);
        expect(state.notifications.length, 2);
      });

      test('should handle zero unread count', () {
        final state = CartNotificationLoaded(notifications: [testNotification], unreadCount: 0);
        expect(state.unreadCount, 0);
      });

      test('should handle large unread count', () {
        final state = CartNotificationLoaded(notifications: [testNotification], unreadCount: 999);
        expect(state.unreadCount, 999);
      });
    });

    group('CartNotificationError', () {
      test('should create with error message', () {
        final state = const CartNotificationError('Error message');
        expect(state.message, 'Error message');
      });

      test('should include message in props', () {
        final state = const CartNotificationError('Error message');
        expect(state.props, ['Error message']);
      });

      test('should support value equality', () {
        final state1 = const CartNotificationError('Error message');
        final state2 = const CartNotificationError('Error message');
        expect(state1, state2);
      });

      test('should not be equal if messages differ', () {
        final state1 = const CartNotificationError('Error 1');
        final state2 = const CartNotificationError('Error 2');
        expect(state1, isNot(state2));
      });

      test('should handle empty error message', () {
        final state = const CartNotificationError('');
        expect(state.message, '');
      });
    });
  });
}
