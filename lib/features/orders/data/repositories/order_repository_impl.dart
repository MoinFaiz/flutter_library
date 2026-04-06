import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/orders/data/datasources/order_remote_datasource.dart';
import 'package:flutter_library/features/orders/domain/entities/order.dart';
import 'package:flutter_library/features/orders/domain/repositories/order_repository.dart';

/// Implementation of OrderRepository
class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl({required this.remoteDataSource});

  @override
  Future<dartz.Either<Failure, List<Order>>> getUserOrders() async {
    try {
      final orders = await remoteDataSource.getUserOrders();
      // Sort orders: active orders first, then by date (latest first)
      orders.sort((a, b) {
        if (a.isActive && !b.isActive) return -1;
        if (!a.isActive && b.isActive) return 1;
        return b.orderDate.compareTo(a.orderDate);
      });
      return dartz.Right(orders);
    } catch (e) {
      return dartz.Left(ServerFailure(message: 'Failed to load orders: ${e.toString()}'));
    }
  }

  @override
  Future<dartz.Either<Failure, Order>> getOrderById(String orderId) async {
    try {
      final order = await remoteDataSource.getOrderById(orderId);
      return dartz.Right(order);
    } catch (e) {
      return dartz.Left(ServerFailure(message: 'Failed to load order: ${e.toString()}'));
    }
  }

  @override
  Future<dartz.Either<Failure, Order>> createOrder({
    required String bookId,
    required OrderType type,
    required double price,
  }) async {
    try {
      final order = await remoteDataSource.createOrder(
        bookId: bookId,
        type: type.name,
        price: price,
      );
      return dartz.Right(order);
    } catch (e) {
      return dartz.Left(ServerFailure(message: 'Failed to create order: ${e.toString()}'));
    }
  }

  @override
  Future<dartz.Either<Failure, Order>> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
  }) async {
    try {
      final order = await remoteDataSource.updateOrderStatus(
        orderId: orderId,
        status: status.name,
      );
      return dartz.Right(order);
    } catch (e) {
      return dartz.Left(ServerFailure(message: 'Failed to update order: ${e.toString()}'));
    }
  }

  @override
  Future<dartz.Either<Failure, void>> cancelOrder(String orderId) async {
    try {
      await remoteDataSource.cancelOrder(orderId);
      return const dartz.Right(null);
    } catch (e) {
      return dartz.Left(ServerFailure(message: 'Failed to cancel order: ${e.toString()}'));
    }
  }

  @override
  Future<dartz.Either<Failure, List<Order>>> getActiveOrders() async {
    try {
      final orders = await remoteDataSource.getUserOrders();
      final activeOrders = orders.where((order) => order.isActive).toList();
      // Sort by date (latest first)
      activeOrders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
      return dartz.Right(activeOrders);
    } catch (e) {
      return dartz.Left(ServerFailure(message: 'Failed to load active orders: ${e.toString()}'));
    }
  }

  @override
  Future<dartz.Either<Failure, List<Order>>> getOrderHistory() async {
    try {
      final orders = await remoteDataSource.getUserOrders();
      final historyOrders = orders.where((order) => !order.isActive).toList();
      // Sort by date (latest first)
      historyOrders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
      return dartz.Right(historyOrders);
    } catch (e) {
      return dartz.Left(ServerFailure(message: 'Failed to load order history: ${e.toString()}'));
    }
  }
}
