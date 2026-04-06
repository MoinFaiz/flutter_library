import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:flutter_library/features/notifications/domain/entities/notification.dart';

class DummyNotification extends AppNotification {
  DummyNotification()
      : super(
          id: 'id',
          title: 'title',
          message: 'msg',
          timestamp: DateTime(2020),
          type: NotificationType.information,
        );
}

void main() {
  group('NotificationsState', () {
    test('NotificationsInitial equality', () {
      expect(const NotificationsInitial(), const NotificationsInitial());
    });
    test('NotificationsLoading equality', () {
      expect(const NotificationsLoading(), const NotificationsLoading());
    });
    test('NotificationsLoaded equality and copyWith', () {
      final n = DummyNotification();
      final loaded = NotificationsLoaded(notifications: [n], unreadCount: 1);
      expect(loaded, NotificationsLoaded(notifications: [n], unreadCount: 1));
      expect(loaded.copyWith(notifications: [n], unreadCount: 2), NotificationsLoaded(notifications: [n], unreadCount: 2));
    });
    test('NotificationsError equality and props', () {
      expect(const NotificationsError(message: 'err'), const NotificationsError(message: 'err'));
      expect(const NotificationsError(message: 'err').props, ['err']);
    });
    test('NotificationActionLoading equality and props', () {
      final n = DummyNotification();
      expect(
        NotificationActionLoading(notifications: [n], unreadCount: 1, actionId: 'a'),
        NotificationActionLoading(notifications: [n], unreadCount: 1, actionId: 'a'),
      );
    });
    test('NotificationActionSuccess equality and props', () {
      final n = DummyNotification();
      expect(
        NotificationActionSuccess(notifications: [n], unreadCount: 1, message: 'm'),
        NotificationActionSuccess(notifications: [n], unreadCount: 1, message: 'm'),
      );
    });
    test('NotificationActionError equality and props', () {
      final n = DummyNotification();
      expect(
        NotificationActionError(notifications: [n], unreadCount: 1, message: 'm'),
        NotificationActionError(notifications: [n], unreadCount: 1, message: 'm'),
      );
    });
  });
}
