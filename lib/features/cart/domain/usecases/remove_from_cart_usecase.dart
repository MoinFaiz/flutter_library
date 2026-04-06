import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/cart/domain/repositories/cart_repository.dart';

class RemoveFromCartUseCase {
  final CartRepository repository;

  RemoveFromCartUseCase({required this.repository});

  Future<Either<Failure, void>> call(String cartItemId) async {
    return await repository.removeFromCart(cartItemId);
  }
}
