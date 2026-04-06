import 'package:flutter/material.dart';
import 'package:flutter_library/core/theme/app_colors.dart';
import 'package:flutter_library/shared/widgets/icon_overlay_button.dart';

/// Reusable favorite button component
class FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback? onPressed;
  final double iconSize;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool showBackground;
  final Color? backgroundColor;

  const FavoriteButton({
    super.key,
    required this.isFavorite,
    this.onPressed,
    this.iconSize = 24,
    this.activeColor,
    this.inactiveColor,
    this.showBackground = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return IconOverlayButton(
      icon: isFavorite ? Icons.favorite : Icons.favorite_border,
      iconColor: isFavorite 
          ? (activeColor ?? AppColors.favoriteColor) 
          : inactiveColor,
      onPressed: onPressed,
      iconSize: iconSize,
      showBackground: showBackground,
      backgroundColor: backgroundColor,
      tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
    );
  }
}
