import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/orders/domain/entities/order.dart';
import 'package:flutter_library/features/orders/domain/repositories/order_repository.dart';

/// Use case for updating order status
class UpdateOrderStatusUseCase {
  final OrderRepository repository;

  UpdateOrderStatusUseCase({required this.repository});

  Future<dartz.Either<Failure, Order>> call({
    required String orderId,
    required OrderStatus status,
  }) async {
    return await repository.updateOrderStatus(
      orderId: orderId,
      status: status,
    );
  }
}
