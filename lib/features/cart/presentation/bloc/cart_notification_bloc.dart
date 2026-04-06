import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_library/core/presentation/base_bloc.dart';
import 'package:flutter_library/features/cart/domain/usecases/get_cart_notifications_usecase.dart';
import 'package:flutter_library/features/cart/domain/usecases/get_unread_notifications_count_usecase.dart';
import 'package:flutter_library/features/cart/domain/usecases/mark_notification_as_read_usecase.dart';
import 'cart_notification_event.dart';
import 'cart_notification_state.dart';

class CartNotificationBloc extends Bloc<CartNotificationEvent, CartNotificationState>
    with BlocResultHandler<CartNotificationState> {
  final GetCartNotificationsUseCase getCartNotificationsUseCase;
  final GetUnreadNotificationsCountUseCase getUnreadNotificationsCountUseCase;
  final MarkNotificationAsReadUseCase markNotificationAsReadUseCase;

  CartNotificationBloc({
    required this.getCartNotificationsUseCase,
    required this.getUnreadNotificationsCountUseCase,
    required this.markNotificationAsReadUseCase,
  }) : super(CartNotificationInitial()) {
    on<LoadCartNotifications>(_onLoadCartNotifications);
    on<MarkCartNotificationAsRead>(_onMarkCartNotificationAsRead);
    on<RefreshCartNotifications>(_onRefreshCartNotifications);
  }

  Future<void> _onLoadCartNotifications(
    LoadCartNotifications event,
    Emitter<CartNotificationState> emit,
  ) async {
    emit(CartNotificationLoading());

    final notificationsResult = await getCartNotificationsUseCase();
    final unreadCountResult = await getUnreadNotificationsCountUseCase();

    notificationsResult.fold(
      (failure) => emit(CartNotificationError(failure.message)),
      (notifications) {
        final unreadCount = unreadCountResult.fold(
          (_) => 0,
          (count) => count,
        );

        emit(CartNotificationLoaded(
          notifications: notifications,
          unreadCount: unreadCount,
        ));
      },
    );
  }

  Future<void> _onMarkCartNotificationAsRead(
    MarkCartNotificationAsRead event,
    Emitter<CartNotificationState> emit,
  ) async {
    final currentState = state;
    if (currentState is CartNotificationLoaded) {
      final result = await markNotificationAsReadUseCase(event.notificationId);

      result.fold(
        (failure) {
          emit(CartNotificationError(failure.message));
          emit(currentState); // Return to previous state
        },
        (_) {
          // Update the notification in the list
          final updatedNotifications = currentState.notifications.map((notification) {
            if (notification.id == event.notificationId) {
              return notification.copyWith(isRead: true);
            }
            return notification;
          }).toList();

          final newUnreadCount = currentState.unreadCount > 0
              ? currentState.unreadCount - 1
              : 0;

          emit(CartNotificationLoaded(
            notifications: updatedNotifications,
            unreadCount: newUnreadCount,
          ));
        },
      );
    }
  }

  Future<void> _onRefreshCartNotifications(
    RefreshCartNotifications event,
    Emitter<CartNotificationState> emit,
  ) async {
    add(LoadCartNotifications());
  }
}
