import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_item.dart';
import 'package:flutter_library/features/cart/domain/repositories/cart_repository.dart';

class AddToCartParams {
  final String bookId;
  final CartItemType type;
  final int rentalPeriodInDays;

  AddToCartParams({
    required this.bookId,
    required this.type,
    this.rentalPeriodInDays = 14,
  });
}

class AddToCartUseCase {
  final CartRepository repository;

  AddToCartUseCase({required this.repository});

  Future<Either<Failure, CartItem>> call(AddToCartParams params) async {
    return await repository.addToCart(
      bookId: params.bookId,
      type: params.type,
      rentalPeriodInDays: params.rentalPeriodInDays,
    );
  }
}
