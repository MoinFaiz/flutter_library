import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/cart/domain/repositories/cart_repository.dart';

class AcceptRequestUseCase {
  final CartRepository repository;

  AcceptRequestUseCase({required this.repository});

  Future<Either<Failure, void>> call(String requestId) async {
    return await repository.acceptRequest(requestId);
  }
}
