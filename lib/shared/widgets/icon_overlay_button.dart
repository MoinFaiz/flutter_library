import 'package:flutter/material.dart';

/// Generic overlay button for book cards (used for favorites, from-friend, etc.)
class IconOverlayButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double iconSize;
  final Color? iconColor;
  final Color? backgroundColor;
  final bool showBackground;
  final String? tooltip;

  const IconOverlayButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.iconSize = 20,
    this.iconColor,
    this.backgroundColor,
    this.showBackground = true,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = IconButton(
      icon: Icon(
        icon,
        color: iconColor,
        size: iconSize,
      ),
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      tooltip: tooltip,
    );

    if (showBackground) {
      return Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: button,
      );
    }

    return button;
  }
}
