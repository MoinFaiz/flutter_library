import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_library/core/navigation/app_routes.dart';
import 'package:flutter_library/core/navigation/navigation_service.dart';
import 'package:flutter_library/core/theme/app_colors.dart';
import 'package:flutter_library/core/theme/app_dimensions.dart';
import 'package:flutter_library/core/theme/app_typography.dart';
import 'package:flutter_library/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:flutter_library/features/cart/presentation/bloc/cart_event.dart';
import 'package:flutter_library/features/cart/presentation/bloc/cart_state.dart';
import 'package:flutter_library/features/cart/presentation/widgets/cart_item_card.dart';
import 'package:flutter_library/features/cart/presentation/widgets/cart_summary_card.dart';
import 'package:flutter_library/injection/injection_container.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CartView();
  }
}

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  final NavigationService _navigationService = sl<NavigationService>();

  void _navigateToFavorites() {
    _navigationService.navigateTo(AppRoutes.favorites);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Shopping Cart',
          style: TextStyle(fontSize: AppTypography.fontSizeLg),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<CartBloc>().add(RefreshCart());
            },
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.favorite_outline),
            onPressed: _navigateToFavorites,
            tooltip: 'Favorites',
          ),
        ],
        elevation: AppDimensions.elevationXs,
        shadowColor: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
        toolbarHeight: AppDimensions.appBarHeight,
      ),
      body: BlocConsumer<CartBloc, CartState>(
        listener: (context, state) {
          if (state is CartError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          } else if (state is CartOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CartLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CartLoaded) {
            if (state.items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: AppDimensions.avatar2Xl,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    SizedBox(height: AppDimensions.spaceMd),
                    Text(
                      'Your cart is empty',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: AppDimensions.spaceSm),
                    Text(
                      'Add books to get started',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context.read<CartBloc>().add(RefreshCart());
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.items.length,
                      itemBuilder: (context, index) {
                        final item = state.items[index];
                        return CartItemCard(
                          item: item,
                          onRemove: () {
                            context.read<CartBloc>().add(RemoveItemFromCart(item.id));
                          },
                          onSendRequest: () {
                            if (item.isRental) {
                              context.read<CartBloc>().add(SendRentalRequest(
                                    bookId: item.book.id,
                                    rentalPeriodInDays: item.rentalPeriodInDays,
                                  ));
                            } else {
                              context.read<CartBloc>().add(SendPurchaseRequest(item.book.id));
                            }
                          },
                        );
                      },
                    ),
                  ),
                ),
                CartSummaryCard(
                  total: state.total,
                  itemCount: state.items.length,
                  isProcessing: state.isProcessing,
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
