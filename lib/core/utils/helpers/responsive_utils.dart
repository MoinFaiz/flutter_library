import 'package:flutter/material.dart';

/// Responsive utility class for handling different screen sizes
class ResponsiveUtils {
  static const double _mobileBreakpoint = 600;
  static const double _tabletBreakpoint = 900;
  static const double _desktopBreakpoint = 1200;

  /// Check if the screen is mobile size
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < _mobileBreakpoint;
  }

  /// Check if the screen is tablet size
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= _mobileBreakpoint && width < _tabletBreakpoint;
  }

  /// Check if the screen is desktop size
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= _desktopBreakpoint;
  }

  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24.0);
    } else {
      return const EdgeInsets.all(32.0);
    }
  }

  /// Get responsive horizontal padding based on screen size
  static EdgeInsets getResponsiveHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < _mobileBreakpoint) {
      return const EdgeInsets.symmetric(horizontal: 16.0);
    } else if (width < _tabletBreakpoint) {
      return const EdgeInsets.symmetric(horizontal: 24.0);
    } else if (width < _desktopBreakpoint) {
      return const EdgeInsets.symmetric(horizontal: 32.0);
    } else {
      // For very large screens, limit the maximum width
      final maxContentWidth = width * 0.8;
      final horizontalPadding = (width - maxContentWidth) / 2;
      return EdgeInsets.symmetric(horizontal: horizontalPadding);
    }
  }

  /// Get responsive content width for centered content
  static double getResponsiveContentWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < _mobileBreakpoint) {
      return width;
    } else if (width < _tabletBreakpoint) {
      return width * 0.9;
    } else if (width < _desktopBreakpoint) {
      return width * 0.8;
    } else {
      return 1000; // Max width for very large screens
    }
  }

  /// Get responsive book cover size
  static Size getResponsiveBookCoverSize(BuildContext context) {
    if (isMobile(context)) {
      return const Size(60, 80);
    } else if (isTablet(context)) {
      return const Size(80, 100);
    } else {
      return const Size(100, 120);
    }
  }

  /// Get responsive star size for ratings
  static double getResponsiveStarSize(BuildContext context) {
    if (isMobile(context)) {
      return 40.0;
    } else if (isTablet(context)) {
      return 48.0;
    } else {
      return 56.0;
    }
  }

  /// Get responsive avatar radius
  static double getResponsiveAvatarRadius(BuildContext context) {
    if (isMobile(context)) {
      return 20.0;
    } else if (isTablet(context)) {
      return 24.0;
    } else {
      return 28.0;
    }
  }

  /// Get responsive modal sheet sizes
  static Map<String, double> getResponsiveModalSizes(BuildContext context) {
    if (isMobile(context)) {
      return {
        'initial': 0.7,
        'max': 0.9,
        'min': 0.5,
      };
    } else if (isTablet(context)) {
      return {
        'initial': 0.6,
        'max': 0.8,
        'min': 0.4,
      };
    } else {
      return {
        'initial': 0.5,
        'max': 0.7,
        'min': 0.3,
      };
    }
  }

  /// Get responsive text field max lines
  static int getResponsiveTextFieldLines(BuildContext context) {
    if (isMobile(context)) {
      return 6;
    } else if (isTablet(context)) {
      return 8;
    } else {
      return 10;
    }
  }

  /// Get responsive spacing
  static double getResponsiveSpacing(BuildContext context, {double base = 16.0}) {
    if (isMobile(context)) {
      return base;
    } else if (isTablet(context)) {
      return base * 1.25;
    } else {
      return base * 1.5;
    }
  }
}
