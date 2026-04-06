import 'package:flutter_library/core/presentation/base_bloc.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_notification.dart';

abstract class CartNotificationState extends BaseState {
  const CartNotificationState();
}

class CartNotificationInitial extends CartNotificationState {
  @override
  List<Object> get props => [];
}

class CartNotificationLoading extends BaseLoading implements CartNotificationState {
  @override
  List<Object> get props => [];
}

class CartNotificationLoaded extends BaseDataState<List<CartNotification>> implements CartNotificationState {
  final int unreadCount;

  const CartNotificationLoaded({
    required List<CartNotification> notifications,
    this.unreadCount = 0,
  }) : super(notifications);

  List<CartNotification> get notifications => data;

  @override
  List<Object> get props => [data, unreadCount];

  @override
  CartNotificationLoaded copyWith(List<CartNotification> newData) {
    return CartNotificationLoaded(
      notifications: newData,
      unreadCount: unreadCount,
    );
  }

  CartNotificationLoaded copyWithState({
    List<CartNotification>? notifications,
    int? unreadCount,
  }) {
    return CartNotificationLoaded(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

class CartNotificationError extends BaseError implements CartNotificationState {
  const CartNotificationError(super.message);
}
