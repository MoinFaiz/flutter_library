import 'package:equatable/equatable.dart';

/// Events for orders
abstract class OrdersEvent extends Equatable {
  const OrdersEvent();

  @override
  List<Object?> get props => [];
}

/// Load user orders
class LoadUserOrders extends OrdersEvent {
  const LoadUserOrders();
}

/// Refresh orders
class RefreshOrders extends OrdersEvent {
  const RefreshOrders();
}

/// Load active orders only
class LoadActiveOrders extends OrdersEvent {
  const LoadActiveOrders();
}

/// Load order history only
class LoadOrderHistory extends OrdersEvent {
  const LoadOrderHistory();
}

/// Cancel an order
class CancelOrder extends OrdersEvent {
  final String orderId;

  const CancelOrder(this.orderId);

  @override
  List<Object?> get props => [orderId];
}
