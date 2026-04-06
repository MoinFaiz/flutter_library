import 'package:flutter/material.dart';
import 'package:flutter_library/core/navigation/app_routes.dart';
import 'package:flutter_library/core/navigation/navigation_service.dart';
import 'package:flutter_library/core/theme/app_dimensions.dart';
import 'package:flutter_library/core/theme/app_typography.dart';
import 'package:flutter_library/injection/injection_container.dart';

/// Reusable cart icon button with badge showing item count
class CartIconButton extends StatelessWidget {
  final Color? iconColor;
  final Color? badgeColor;
  final Color? badgeTextColor;
  final int itemCount;

  const CartIconButton({
    super.key,
    this.iconColor,
    this.badgeColor,
    this.badgeTextColor,
    this.itemCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(
            Icons.shopping_cart_outlined,
            color: iconColor,
          ),
          onPressed: () {
            final navigationService = sl<NavigationService>();
            navigationService.navigateTo(AppRoutes.cart);
          },
          tooltip: 'Shopping Cart',
        ),
        if (itemCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: badgeColor ?? Theme.of(context).colorScheme.error,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.surface,
                  width: AppDimensions.dividerMedium,
                ),
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Center(
                child: Text(
                  itemCount > 99 ? '99+' : itemCount.toString(),
                  style: TextStyle(
                    color: badgeTextColor ?? Theme.of(context).colorScheme.onPrimary,
                    fontSize: AppTypography.fontSizeXs,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
