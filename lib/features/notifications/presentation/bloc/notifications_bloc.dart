import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_library/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:flutter_library/features/notifications/domain/usecases/get_unread_count_usecase.dart';
import 'package:flutter_library/features/notifications/domain/usecases/mark_notification_as_read_usecase.dart';
import 'package:flutter_library/features/notifications/domain/usecases/mark_all_notifications_as_read_usecase.dart';
import 'package:flutter_library/features/notifications/domain/usecases/delete_notification_usecase.dart';
import 'package:flutter_library/features/notifications/domain/usecases/watch_notifications_usecase.dart';
import 'package:flutter_library/features/notifications/domain/usecases/accept_book_request_usecase.dart';
import 'package:flutter_library/features/notifications/domain/usecases/reject_book_request_usecase.dart';
import 'package:flutter_library/features/cart/domain/usecases/accept_cart_request_usecase.dart';
import 'package:flutter_library/features/cart/domain/usecases/reject_cart_request_usecase.dart';
import 'package:flutter_library/features/notifications/presentation/bloc/notifications_event.dart';
import 'package:flutter_library/features/notifications/presentation/bloc/notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final GetUnreadCountUseCase getUnreadCountUseCase;
  final MarkNotificationAsReadUseCase markNotificationAsReadUseCase;
  final MarkAllNotificationsAsReadUseCase markAllNotificationsAsReadUseCase;
  final DeleteNotificationUseCase deleteNotificationUseCase;
  final WatchNotificationsUseCase watchNotificationsUseCase;
  final AcceptBookRequestUseCase acceptBookRequestUseCase;
  final RejectBookRequestUseCase rejectBookRequestUseCase;
  final AcceptCartRequestUseCase acceptCartRequestUseCase;
  final RejectCartRequestUseCase rejectCartRequestUseCase;

  StreamSubscription? _notificationsSubscription;

  NotificationsBloc({
    required this.getNotificationsUseCase,
    required this.getUnreadCountUseCase,
    required this.markNotificationAsReadUseCase,
    required this.markAllNotificationsAsReadUseCase,
    required this.deleteNotificationUseCase,
    required this.watchNotificationsUseCase,
    required this.acceptBookRequestUseCase,
    required this.rejectBookRequestUseCase,
    required this.acceptCartRequestUseCase,
    required this.rejectCartRequestUseCase,
  }) : super(const NotificationsInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<RefreshNotifications>(_onRefreshNotifications);
    on<MarkNotificationAsRead>(_onMarkNotificationAsRead);
    on<MarkAllNotificationsAsRead>(_onMarkAllNotificationsAsRead);
    on<DeleteNotification>(_onDeleteNotification);
    on<AcceptBookRequest>(_onAcceptBookRequest);
    on<RejectBookRequest>(_onRejectBookRequest);
    on<AcceptCartRequest>(_onAcceptCartRequest);
    on<RejectCartRequest>(_onRejectCartRequest);
    on<LoadUnreadCount>(_onLoadUnreadCount);

    // Listen to real-time updates
    _notificationsSubscription = watchNotificationsUseCase().listen(
      (notifications) {
        if (state is NotificationsLoaded) {
          add(LoadNotifications()); // Reload to get latest state
        }
      },
    );
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(const NotificationsLoading());

    final notificationsResult = await getNotificationsUseCase();
    final unreadCountResult = await getUnreadCountUseCase();

    await notificationsResult.fold(
      (failure) async {
        emit(NotificationsError(message: failure.message));
      },
      (notifications) async {
        final unreadCount = unreadCountResult.fold(
          (failure) => 0,
          (count) => count,
        );
        emit(NotificationsLoaded(
          notifications: notifications,
          unreadCount: unreadCount,
        ));
      },
    );
  }

  Future<void> _onRefreshNotifications(
    RefreshNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    final notificationsResult = await getNotificationsUseCase();
    final unreadCountResult = await getUnreadCountUseCase();

    await notificationsResult.fold(
      (failure) async {
        if (state is NotificationsLoaded) {
          final currentState = state as NotificationsLoaded;
          emit(NotificationActionError(
            notifications: currentState.notifications,
            unreadCount: currentState.unreadCount,
            message: failure.message,
          ));
        }
      },
      (notifications) async {
        final unreadCount = unreadCountResult.fold(
          (failure) => 0,
          (count) => count,
        );
        emit(NotificationsLoaded(
          notifications: notifications,
          unreadCount: unreadCount,
        ));
      },
    );
  }

  Future<void> _onMarkNotificationAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    if (state is! NotificationsLoaded) return;

    final currentState = state as NotificationsLoaded;
    emit(NotificationActionLoading(
      notifications: currentState.notifications,
      unreadCount: currentState.unreadCount,
      actionId: event.notificationId,
    ));

    final result = await markNotificationAsReadUseCase(event.notificationId);

    await result.fold(
      (failure) async {
        emit(NotificationActionError(
          notifications: currentState.notifications,
          unreadCount: currentState.unreadCount,
          message: failure.message,
        ));
      },
      (_) async {
        // Update local state
        final updatedNotifications = currentState.notifications.map((notification) {
          if (notification.id == event.notificationId) {
            return notification.copyWith(isRead: true);
          }
          return notification;
        }).toList();

        final newUnreadCount = updatedNotifications.where((n) => !n.isRead).length;

        emit(NotificationsLoaded(
          notifications: updatedNotifications,
          unreadCount: newUnreadCount,
        ));
      },
    );
  }

  Future<void> _onMarkAllNotificationsAsRead(
    MarkAllNotificationsAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    if (state is! NotificationsLoaded) return;

    final currentState = state as NotificationsLoaded;
    
    final result = await markAllNotificationsAsReadUseCase();

    await result.fold(
      (failure) async {
        emit(NotificationActionError(
          notifications: currentState.notifications,
          unreadCount: currentState.unreadCount,
          message: failure.message,
        ));
      },
      (_) async {
        final updatedNotifications = currentState.notifications.map((notification) {
          return notification.copyWith(isRead: true);
        }).toList();

        emit(NotificationsLoaded(
          notifications: updatedNotifications,
          unreadCount: 0,
        ));
      },
    );
  }

  Future<void> _onDeleteNotification(
    DeleteNotification event,
    Emitter<NotificationsState> emit,
  ) async {
    if (state is! NotificationsLoaded) return;

    final currentState = state as NotificationsLoaded;
    
    final result = await deleteNotificationUseCase(event.notificationId);

    await result.fold(
      (failure) async {
        emit(NotificationActionError(
          notifications: currentState.notifications,
          unreadCount: currentState.unreadCount,
          message: failure.message,
        ));
      },
      (_) async {
        final updatedNotifications = currentState.notifications
            .where((notification) => notification.id != event.notificationId)
            .toList();

        final newUnreadCount = updatedNotifications.where((n) => !n.isRead).length;

        emit(NotificationActionSuccess(
          notifications: updatedNotifications,
          unreadCount: newUnreadCount,
          message: 'Notification deleted successfully',
        ));
      },
    );
  }

  Future<void> _onAcceptBookRequest(
    AcceptBookRequest event,
    Emitter<NotificationsState> emit,
  ) async {
    if (state is! NotificationsLoaded) return;

    final currentState = state as NotificationsLoaded;
    emit(NotificationActionLoading(
      notifications: currentState.notifications,
      unreadCount: currentState.unreadCount,
      actionId: event.notificationId,
    ));

    final result = await acceptBookRequestUseCase(event.notificationId);

    await result.fold(
      (failure) async {
        emit(NotificationActionError(
          notifications: currentState.notifications,
          unreadCount: currentState.unreadCount,
          message: failure.message,
        ));
      },
      (_) async {
        emit(NotificationActionSuccess(
          notifications: currentState.notifications,
          unreadCount: currentState.unreadCount,
          message: 'Book request accepted successfully',
        ));
      },
    );
  }

  Future<void> _onRejectBookRequest(
    RejectBookRequest event,
    Emitter<NotificationsState> emit,
  ) async {
    if (state is! NotificationsLoaded) return;

    final currentState = state as NotificationsLoaded;
    emit(NotificationActionLoading(
      notifications: currentState.notifications,
      unreadCount: currentState.unreadCount,
      actionId: event.notificationId,
    ));

    final result = await rejectBookRequestUseCase(event.notificationId, event.reason);

    await result.fold(
      (failure) async {
        emit(NotificationActionError(
          notifications: currentState.notifications,
          unreadCount: currentState.unreadCount,
          message: failure.message,
        ));
      },
      (_) async {
        emit(NotificationActionSuccess(
          notifications: currentState.notifications,
          unreadCount: currentState.unreadCount,
          message: 'Book request rejected successfully',
        ));
      },
    );
  }

  Future<void> _onAcceptCartRequest(
    AcceptCartRequest event,
    Emitter<NotificationsState> emit,
  ) async {
    if (state is! NotificationsLoaded) return;

    final currentState = state as NotificationsLoaded;
    emit(NotificationActionLoading(
      notifications: currentState.notifications,
      unreadCount: currentState.unreadCount,
      actionId: event.notificationId,
    ));

    final result = await acceptCartRequestUseCase(event.notificationId);

    await result.fold(
      (failure) async {
        emit(NotificationActionError(
          notifications: currentState.notifications,
          unreadCount: currentState.unreadCount,
          message: failure.message,
        ));
      },
      (_) async {
        emit(NotificationActionSuccess(
          notifications: currentState.notifications,
          unreadCount: currentState.unreadCount,
          message: 'Cart request accepted successfully',
        ));
      },
    );
  }

  Future<void> _onRejectCartRequest(
    RejectCartRequest event,
    Emitter<NotificationsState> emit,
  ) async {
    if (state is! NotificationsLoaded) return;

    final currentState = state as NotificationsLoaded;
    emit(NotificationActionLoading(
      notifications: currentState.notifications,
      unreadCount: currentState.unreadCount,
      actionId: event.notificationId,
    ));

    final result = await rejectCartRequestUseCase(event.notificationId, reason: event.reason);

    await result.fold(
      (failure) async {
        emit(NotificationActionError(
          notifications: currentState.notifications,
          unreadCount: currentState.unreadCount,
          message: failure.message,
        ));
      },
      (_) async {
        emit(NotificationActionSuccess(
          notifications: currentState.notifications,
          unreadCount: currentState.unreadCount,
          message: 'Cart request rejected successfully',
        ));
      },
    );
  }

  Future<void> _onLoadUnreadCount(
    LoadUnreadCount event,
    Emitter<NotificationsState> emit,
  ) async {
    final result = await getUnreadCountUseCase();

    result.fold(
      (failure) {
        // Ignore error for unread count
      },
      (count) {
        if (state is NotificationsLoaded) {
          final currentState = state as NotificationsLoaded;
          emit(currentState.copyWith(unreadCount: count));
        }
      },
    );
  }

  @override
  Future<void> close() {
    _notificationsSubscription?.cancel();
    return super.close();
  }
}
