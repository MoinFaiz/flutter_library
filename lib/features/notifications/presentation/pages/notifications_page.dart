import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_library/core/constants/app_constants.dart';
import 'package:flutter_library/core/navigation/app_routes.dart';
import 'package:flutter_library/core/navigation/navigation_service.dart';
import 'package:flutter_library/features/cart/presentation/widgets/cart_icon_button_with_badge.dart';
import 'package:flutter_library/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:flutter_library/features/notifications/presentation/bloc/notifications_event.dart';
import 'package:flutter_library/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:flutter_library/features/notifications/presentation/widgets/notification_card.dart';
import 'package:flutter_library/shared/widgets/app_button.dart';
import 'package:flutter_library/core/theme/app_colors.dart';
import 'package:flutter_library/core/theme/app_dimensions.dart';
import 'package:flutter_library/injection/injection_container.dart';

/// Notifications page showing all user notifications
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NavigationService _navigationService = sl<NavigationService>();

  void _navigateToFavorites() {
    _navigationService.navigateTo(AppRoutes.favorites);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotificationsBloc, NotificationsState>(
      listener: (context, state) {
        if (state is NotificationActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state is NotificationActionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final hasUnread = state is NotificationsLoaded && 
            state.notifications.any((n) => !n.isRead);

        return Scaffold(
          appBar: AppBar(
            actions: [
              if (hasUnread)
                IconButton(
                  icon: const Icon(Icons.mark_email_read),
                  onPressed: () {
                    context.read<NotificationsBloc>().add(
                      const MarkAllNotificationsAsRead(),
                    );
                  },
                  tooltip: 'Mark all as read',
                ),
              IconButton(
                icon: const Icon(Icons.favorite_outline),
                onPressed: _navigateToFavorites,
                tooltip: 'Favorites',
              ),
              const CartIconButtonWithBadge(),
            ],
            elevation: AppDimensions.elevationXs,
            shadowColor: Theme.of(context).shadowColor,
            toolbarHeight: AppDimensions.appBarHeight
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }



  Widget _buildBody(BuildContext context, NotificationsState state) {
    if (state is NotificationsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is NotificationsError) {
      return _buildErrorState(context, state.message);
    }

    if (state is NotificationsLoaded) {
      if (state.notifications.isEmpty) {
        return _buildEmptyState(context);
      }

      return _buildNotificationsList(context, state);
    }

    return _buildEmptyState(context);
  }

  Widget _buildNotificationsList(BuildContext context, NotificationsLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<NotificationsBloc>().add(const RefreshNotifications());
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        itemCount: state.notifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: AppConstants.smallPadding),
        itemBuilder: (context, index) {
          final notification = state.notifications[index];
          return NotificationCard(
            notification: notification,
            onMarkAsRead: () {
              context.read<NotificationsBloc>().add(
                MarkNotificationAsRead(notificationId: notification.id),
              );
            },
            onDelete: () {
              _showDeleteConfirmation(context, notification.id);
            },
            onAcceptBookRequest: (notificationId, reason) {
              context.read<NotificationsBloc>().add(
                AcceptBookRequest(notificationId: notificationId),
              );
            },
            onRejectBookRequest: (notificationId, reason) {
              context.read<NotificationsBloc>().add(
                RejectBookRequest(notificationId: notificationId, reason: reason),
              );
            },
            onAcceptCartRequest: (notificationId, reason) {
              context.read<NotificationsBloc>().add(
                AcceptCartRequest(notificationId: notificationId),
              );
            },
            onRejectCartRequest: (notificationId, reason) {
              context.read<NotificationsBloc>().add(
                RejectCartRequest(notificationId: notificationId, reason: reason),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: AppDimensions.icon3Xl,
            color: Theme.of(context).colorScheme.outline,
          ),
          SizedBox(height: AppDimensions.spaceMd),
          Text(
            'No Notifications',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: AppDimensions.spaceSm),
          Text(
            'You\'re all caught up! No new notifications.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: AppDimensions.icon3Xl,
            color: Theme.of(context).colorScheme.error,
          ),
          SizedBox(height: AppDimensions.spaceMd),
          Text(
            'Error',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: AppDimensions.spaceSm),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppDimensions.spaceMd),
          AppButton.primary(
            text: 'Retry',
            onPressed: () {
              context.read<NotificationsBloc>().add(const LoadNotifications());
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String notificationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notification'),
        content: const Text('Are you sure you want to delete this notification?'),
        actions: [
          AppButton.text(
            text: 'Cancel',
            onPressed: () => Navigator.of(context).pop(),
          ),
          AppButton.destructive(
            text: 'Delete',
            onPressed: () {
              Navigator.of(context).pop();
              context.read<NotificationsBloc>().add(
                DeleteNotification(notificationId: notificationId),
              );
            },
          ),
        ],
      ),
    );
  }
}
