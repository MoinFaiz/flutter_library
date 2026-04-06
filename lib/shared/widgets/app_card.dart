import 'package:flutter/material.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_component_styles.dart';

/// Standardized card widget with consistent styling
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final bool elevated;
  final Color? color;
  final BorderRadius? borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.elevated = true,
    this.color,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final decoration = (isDark 
        ? AppComponentStyles.cardDecorationDark 
        : AppComponentStyles.cardDecoration).copyWith(
      color: color,
      borderRadius: borderRadius ?? BorderRadius.circular(AppDimensions.cardRadius),
      boxShadow: elevated ? (isDark 
          ? AppComponentStyles.cardDecorationDark 
          : AppComponentStyles.cardDecoration).boxShadow : null,
    );

    Widget card = Container(
      margin: margin,
      decoration: decoration,
      child: Padding(
        padding: padding ?? EdgeInsets.all(AppDimensions.cardPadding),
        child: child,
      ),
    );

    if (onTap != null) {
      card = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? BorderRadius.circular(AppDimensions.cardRadius),
          child: card,
        ),
      );
    }

    return card;
  }
}

/// Standardized list tile with consistent styling
class AppListTile extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;
  final EdgeInsets? contentPadding;

  const AppListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.enabled = true,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
      title: DefaultTextStyle(
        style: AppTypography.bodyMedium.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        child: title,
      ),
      subtitle: subtitle != null
          ? DefaultTextStyle(
              style: AppTypography.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              child: subtitle!,
            )
          : null,
      trailing: trailing,
      onTap: enabled ? onTap : null,
      enabled: enabled,
      contentPadding: contentPadding ?? EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceMd,
        vertical: AppDimensions.spaceSm,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
    );
  }
}

/// Standardized section header widget
class AppSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  final EdgeInsets? padding;

  const AppSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: padding ?? EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceMd,
        vertical: AppDimensions.spaceSm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.heading5.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                ...?(subtitle == null
                    ? null
                    : [
                        const SizedBox(height: AppDimensions.spaceXs),
                        Text(
                          subtitle!,
                          style: AppTypography.bodySmall.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ]),
              ],
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}

/// Standardized empty state widget
class AppEmptyState extends StatelessWidget {
  final Widget icon;
  final String title;
  final String? message;
  final Widget? action;
  final EdgeInsets? padding;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: padding ?? EdgeInsets.all(AppDimensions.spaceLg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconTheme(
            data: IconThemeData(
              size: AppDimensions.icon3Xl,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            child: icon,
          ),
          const SizedBox(height: AppDimensions.spaceMd),
          Text(
            title,
            style: AppTypography.heading4.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          if (message != null) ...[
            const SizedBox(height: AppDimensions.spaceSm),
            Text(
              message!,
              style: AppTypography.bodyMedium.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: AppDimensions.spaceLg),
            action!,
          ],
        ],
      ),
    );
  }
}

/// Standardized loading widget
class AppLoading extends StatelessWidget {
  final String? message;
  final bool overlay;

  const AppLoading({
    super.key,
    this.message,
    this.overlay = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget loading = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          color: theme.colorScheme.primary,
        ),
        if (message != null) ...[
          const SizedBox(height: AppDimensions.spaceMd),
          Text(
            message!,
            style: AppTypography.bodyMedium.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (overlay) {
      loading = Container(
        color: theme.colorScheme.surface.withValues(alpha: 0.8),
        child: Center(child: loading),
      );
    }

    return loading;
  }
}