import 'package:flutter/material.dart';
import 'package:flutter_library/shared/widgets/icon_overlay_button.dart';

/// Button to indicate book is available from a friend
class FromFriendButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final double iconSize;
  final Color? iconColor;
  final Color? backgroundColor;
  final bool showBackground;

  const FromFriendButton({
    super.key,
    this.onPressed,
    this.iconSize = 20,
    this.iconColor,
    this.backgroundColor,
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    return IconOverlayButton(
      icon: Icons.people,
      iconColor: iconColor ?? Theme.of(context).colorScheme.primary,
      onPressed: onPressed,
      iconSize: iconSize,
      showBackground: showBackground,
      backgroundColor: backgroundColor,
      tooltip: 'Available from friend',
    );
  }
}
