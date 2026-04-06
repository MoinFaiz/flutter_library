import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/cart/domain/repositories/cart_repository.dart';

/// Use case for accepting a cart request (rental or purchase)
class AcceptCartRequestUseCase {
  final CartRepository repository;

  AcceptCartRequestUseCase(this.repository);

  Future<Either<Failure, void>> call(String requestId) async {
    return await repository.acceptRequest(requestId);
  }
}
