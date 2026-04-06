import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_item.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_request.dart';

abstract class CartRepository {
  /// Get all cart items for the current user
  Future<Either<Failure, List<CartItem>>> getCartItems();

  /// Add a book to cart (rent or purchase)
  Future<Either<Failure, CartItem>> addToCart({
    required String bookId,
    required CartItemType type,
    int rentalPeriodInDays = 14,
  });

  /// Remove a book from cart
  Future<Either<Failure, void>> removeFromCart(String cartItemId);

  /// Send rental request to book owner
  Future<Either<Failure, CartRequest>> sendRentalRequest({
    required String bookId,
    required int rentalPeriodInDays,
  });

  /// Send purchase request to book owner
  Future<Either<Failure, CartRequest>> sendPurchaseRequest({
    required String bookId,
  });

  /// Get all requests made by the current user
  Future<Either<Failure, List<CartRequest>>> getMyRequests();

  /// Get all requests received by the current user (as book owner)
  Future<Either<Failure, List<CartRequest>>> getReceivedRequests();

  /// Accept a book request (as book owner)
  Future<Either<Failure, void>> acceptRequest(String requestId);

  /// Reject a book request (as book owner)
  Future<Either<Failure, void>> rejectRequest(String requestId, {String? reason});

  /// Cancel a request (as requester)
  Future<Either<Failure, void>> cancelRequest(String requestId);

  /// Clear all cart items
  Future<Either<Failure, void>> clearCart();

  /// Get total cart amount
  Future<Either<Failure, double>> getCartTotal();
}
