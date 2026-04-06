import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/orders/domain/entities/order.dart';

/// Repository interface for orders
abstract class OrderRepository {
  /// Get all orders for the current user
  Future<dartz.Either<Failure, List<Order>>> getUserOrders();
  
  /// Get a specific order by ID
  Future<dartz.Either<Failure, Order>> getOrderById(String orderId);
  
  /// Create a new order
  Future<dartz.Either<Failure, Order>> createOrder({
    required String bookId,
    required OrderType type,
    required double price,
  });
  
  /// Update order status
  Future<dartz.Either<Failure, Order>> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
  });
  
  /// Cancel an order
  Future<dartz.Either<Failure, void>> cancelOrder(String orderId);
  
  /// Get active orders only
  Future<dartz.Either<Failure, List<Order>>> getActiveOrders();
  
  /// Get order history (completed/delivered/cancelled orders)
  Future<dartz.Either<Failure, List<Order>>> getOrderHistory();
}
