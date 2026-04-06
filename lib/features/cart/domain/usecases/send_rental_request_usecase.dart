import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_request.dart';
import 'package:flutter_library/features/cart/domain/repositories/cart_repository.dart';

class SendRentalRequestParams {
  final String bookId;
  final int rentalPeriodInDays;

  SendRentalRequestParams({
    required this.bookId,
    this.rentalPeriodInDays = 14,
  });
}

class SendRentalRequestUseCase {
  final CartRepository repository;

  SendRentalRequestUseCase({required this.repository});

  Future<Either<Failure, CartRequest>> call(SendRentalRequestParams params) async {
    return await repository.sendRentalRequest(
      bookId: params.bookId,
      rentalPeriodInDays: params.rentalPeriodInDays,
    );
  }
}
