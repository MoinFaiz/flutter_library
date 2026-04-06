import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/orders/domain/entities/order.dart';
import 'package:flutter_library/features/orders/domain/repositories/order_repository.dart';

/// Use case for getting user orders
class GetUserOrdersUseCase {
  final OrderRepository repository;

  GetUserOrdersUseCase({required this.repository});

  Future<dartz.Either<Failure, List<Order>>> call() async {
    return await repository.getUserOrders();
  }
}
