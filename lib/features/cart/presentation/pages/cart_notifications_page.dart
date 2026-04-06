import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_library/core/theme/app_dimensions.dart';
import 'package:flutter_library/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:flutter_library/features/cart/presentation/bloc/cart_event.dart';
import 'package:flutter_library/features/cart/presentation/bloc/cart_state.dart';
import 'package:flutter_library/features/cart/presentation/bloc/cart_notification_bloc.dart';
import 'package:flutter_library/features/cart/presentation/bloc/cart_notification_event.dart';
import 'package:flutter_library/features/cart/presentation/bloc/cart_notification_state.dart';
import 'package:flutter_library/features/cart/presentation/widgets/cart_notification_card.dart';
import 'package:flutter_library/injection/injection_container.dart';

class CartNotificationsPage extends StatelessWidget {
  const CartNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CartNotificationBloc>()..add(LoadCartNotifications()),
      child: const CartNotificationsView(),
    );
  }
}

class CartNotificationsView extends StatelessWidget {
  const CartNotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<CartNotificationBloc>().add(RefreshCartNotifications());
            },
          ),
        ],
      ),
      body: BlocBuilder<CartNotificationBloc, CartNotificationState>(
        builder: (context, state) {
          if (state is CartNotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CartNotificationError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  SizedBox(height: AppDimensions.spaceMd),
                  Text(
                    'Error loading notifications',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: AppDimensions.spaceSm),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  SizedBox(height: AppDimensions.spaceMd),
                  ElevatedButton(
                    onPressed: () {
                      context.read<CartNotificationBloc>().add(LoadCartNotifications());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is CartNotificationLoaded) {
            if (state.notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 80,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    SizedBox(height: AppDimensions.spaceMd),
                    Text(
                      'No notifications',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: AppDimensions.spaceSm),
                    Text(
                      'You\'ll see notifications here',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<CartNotificationBloc>().add(RefreshCartNotifications());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.notifications.length,
                itemBuilder: (context, index) {
                  final notification = state.notifications[index];
                  return CartNotificationCard(
                    notification: notification,
                    onTap: () {
                      if (!notification.isRead) {
                        context.read<CartNotificationBloc>().add(
                              MarkCartNotificationAsRead(notification.id),
                            );
                      }
                    },
                    onAccept: notification.requiresAction
                        ? () {
                            final cartBloc = context.read<CartBloc>();
                            if (cartBloc.state is! CartLoaded) {
                              cartBloc.add(LoadCartItems());
                            }
                            context.read<CartBloc>().add(
                                  AcceptBookRequest(notification.requestId),
                                );
                            context.read<CartNotificationBloc>().add(
                                  RefreshCartNotifications(),
                                );
                          }
                        : null,
                    onReject: notification.requiresAction
                        ? () {
                            final cartBloc = context.read<CartBloc>();
                            if (cartBloc.state is! CartLoaded) {
                              cartBloc.add(LoadCartItems());
                            }
                            context.read<CartBloc>().add(
                                  RejectBookRequest(notification.requestId),
                                );
                            context.read<CartNotificationBloc>().add(
                                  RefreshCartNotifications(),
                                );
                          }
                        : null,
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
