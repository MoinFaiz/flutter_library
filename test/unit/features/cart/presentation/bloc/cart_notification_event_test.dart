import 'package:flutter_library/features/cart/presentation/bloc/cart_notification_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CartNotificationEvent', () {
    group('LoadCartNotifications', () {
      test('should have empty props', () {
        final event = LoadCartNotifications();
        expect(event.props, []);
      });

      test('should support value equality', () {
        final event1 = LoadCartNotifications();
        final event2 = LoadCartNotifications();
        expect(event1, event2);
      });
    });

    group('MarkCartNotificationAsRead', () {
      test('should create instance with notification ID', () {
        final event = const MarkCartNotificationAsRead('notif1');
        expect(event.notificationId, 'notif1');
      });

      test('should support value equality', () {
        final event1 = const MarkCartNotificationAsRead('notif1');
        final event2 = const MarkCartNotificationAsRead('notif1');
        expect(event1, event2);
      });

      test('should not be equal if IDs differ', () {
        final event1 = const MarkCartNotificationAsRead('notif1');
        final event2 = const MarkCartNotificationAsRead('notif2');
        expect(event1, isNot(event2));
      });

      test('should include notification ID in props', () {
        final event = const MarkCartNotificationAsRead('notif1');
        expect(event.props, ['notif1']);
      });

      test('should handle empty string ID', () {
        final event = const MarkCartNotificationAsRead('');
        expect(event.notificationId, '');
      });

      test('should handle special characters in ID', () {
        final event = const MarkCartNotificationAsRead('notif-123_abc');
        expect(event.notificationId, 'notif-123_abc');
      });
    });

    group('RefreshCartNotifications', () {
      test('should have empty props', () {
        final event = RefreshCartNotifications();
        expect(event.props, []);
      });

      test('should support value equality', () {
        final event1 = RefreshCartNotifications();
        final event2 = RefreshCartNotifications();
        expect(event1, event2);
      });
    });
  });
}
