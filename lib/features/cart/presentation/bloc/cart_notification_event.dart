import 'package:equatable/equatable.dart';

abstract class CartNotificationEvent extends Equatable {
  const CartNotificationEvent();

  @override
  List<Object?> get props => [];
}

class LoadCartNotifications extends CartNotificationEvent {}

class MarkCartNotificationAsRead extends CartNotificationEvent {
  final String notificationId;

  const MarkCartNotificationAsRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class RefreshCartNotifications extends CartNotificationEvent {}
