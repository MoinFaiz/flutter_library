import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_request.dart';
import 'package:flutter_library/features/cart/domain/repositories/cart_repository.dart';

class GetReceivedRequestsUseCase {
  final CartRepository repository;

  GetReceivedRequestsUseCase({required this.repository});

  Future<Either<Failure, List<CartRequest>>> call() async {
    return await repository.getReceivedRequests();
  }
}
