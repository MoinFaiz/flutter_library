import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/orders/domain/entities/order.dart';
import 'package:flutter_library/features/orders/domain/repositories/order_repository.dart';

/// Use case for creating a new order
class CreateOrderUseCase {
  final OrderRepository repository;

  CreateOrderUseCase({required this.repository});

  Future<dartz.Either<Failure, Order>> call({
    required String bookId,
    required OrderType type,
    required double price,
  }) async {
    return await repository.createOrder(
      bookId: bookId,
      type: type,
      price: price,
    );
  }
}
