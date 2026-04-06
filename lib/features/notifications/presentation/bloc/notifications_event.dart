import 'package:equatable/equatable.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationsEvent {
  const LoadNotifications();
}

class RefreshNotifications extends NotificationsEvent {
  const RefreshNotifications();
}

class MarkNotificationAsRead extends NotificationsEvent {
  final String notificationId;

  const MarkNotificationAsRead({required this.notificationId});

  @override
  List<Object> get props => [notificationId];
}

class MarkAllNotificationsAsRead extends NotificationsEvent {
  const MarkAllNotificationsAsRead();
}

class DeleteNotification extends NotificationsEvent {
  final String notificationId;

  const DeleteNotification({required this.notificationId});

  @override
  List<Object> get props => [notificationId];
}

class AcceptBookRequest extends NotificationsEvent {
  final String notificationId;

  const AcceptBookRequest({required this.notificationId});

  @override
  List<Object> get props => [notificationId];
}

class RejectBookRequest extends NotificationsEvent {
  final String notificationId;
  final String? reason;

  const RejectBookRequest({
    required this.notificationId,
    this.reason,
  });

  @override
  List<Object?> get props => [notificationId, reason];
}

class AcceptCartRequest extends NotificationsEvent {
  final String notificationId;

  const AcceptCartRequest({required this.notificationId});

  @override
  List<Object> get props => [notificationId];
}

class RejectCartRequest extends NotificationsEvent {
  final String notificationId;
  final String? reason;

  const RejectCartRequest({
    required this.notificationId,
    this.reason,
  });

  @override
  List<Object?> get props => [notificationId, reason];
}

class LoadUnreadCount extends NotificationsEvent {
  const LoadUnreadCount();
}
