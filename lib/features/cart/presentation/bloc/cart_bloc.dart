import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_library/core/presentation/base_bloc.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_request.dart';
import 'package:flutter_library/features/cart/domain/usecases/accept_request_usecase.dart';
import 'package:flutter_library/features/cart/domain/usecases/add_to_cart_usecase.dart';
import 'package:flutter_library/features/cart/domain/usecases/get_cart_items_usecase.dart';
import 'package:flutter_library/features/cart/domain/usecases/get_cart_total_usecase.dart';
import 'package:flutter_library/features/cart/domain/usecases/get_received_requests_usecase.dart';
import 'package:flutter_library/features/cart/domain/usecases/reject_request_usecase.dart';
import 'package:flutter_library/features/cart/domain/usecases/remove_from_cart_usecase.dart';
import 'package:flutter_library/features/cart/domain/usecases/send_purchase_request_usecase.dart';
import 'package:flutter_library/features/cart/domain/usecases/send_rental_request_usecase.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> with BlocResultHandler<CartState> {
  final GetCartItemsUseCase getCartItemsUseCase;
  final AddToCartUseCase addToCartUseCase;
  final RemoveFromCartUseCase removeFromCartUseCase;
  final SendRentalRequestUseCase sendRentalRequestUseCase;
  final SendPurchaseRequestUseCase sendPurchaseRequestUseCase;
  final GetReceivedRequestsUseCase getReceivedRequestsUseCase;
  final AcceptRequestUseCase acceptRequestUseCase;
  final RejectRequestUseCase rejectRequestUseCase;
  final GetCartTotalUseCase getCartTotalUseCase;

  CartBloc({
    required this.getCartItemsUseCase,
    required this.addToCartUseCase,
    required this.removeFromCartUseCase,
    required this.sendRentalRequestUseCase,
    required this.sendPurchaseRequestUseCase,
    required this.getReceivedRequestsUseCase,
    required this.acceptRequestUseCase,
    required this.rejectRequestUseCase,
    required this.getCartTotalUseCase,
  }) : super(CartInitial()) {
    on<LoadCartItems>(_onLoadCartItems);
    on<AddItemToCart>(_onAddItemToCart);
    on<RemoveItemFromCart>(_onRemoveItemFromCart);
    on<SendRentalRequest>(_onSendRentalRequest);
    on<SendPurchaseRequest>(_onSendPurchaseRequest);
    on<AcceptBookRequest>(_onAcceptBookRequest);
    on<RejectBookRequest>(_onRejectBookRequest);
    on<LoadReceivedRequests>(_onLoadReceivedRequests);
    on<RefreshCart>(_onRefreshCart);
  }

  Future<void> _onLoadCartItems(LoadCartItems event, Emitter<CartState> emit) async {
    emit(CartLoading());

    final itemsResult = await getCartItemsUseCase();
    final totalResult = await getCartTotalUseCase();
    final requestsResult = await getReceivedRequestsUseCase();

    itemsResult.fold(
      (failure) => emit(CartError(failure.message)),
      (items) {
        final total = totalResult.fold(
          (_) => 0.0,
          (t) => t,
        );
        final requests = requestsResult.fold(
          (_) => <CartRequest>[],
          (r) => r,
        );

        emit(CartLoaded(
          items: items,
          total: total,
          receivedRequests: requests,
        ));
      },
    );
  }

  Future<void> _onAddItemToCart(AddItemToCart event, Emitter<CartState> emit) async {
    final currentState = state;
    if (currentState is CartLoaded) {
      emit(currentState.copyWithState(isProcessing: true));

      final result = await addToCartUseCase(AddToCartParams(
        bookId: event.bookId,
        type: event.type,
        rentalPeriodInDays: event.rentalPeriodInDays,
      ));

      result.fold(
        (failure) {
          emit(currentState.copyWithState(isProcessing: false));
          emit(CartError(failure.message));
          emit(currentState); // Return to previous state
        },
        (cartItem) {
          add(LoadCartItems()); // Reload to get updated total
        },
      );
    }
  }

  Future<void> _onRemoveItemFromCart(RemoveItemFromCart event, Emitter<CartState> emit) async {
    final currentState = state;
    if (currentState is CartLoaded) {
      emit(currentState.copyWithState(isProcessing: true));

      final result = await removeFromCartUseCase(event.cartItemId);

      result.fold(
        (failure) {
          emit(currentState.copyWithState(isProcessing: false));
          emit(CartError(failure.message));
          emit(currentState);
        },
        (_) {
          add(LoadCartItems()); // Reload cart
        },
      );
    }
  }

  Future<void> _onSendRentalRequest(SendRentalRequest event, Emitter<CartState> emit) async {
    final currentState = state;
    if (currentState is CartLoaded) {
      emit(currentState.copyWithState(isProcessing: true));

      final result = await sendRentalRequestUseCase(SendRentalRequestParams(
        bookId: event.bookId,
        rentalPeriodInDays: event.rentalPeriodInDays,
      ));

      result.fold(
        (failure) {
          emit(currentState.copyWithState(isProcessing: false));
          emit(CartError(failure.message));
          emit(currentState);
        },
        (request) {
          emit(currentState.copyWithState(isProcessing: false));
          emit(const CartOperationSuccess('Rental request sent successfully'));
          emit(currentState);
        },
      );
    }
  }

  Future<void> _onSendPurchaseRequest(SendPurchaseRequest event, Emitter<CartState> emit) async {
    final currentState = state;
    if (currentState is CartLoaded) {
      emit(currentState.copyWithState(isProcessing: true));

      final result = await sendPurchaseRequestUseCase(event.bookId);

      result.fold(
        (failure) {
          emit(currentState.copyWithState(isProcessing: false));
          emit(CartError(failure.message));
          emit(currentState);
        },
        (request) {
          emit(currentState.copyWithState(isProcessing: false));
          emit(const CartOperationSuccess('Purchase request sent successfully'));
          emit(currentState);
        },
      );
    }
  }

  Future<void> _onAcceptBookRequest(AcceptBookRequest event, Emitter<CartState> emit) async {
    final currentState = state;
    if (currentState is CartLoaded) {
      emit(currentState.copyWithState(isProcessing: true));

      final result = await acceptRequestUseCase(event.requestId);

      result.fold(
        (failure) {
          emit(currentState.copyWithState(isProcessing: false));
          emit(CartError(failure.message));
          emit(currentState);
        },
        (_) {
          emit(currentState.copyWithState(isProcessing: false));
          emit(const CartOperationSuccess('Request accepted successfully'));
          add(LoadReceivedRequests()); // Reload requests
        },
      );
    }
  }

  Future<void> _onRejectBookRequest(RejectBookRequest event, Emitter<CartState> emit) async {
    final currentState = state;
    if (currentState is CartLoaded) {
      emit(currentState.copyWithState(isProcessing: true));

      final result = await rejectRequestUseCase(event.requestId);

      result.fold(
        (failure) {
          emit(currentState.copyWithState(isProcessing: false));
          emit(CartError(failure.message));
          emit(currentState);
        },
        (_) {
          emit(currentState.copyWithState(isProcessing: false));
          emit(const CartOperationSuccess('Request rejected'));
          add(LoadReceivedRequests());
        },
      );
    }
  }

  Future<void> _onLoadReceivedRequests(LoadReceivedRequests event, Emitter<CartState> emit) async {
    final currentState = state;
    if (currentState is CartLoaded) {
      final result = await getReceivedRequestsUseCase();

      result.fold(
        (failure) => emit(CartError(failure.message)),
        (requests) {
          emit(currentState.copyWithState(receivedRequests: requests));
        },
      );
    }
  }

  Future<void> _onRefreshCart(RefreshCart event, Emitter<CartState> emit) async {
    final currentState = state;
    if (currentState is CartLoaded) {
      emit(CartRefreshing(currentState.items));
      add(LoadCartItems());
    } else {
      add(LoadCartItems());
    }
  }
}
