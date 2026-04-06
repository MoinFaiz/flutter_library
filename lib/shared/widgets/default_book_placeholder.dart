import 'package:flutter/material.dart';
import 'package:flutter_library/core/theme/app_dimensions.dart';

/// Default book placeholder widget when no image is available
class DefaultBookPlaceholder extends StatelessWidget {
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? iconColor;

  const DefaultBookPlaceholder({
    super.key,
    this.width,
    this.height,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showLabel = (height ?? 0) > 90;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: showLabel
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  size: (height != null && height! > 100) ? 48 : 32,
                  color: iconColor ?? theme.colorScheme.outline,
                ),
                const SizedBox(height: AppDimensions.spaceSm),
                Text(
                  'No Image',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: iconColor ?? theme.colorScheme.outline,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            )
          : Center(
              child: Icon(
                Icons.menu_book_rounded,
                size: 28,
                color: iconColor ?? theme.colorScheme.outline,
              ),
            ),
    );
  }
}

/// Loading placeholder widget for images that are loading
class BookImageLoadingPlaceholder extends StatelessWidget {
  final double? width;
  final double? height;
  final Color? backgroundColor;

  const BookImageLoadingPlaceholder({
    super.key,
    this.width,
    this.height,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showLabel = (height ?? 0) > 90;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: showLabel
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceSmPlus),
                Text(
                  'Loading...',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            )
          : Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
    );
  }
}
