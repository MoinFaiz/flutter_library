import 'package:flutter_library/features/orders/data/models/order_model.dart';

/// Remote data source for orders
abstract class OrderRemoteDataSource {
  /// Get all orders for the current user
  Future<List<OrderModel>> getUserOrders();
  
  /// Get a specific order by ID
  Future<OrderModel> getOrderById(String orderId);
  
  /// Create a new order
  Future<OrderModel> createOrder({
    required String bookId,
    required String type,
    required double price,
  });
  
  /// Update order status
  Future<OrderModel> updateOrderStatus({
    required String orderId,
    required String status,
  });
  
  /// Cancel an order
  Future<void> cancelOrder(String orderId);
}
