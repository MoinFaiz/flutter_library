import 'package:equatable/equatable.dart';
import 'package:flutter_library/features/notifications/domain/entities/notification.dart';

abstract class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];
}

class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();
}

class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

class NotificationsLoaded extends NotificationsState {
  final List<AppNotification> notifications;
  final int unreadCount;

  const NotificationsLoaded({
    required this.notifications,
    this.unreadCount = 0,
  });

  @override
  List<Object> get props => [notifications, unreadCount];

  NotificationsLoaded copyWith({
    List<AppNotification>? notifications,
    int? unreadCount,
  }) {
    return NotificationsLoaded(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

class NotificationsError extends NotificationsState {
  final String message;

  const NotificationsError({required this.message});

  @override
  List<Object> get props => [message];
}

class NotificationActionLoading extends NotificationsState {
  final List<AppNotification> notifications;
  final int unreadCount;
  final String actionId;

  const NotificationActionLoading({
    required this.notifications,
    required this.unreadCount,
    required this.actionId,
  });

  @override
  List<Object> get props => [notifications, unreadCount, actionId];
}

class NotificationActionSuccess extends NotificationsState {
  final List<AppNotification> notifications;
  final int unreadCount;
  final String message;

  const NotificationActionSuccess({
    required this.notifications,
    required this.unreadCount,
    required this.message,
  });

  @override
  List<Object> get props => [notifications, unreadCount, message];
}

class NotificationActionError extends NotificationsState {
  final List<AppNotification> notifications;
  final int unreadCount;
  final String message;

  const NotificationActionError({
    required this.notifications,
    required this.unreadCount,
    required this.message,
  });

  @override
  List<Object> get props => [notifications, unreadCount, message];
}
