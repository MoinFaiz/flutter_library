import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/notifications/presentation/bloc/notifications_event.dart';

void main() {
  group('NotificationsEvent Tests', () {
    group('LoadNotifications', () {
      test('should support value equality', () {
        const event1 = LoadNotifications();
        const event2 = LoadNotifications();

        expect(event1, equals(event2));
      });

      test('should have empty props', () {
        const event = LoadNotifications();

        expect(event.props, equals([]));
      });

      test('should extend NotificationsEvent', () {
        const event = LoadNotifications();

        expect(event, isA<NotificationsEvent>());
      });
    });

    group('RefreshNotifications', () {
      test('should support value equality', () {
        const event1 = RefreshNotifications();
        const event2 = RefreshNotifications();

        expect(event1, equals(event2));
      });

      test('should have empty props', () {
        const event = RefreshNotifications();

        expect(event.props, equals([]));
      });

      test('should extend NotificationsEvent', () {
        const event = RefreshNotifications();

        expect(event, isA<NotificationsEvent>());
      });
    });

    group('MarkNotificationAsRead', () {
      test('should support value equality', () {
        const event1 = MarkNotificationAsRead(notificationId: 'notification_1');
        const event2 = MarkNotificationAsRead(notificationId: 'notification_1');

        expect(event1, equals(event2));
      });

      test('should not be equal with different notificationId', () {
        const event1 = MarkNotificationAsRead(notificationId: 'notification_1');
        const event2 = MarkNotificationAsRead(notificationId: 'notification_2');

        expect(event1, isNot(equals(event2)));
      });

      test('should have correct props', () {
        const event = MarkNotificationAsRead(notificationId: 'notification_1');

        expect(event.props, equals(['notification_1']));
      });

      test('should extend NotificationsEvent', () {
        const event = MarkNotificationAsRead(notificationId: 'notification_1');

        expect(event, isA<NotificationsEvent>());
      });

      test('should handle empty notificationId', () {
        const event = MarkNotificationAsRead(notificationId: '');

        expect(event.notificationId, equals(''));
        expect(event.props, equals(['']));
      });
    });

    group('MarkAllNotificationsAsRead', () {
      test('should support value equality', () {
        const event1 = MarkAllNotificationsAsRead();
        const event2 = MarkAllNotificationsAsRead();

        expect(event1, equals(event2));
      });

      test('should have empty props', () {
        const event = MarkAllNotificationsAsRead();

        expect(event.props, equals([]));
      });

      test('should extend NotificationsEvent', () {
        const event = MarkAllNotificationsAsRead();

        expect(event, isA<NotificationsEvent>());
      });
    });

    group('DeleteNotification', () {
      test('should support value equality', () {
        const event1 = DeleteNotification(notificationId: 'notification_1');
        const event2 = DeleteNotification(notificationId: 'notification_1');

        expect(event1, equals(event2));
      });

      test('should not be equal with different notificationId', () {
        const event1 = DeleteNotification(notificationId: 'notification_1');
        const event2 = DeleteNotification(notificationId: 'notification_2');

        expect(event1, isNot(equals(event2)));
      });

      test('should have correct props', () {
        const event = DeleteNotification(notificationId: 'notification_1');

        expect(event.props, equals(['notification_1']));
      });

      test('should extend NotificationsEvent', () {
        const event = DeleteNotification(notificationId: 'notification_1');

        expect(event, isA<NotificationsEvent>());
      });

      test('should handle empty notificationId', () {
        const event = DeleteNotification(notificationId: '');

        expect(event.notificationId, equals(''));
        expect(event.props, equals(['']));
      });
    });

    group('AcceptBookRequest', () {
      test('should support value equality', () {
        const event1 = AcceptBookRequest(notificationId: 'notification_1');
        const event2 = AcceptBookRequest(notificationId: 'notification_1');

        expect(event1, equals(event2));
      });

      test('should not be equal with different notificationId', () {
        const event1 = AcceptBookRequest(notificationId: 'notification_1');
        const event2 = AcceptBookRequest(notificationId: 'notification_2');

        expect(event1, isNot(equals(event2)));
      });

      test('should have correct props', () {
        const event = AcceptBookRequest(notificationId: 'notification_1');

        expect(event.props, equals(['notification_1']));
      });

      test('should extend NotificationsEvent', () {
        const event = AcceptBookRequest(notificationId: 'notification_1');

        expect(event, isA<NotificationsEvent>());
      });

      test('should handle empty notificationId', () {
        const event = AcceptBookRequest(notificationId: '');

        expect(event.notificationId, equals(''));
        expect(event.props, equals(['']));
      });
    });

    group('RejectBookRequest', () {
      test('should support value equality with reason', () {
        const event1 = RejectBookRequest(
          notificationId: 'notification_1',
          reason: 'Not available',
        );
        const event2 = RejectBookRequest(
          notificationId: 'notification_1',
          reason: 'Not available',
        );

        expect(event1, equals(event2));
      });

      test('should support value equality without reason', () {
        const event1 = RejectBookRequest(notificationId: 'notification_1');
        const event2 = RejectBookRequest(notificationId: 'notification_1');

        expect(event1, equals(event2));
      });

      test('should not be equal with different notificationId', () {
        const event1 = RejectBookRequest(notificationId: 'notification_1');
        const event2 = RejectBookRequest(notificationId: 'notification_2');

        expect(event1, isNot(equals(event2)));
      });

      test('should not be equal with different reason', () {
        const event1 = RejectBookRequest(
          notificationId: 'notification_1',
          reason: 'Not available',
        );
        const event2 = RejectBookRequest(
          notificationId: 'notification_1',
          reason: 'Different reason',
        );

        expect(event1, isNot(equals(event2)));
      });

      test('should not be equal when one has reason and other does not', () {
        const event1 = RejectBookRequest(
          notificationId: 'notification_1',
          reason: 'Not available',
        );
        const event2 = RejectBookRequest(notificationId: 'notification_1');

        expect(event1, isNot(equals(event2)));
      });

      test('should have correct props with reason', () {
        const event = RejectBookRequest(
          notificationId: 'notification_1',
          reason: 'Not available',
        );

        expect(event.props, equals(['notification_1', 'Not available']));
      });

      test('should have correct props without reason', () {
        const event = RejectBookRequest(notificationId: 'notification_1');

        expect(event.props, equals(['notification_1', null]));
      });

      test('should extend NotificationsEvent', () {
        const event = RejectBookRequest(notificationId: 'notification_1');

        expect(event, isA<NotificationsEvent>());
      });

      test('should handle empty notificationId', () {
        const event = RejectBookRequest(notificationId: '');

        expect(event.notificationId, equals(''));
        expect(event.reason, isNull);
        expect(event.props, equals(['', null]));
      });

      test('should handle empty reason', () {
        const event = RejectBookRequest(
          notificationId: 'notification_1',
          reason: '',
        );

        expect(event.notificationId, equals('notification_1'));
        expect(event.reason, equals(''));
        expect(event.props, equals(['notification_1', '']));
      });
    });

    group('AcceptCartRequest', () {
      test('should support value equality', () {
        const event1 = AcceptCartRequest(notificationId: 'notification_1');
        const event2 = AcceptCartRequest(notificationId: 'notification_1');

        expect(event1, equals(event2));
      });

      test('should not be equal with different notificationId', () {
        const event1 = AcceptCartRequest(notificationId: 'notification_1');
        const event2 = AcceptCartRequest(notificationId: 'notification_2');

        expect(event1, isNot(equals(event2)));
      });

      test('should have correct props', () {
        const event = AcceptCartRequest(notificationId: 'notification_1');

        expect(event.props, equals(['notification_1']));
      });

      test('should extend NotificationsEvent', () {
        const event = AcceptCartRequest(notificationId: 'notification_1');

        expect(event, isA<NotificationsEvent>());
      });
    });

    group('RejectCartRequest', () {
      test('should support value equality with reason', () {
        const event1 = RejectCartRequest(
          notificationId: 'notification_1',
          reason: 'Out of stock',
        );
        const event2 = RejectCartRequest(
          notificationId: 'notification_1',
          reason: 'Out of stock',
        );

        expect(event1, equals(event2));
      });

      test('should support value equality without reason', () {
        const event1 = RejectCartRequest(notificationId: 'notification_1');
        const event2 = RejectCartRequest(notificationId: 'notification_1');

        expect(event1, equals(event2));
      });

      test('should not be equal with different notificationId', () {
        const event1 = RejectCartRequest(notificationId: 'notification_1');
        const event2 = RejectCartRequest(notificationId: 'notification_2');

        expect(event1, isNot(equals(event2)));
      });

      test('should have correct props with reason', () {
        const event = RejectCartRequest(
          notificationId: 'notification_1',
          reason: 'Out of stock',
        );

        expect(event.props, equals(['notification_1', 'Out of stock']));
      });

      test('should have correct props without reason', () {
        const event = RejectCartRequest(notificationId: 'notification_1');

        expect(event.props, equals(['notification_1', null]));
      });

      test('should extend NotificationsEvent', () {
        const event = RejectCartRequest(notificationId: 'notification_1');

        expect(event, isA<NotificationsEvent>());
      });
    });

    group('LoadUnreadCount', () {
      test('should support value equality', () {
        const event1 = LoadUnreadCount();
        const event2 = LoadUnreadCount();

        expect(event1, equals(event2));
      });

      test('should have empty props', () {
        const event = LoadUnreadCount();

        expect(event.props, equals([]));
      });

      test('should extend NotificationsEvent', () {
        const event = LoadUnreadCount();

        expect(event, isA<NotificationsEvent>());
      });
    });

    group('Event Inheritance', () {
      test('all events should extend NotificationsEvent', () {
        const events = [
          LoadNotifications(),
          RefreshNotifications(),
          MarkNotificationAsRead(notificationId: 'test'),
          MarkAllNotificationsAsRead(),
          DeleteNotification(notificationId: 'test'),
          AcceptBookRequest(notificationId: 'test'),
          RejectBookRequest(notificationId: 'test'),
          AcceptCartRequest(notificationId: 'test'),
          RejectCartRequest(notificationId: 'test'),
          LoadUnreadCount(),
        ];

        for (final event in events) {
          expect(event, isA<NotificationsEvent>());
        }
      });
    });

    group('Base NotificationsEvent', () {
      test('should have empty props by default', () {
        // Since NotificationsEvent is abstract, we can't instantiate it directly,
        // but we can verify through subclasses that inherit the default props
        const event = LoadNotifications();
        
        // All events that don't override props should have empty props
        expect(event.props, equals([]));
      });
    });

    group('Edge Cases', () {
      test('should handle very long notificationId', () {
        final longId = 'a' * 1000;
        final event = MarkNotificationAsRead(notificationId: longId);

        expect(event.notificationId, equals(longId));
        expect(event.props, equals([longId]));
      });

      test('should handle very long reason', () {
        final longReason = 'b' * 1000;
        final event = RejectBookRequest(
          notificationId: 'notification_1',
          reason: longReason,
        );

        expect(event.reason, equals(longReason));
        expect(event.props, equals(['notification_1', longReason]));
      });

      test('should handle special characters in notificationId', () {
        const specialId = 'notification_1@#\$%^&*()';
        const event = MarkNotificationAsRead(notificationId: specialId);

        expect(event.notificationId, equals(specialId));
        expect(event.props, equals([specialId]));
      });

      test('should handle special characters in reason', () {
        const specialReason = 'Reason with special chars: @#\$%^&*()';
        const event = RejectBookRequest(
          notificationId: 'notification_1',
          reason: specialReason,
        );

        expect(event.reason, equals(specialReason));
        expect(event.props, equals(['notification_1', specialReason]));
      });
    });
  });
}
