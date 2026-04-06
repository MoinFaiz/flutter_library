import 'package:equatable/equatable.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_item.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class LoadCartItems extends CartEvent {}

class AddItemToCart extends CartEvent {
  final String bookId;
  final CartItemType type;
  final int rentalPeriodInDays;

  const AddItemToCart({
    required this.bookId,
    required this.type,
    this.rentalPeriodInDays = 14,
  });

  @override
  List<Object?> get props => [bookId, type, rentalPeriodInDays];
}

class RemoveItemFromCart extends CartEvent {
  final String cartItemId;

  const RemoveItemFromCart(this.cartItemId);

  @override
  List<Object?> get props => [cartItemId];
}

class SendRentalRequest extends CartEvent {
  final String bookId;
  final int rentalPeriodInDays;

  const SendRentalRequest({
    required this.bookId,
    this.rentalPeriodInDays = 14,
  });

  @override
  List<Object?> get props => [bookId, rentalPeriodInDays];
}

class SendPurchaseRequest extends CartEvent {
  final String bookId;

  const SendPurchaseRequest(this.bookId);

  @override
  List<Object?> get props => [bookId];
}

class AcceptBookRequest extends CartEvent {
  final String requestId;

  const AcceptBookRequest(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

class RejectBookRequest extends CartEvent {
  final String requestId;

  const RejectBookRequest(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

class LoadReceivedRequests extends CartEvent {}

class RefreshCart extends CartEvent {}

class ClearCart extends CartEvent {}
