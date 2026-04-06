import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/cart/domain/repositories/cart_repository.dart';

/// Use case for rejecting a cart request (rental or purchase)
class RejectCartRequestUseCase {
  final CartRepository repository;

  RejectCartRequestUseCase(this.repository);

  Future<Either<Failure, void>> call(String requestId, {String? reason}) async {
    return await repository.rejectRequest(requestId, reason: reason);
  }
}
