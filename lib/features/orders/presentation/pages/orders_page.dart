import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_library/core/constants/app_constants.dart';
import 'package:flutter_library/core/theme/app_dimensions.dart';
import 'package:flutter_library/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:flutter_library/features/orders/presentation/bloc/orders_event.dart';
import 'package:flutter_library/features/orders/presentation/bloc/orders_state.dart';
import 'package:flutter_library/features/orders/presentation/widgets/order_card.dart';
import 'package:flutter_library/injection/injection_container.dart';

/// Orders page showing user's order history
class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<OrdersBloc>()..add(const LoadUserOrders()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Orders'),
          elevation: AppDimensions.elevationNone,
        ),
        body: const OrdersView(),
      ),
    );
  }
}

/// Main view for orders page
class OrdersView extends StatelessWidget {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrdersBloc, OrdersState>(
      listener: (context, state) {
        if (state is OrdersError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        } else if (state is OrderCancelled) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Order #${state.orderId} has been cancelled'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is OrdersLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (state is OrdersError) {
          return _buildErrorView(context, state.message);
        }
        
        if (state is OrdersLoaded) {
          if (state.orders.isEmpty) {
            return _buildEmptyState(context);
          }
          
          return _buildOrdersList(context, state);
        }
        
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            'Error Loading Orders',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          ElevatedButton(
            onPressed: () {
              context.read<OrdersBloc>().add(const LoadUserOrders());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            'No Orders Yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'Your order history will appear here once you make your first purchase or rental.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(BuildContext context, OrdersLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<OrdersBloc>().add(const RefreshOrders());
        // Wait a bit for the refresh to complete
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: CustomScrollView(
        slivers: [
          // Active orders section
          if (state.activeOrders.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Text(
                  'Active Orders',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final order = state.activeOrders[index];
                  return Padding(
                    padding: const EdgeInsets.only(
                      left: AppConstants.defaultPadding,
                      right: AppConstants.defaultPadding,
                      bottom: AppConstants.smallPadding,
                    ),
                    child: OrderCard(
                      order: order,
                      isActive: true,
                      onTap: () => _onOrderTap(context, order),
                    ),
                  );
                },
                childCount: state.activeOrders.length,
              ),
            ),
          ],
          
          // Order history section
          if (state.orderHistory.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppConstants.defaultPadding,
                  state.activeOrders.isNotEmpty ? AppConstants.largePadding : AppConstants.defaultPadding,
                  AppConstants.defaultPadding,
                  AppConstants.defaultPadding,
                ),
                child: Text(
                  'Order History',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final order = state.orderHistory[index];
                  return Padding(
                    padding: const EdgeInsets.only(
                      left: AppConstants.defaultPadding,
                      right: AppConstants.defaultPadding,
                      bottom: AppConstants.smallPadding,
                    ),
                    child: OrderCard(
                      order: order,
                      isActive: false,
                      onTap: () => _onOrderTap(context, order),
                    ),
                  );
                },
                childCount: state.orderHistory.length,
              ),
            ),
          ],
          
          // Bottom spacing
          const SliverToBoxAdapter(
            child: SizedBox(height: AppConstants.defaultPadding),
          ),
        ],
      ),
    );
  }

  void _onOrderTap(BuildContext context, order) {
    // TODO: Navigate to order details page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order details for #${order.id}'),
      ),
    );
  }
}


