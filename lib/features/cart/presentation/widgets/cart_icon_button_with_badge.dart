import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_library/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:flutter_library/features/cart/presentation/bloc/cart_state.dart';
import 'package:flutter_library/shared/widgets/cart_icon_button.dart';

/// Feature adapter that binds cart state to the shared cart icon button.
class CartIconButtonWithBadge extends StatelessWidget {
  final Color? iconColor;
  final Color? badgeColor;
  final Color? badgeTextColor;

  const CartIconButtonWithBadge({
    super.key,
    this.iconColor,
    this.badgeColor,
    this.badgeTextColor,
  });

  @override
  Widget build(BuildContext context) {
    CartBloc? cartBloc;
    try {
      cartBloc = context.read<CartBloc>();
    } catch (_) {
      cartBloc = null;
    }

    if (cartBloc == null) {
      return CartIconButton(
        iconColor: iconColor,
        badgeColor: badgeColor,
        badgeTextColor: badgeTextColor,
      );
    }

    return BlocBuilder<CartBloc, CartState>(
      bloc: cartBloc,
      builder: (context, state) {
        final itemCount = state is CartLoaded ? state.items.length : 0;

        return CartIconButton(
          iconColor: iconColor,
          badgeColor: badgeColor,
          badgeTextColor: badgeTextColor,
          itemCount: itemCount,
        );
      },
    );
  }
}
