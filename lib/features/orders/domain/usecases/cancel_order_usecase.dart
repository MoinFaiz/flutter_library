import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/orders/domain/repositories/order_repository.dart';

/// Use case for cancelling an order
class CancelOrderUseCase {
  final OrderRepository repository;

  CancelOrderUseCase({required this.repository});

  Future<dartz.Either<Failure, void>> call(String orderId) async {
    return await repository.cancelOrder(orderId);
  }
}
