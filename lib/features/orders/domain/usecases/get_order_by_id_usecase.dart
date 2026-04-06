import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/orders/domain/entities/order.dart';
import 'package:flutter_library/features/orders/domain/repositories/order_repository.dart';

/// Use case for getting a specific order by ID
class GetOrderByIdUseCase {
  final OrderRepository repository;

  GetOrderByIdUseCase({required this.repository});

  Future<dartz.Either<Failure, Order>> call(String orderId) async {
    return await repository.getOrderById(orderId);
  }
}
