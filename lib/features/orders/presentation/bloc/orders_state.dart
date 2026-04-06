import 'package:equatable/equatable.dart';
import 'package:flutter_library/features/orders/domain/entities/order.dart';

/// States for orders
abstract class OrdersState extends Equatable {
  const OrdersState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class OrdersInitial extends OrdersState {
  const OrdersInitial();
}

/// Loading state
class OrdersLoading extends OrdersState {
  const OrdersLoading();
}

/// Orders loaded successfully
class OrdersLoaded extends OrdersState {
  final List<Order> orders;
  final List<Order> activeOrders;
  final List<Order> orderHistory;

  const OrdersLoaded({
    required this.orders,
    required this.activeOrders,
    required this.orderHistory,
  });

  @override
  List<Object?> get props => [orders, activeOrders, orderHistory];
}

/// Error state
class OrdersError extends OrdersState {
  final String message;

  const OrdersError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Order cancelled successfully
class OrderCancelled extends OrdersState {
  final String orderId;

  const OrderCancelled(this.orderId);

  @override
  List<Object?> get props => [orderId];
}
