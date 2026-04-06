import 'package:flutter/material.dart';
import 'app_dimensions.dart';
import 'app_component_styles.dart';

/// Extension methods for common component patterns and padding utilities
extension WidgetPaddingExtension on Widget {
  /// Wraps widget with compact padding
  Widget withCompactPadding() => Padding(
    padding: AppComponentStyles.compactPadding,
    child: this,
  );

  /// Wraps widget with default padding
  Widget withDefaultPadding() => Padding(
    padding: AppComponentStyles.defaultPadding,
    child: this,
  );

  /// Wraps widget with loose padding
  Widget withLoosePadding() => Padding(
    padding: AppComponentStyles.loosePadding,
    child: this,
  );

  /// Wraps widget with card padding
  Widget withCardPadding() => Padding(
    padding: AppComponentStyles.cardPadding,
    child: this,
  );

  /// Wraps widget with custom padding
  Widget withPadding(EdgeInsets padding) => Padding(
    padding: padding,
    child: this,
  );
}

/// Extension methods for container decorations
extension ContainerDecorationExtension on Widget {
  /// Applies card decoration with default styling
  Widget asCard({
    bool isDark = false,
    EdgeInsets padding = const EdgeInsets.all(0),
  }) =>
      Container(
        decoration: isDark
            ? AppComponentStyles.cardDecorationDark
            : AppComponentStyles.cardDecoration,
        padding: padding.add(AppComponentStyles.defaultPadding),
        child: this,
      );

  /// Applies status badge decoration
  Widget asStatusBadge({
    required BadgeStatus status,
    EdgeInsets padding = const EdgeInsets.all(0),
  }) =>
      Container(
        decoration: status == BadgeStatus.success
            ? AppComponentStyles.statusBadgeDecoration
            : status == BadgeStatus.error
                ? AppComponentStyles.statusErrorBadgeDecoration
                : AppComponentStyles.statusWarningBadgeDecoration,
        padding: padding.add(AppComponentStyles.compactPadding),
        child: this,
      );

  /// Applies shadow elevation style
  Widget withShadow({required ShadowElevation elevation}) => Container(
    decoration: elevation == ShadowElevation.small
        ? AppComponentStyles.shadowElevationSm
        : elevation == ShadowElevation.medium
            ? AppComponentStyles.shadowElevationMd
            : AppComponentStyles.shadowElevationLg,
    child: this,
  );

  /// Applies focus state decoration
  Widget asFocusedElement() => Container(
    decoration: AppComponentStyles.focusStateDecoration,
    child: this,
  );

  /// Applies hover state decoration
  Widget asHoverElement() => Container(
    decoration: AppComponentStyles.hoverStateDecoration,
    child: this,
  );

  /// Applies disabled state decoration
  Widget asDisabledElement() => Container(
    decoration: AppComponentStyles.disabledStateDecoration,
    child: this,
  );
}

/// Extension methods for spacing utilities
extension SpacingExtension on Widget {
  /// Adds vertical spacing below widget
  Widget addVerticalSpace(double height) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      this,
      SizedBox(height: height),
    ],
  );

  /// Adds horizontal spacing to the right of widget
  Widget addHorizontalSpace(double width) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      this,
      SizedBox(width: width),
    ],
  );

  /// Wraps widget with standard spacing on all sides
  Widget withStandardSpacing() => Padding(
    padding: const EdgeInsets.all(AppDimensions.spaceMd),
    child: this,
  );

  /// Wraps widget with compact spacing
  Widget withCompactSpacing() => Padding(
    padding: const EdgeInsets.all(AppDimensions.spaceSm),
    child: this,
  );

  /// Wraps widget with loose spacing
  Widget withLooseSpacing() => Padding(
    padding: const EdgeInsets.all(AppDimensions.spaceLg),
    child: this,
  );
}

/// Extension methods for text styling with spacing
extension TextSpacingExtension on Text {
  /// Wraps text with top padding
  Widget withTopPadding(double padding) => Padding(
    padding: EdgeInsets.only(top: padding),
    child: this,
  );

  /// Wraps text with bottom padding
  Widget withBottomPadding(double padding) => Padding(
    padding: EdgeInsets.only(bottom: padding),
    child: this,
  );

  /// Wraps text with left padding
  Widget withLeftPadding(double padding) => Padding(
    padding: EdgeInsets.only(left: padding),
    child: this,
  );

  /// Wraps text with right padding
  Widget withRightPadding(double padding) => Padding(
    padding: EdgeInsets.only(right: padding),
    child: this,
  );
}

/// Enum for badge status colors
enum BadgeStatus {
  success,
  error,
  warning,
}

/// Enum for shadow elevation levels
enum ShadowElevation {
  small,
  medium,
  large,
}
