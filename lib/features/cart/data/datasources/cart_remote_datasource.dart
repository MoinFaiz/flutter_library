import 'package:flutter_library/features/cart/data/models/cart_item_model.dart';
import 'package:flutter_library/features/cart/data/models/cart_request_model.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_item.dart';

abstract class CartRemoteDataSource {
  Future<List<CartItemModel>> getCartItems();
  Future<CartItemModel> addToCart({
    required String bookId,
    required CartItemType type,
    int rentalPeriodInDays = 14,
  });
  Future<void> removeFromCart(String cartItemId);
  Future<CartRequestModel> sendRentalRequest({
    required String bookId,
    required int rentalPeriodInDays,
  });
  Future<CartRequestModel> sendPurchaseRequest({
    required String bookId,
  });
  Future<List<CartRequestModel>> getMyRequests();
  Future<List<CartRequestModel>> getReceivedRequests();
  Future<void> acceptRequest(String requestId);
  Future<void> rejectRequest(String requestId, {String? reason});
  Future<void> cancelRequest(String requestId);
  Future<void> clearCart();
  Future<double> getCartTotal();
}
