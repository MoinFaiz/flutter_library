import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_library/features/orders/domain/usecases/cancel_order_usecase.dart';
import 'package:flutter_library/features/orders/domain/usecases/get_active_orders_usecase.dart';
import 'package:flutter_library/features/orders/domain/usecases/get_order_history_usecase.dart';
import 'package:flutter_library/features/orders/domain/usecases/get_user_orders_usecase.dart';
import 'package:flutter_library/features/orders/presentation/bloc/orders_event.dart';
import 'package:flutter_library/features/orders/presentation/bloc/orders_state.dart';

/// BLoC for managing orders state
class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final GetUserOrdersUseCase getUserOrdersUseCase;
  final GetActiveOrdersUseCase getActiveOrdersUseCase;
  final GetOrderHistoryUseCase getOrderHistoryUseCase;
  final CancelOrderUseCase cancelOrderUseCase;

  OrdersBloc({
    required this.getUserOrdersUseCase,
    required this.getActiveOrdersUseCase,
    required this.getOrderHistoryUseCase,
    required this.cancelOrderUseCase,
  }) : super(const OrdersInitial()) {
    on<LoadUserOrders>(_onLoadUserOrders);
    on<RefreshOrders>(_onRefreshOrders);
    on<LoadActiveOrders>(_onLoadActiveOrders);
    on<LoadOrderHistory>(_onLoadOrderHistory);
    on<CancelOrder>(_onCancelOrder);
  }

  Future<void> _onLoadUserOrders(
    LoadUserOrders event,
    Emitter<OrdersState> emit,
  ) async {
    emit(const OrdersLoading());
    
    final result = await getUserOrdersUseCase();
    
    result.fold(
      (failure) => emit(OrdersError(failure.message)),
      (orders) {
        final activeOrders = orders.where((order) => order.isActive).toList();
        final orderHistory = orders.where((order) => !order.isActive).toList();
        
        emit(OrdersLoaded(
          orders: orders,
          activeOrders: activeOrders,
          orderHistory: orderHistory,
        ));
      },
    );
  }

  Future<void> _onRefreshOrders(
    RefreshOrders event,
    Emitter<OrdersState> emit,
  ) async {
    // Don't show loading state for refresh, just reload data
    final result = await getUserOrdersUseCase();
    
    result.fold(
      (failure) => emit(OrdersError(failure.message)),
      (orders) {
        final activeOrders = orders.where((order) => order.isActive).toList();
        final orderHistory = orders.where((order) => !order.isActive).toList();
        
        emit(OrdersLoaded(
          orders: orders,
          activeOrders: activeOrders,
          orderHistory: orderHistory,
        ));
      },
    );
  }

  Future<void> _onLoadActiveOrders(
    LoadActiveOrders event,
    Emitter<OrdersState> emit,
  ) async {
    emit(const OrdersLoading());
    
    final result = await getActiveOrdersUseCase();
    
    result.fold(
      (failure) => emit(OrdersError(failure.message)),
      (activeOrders) {
        emit(OrdersLoaded(
          orders: activeOrders,
          activeOrders: activeOrders,
          orderHistory: const [],
        ));
      },
    );
  }

  Future<void> _onLoadOrderHistory(
    LoadOrderHistory event,
    Emitter<OrdersState> emit,
  ) async {
    emit(const OrdersLoading());
    
    final result = await getOrderHistoryUseCase();
    
    result.fold(
      (failure) => emit(OrdersError(failure.message)),
      (orderHistory) {
        emit(OrdersLoaded(
          orders: orderHistory,
          activeOrders: const [],
          orderHistory: orderHistory,
        ));
      },
    );
  }

  Future<void> _onCancelOrder(
    CancelOrder event,
    Emitter<OrdersState> emit,
  ) async {
    final result = await cancelOrderUseCase(event.orderId);
    
    result.fold(
      (failure) => emit(OrdersError(failure.message)),
      (_) {
        emit(OrderCancelled(event.orderId));
        // Reload orders after cancellation
        add(const LoadUserOrders());
      },
    );
  }
}
