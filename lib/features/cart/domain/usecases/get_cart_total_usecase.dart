import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/cart/domain/repositories/cart_repository.dart';

class GetCartTotalUseCase {
  final CartRepository repository;

  GetCartTotalUseCase({required this.repository});

  Future<Either<Failure, double>> call() async {
    return await repository.getCartTotal();
  }
}
