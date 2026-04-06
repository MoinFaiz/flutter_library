import 'package:flutter_library/core/presentation/base_bloc.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_item.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_request.dart';

abstract class CartState extends BaseState {
  const CartState();
}

class CartInitial extends CartState {
  @override
  List<Object> get props => [];
}

class CartLoading extends BaseLoading implements CartState {
  @override
  List<Object> get props => [];
}

class CartLoaded extends BaseDataState<List<CartItem>> implements CartState {
  final double total;
  final List<CartRequest> receivedRequests;
  final bool isProcessing;

  const CartLoaded({
    required List<CartItem> items,
    this.total = 0.0,
    this.receivedRequests = const [],
    this.isProcessing = false,
  }) : super(items);

  List<CartItem> get items => data;

  @override
  List<Object> get props => [data, total, receivedRequests, isProcessing];

  @override
  CartLoaded copyWith(List<CartItem> newData) {
    return CartLoaded(
      items: newData,
      total: total,
      receivedRequests: receivedRequests,
      isProcessing: isProcessing,
    );
  }

  CartLoaded copyWithState({
    List<CartItem>? items,
    double? total,
    List<CartRequest>? receivedRequests,
    bool? isProcessing,
  }) {
    return CartLoaded(
      items: items ?? this.items,
      total: total ?? this.total,
      receivedRequests: receivedRequests ?? this.receivedRequests,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}

class CartError extends BaseError implements CartState {
  const CartError(super.message);
}

class CartOperationSuccess extends CartState {
  final String message;

  const CartOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class CartRefreshing extends BaseDataState<List<CartItem>> implements CartState {
  const CartRefreshing(super.items);

  @override
  CartRefreshing copyWith(List<CartItem> newData) {
    return CartRefreshing(newData);
  }
}
