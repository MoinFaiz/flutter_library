import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_request.dart';
import 'package:flutter_library/features/cart/domain/repositories/cart_repository.dart';

class SendPurchaseRequestUseCase {
  final CartRepository repository;

  SendPurchaseRequestUseCase({required this.repository});

  Future<Either<Failure, CartRequest>> call(String bookId) async {
    return await repository.sendPurchaseRequest(bookId: bookId);
  }
}
