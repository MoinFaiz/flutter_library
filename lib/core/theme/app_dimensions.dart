/// Standardized dimensions and spacing for the entire app
class AppDimensions {
  // Spacing Scale - 8dp base unit
  static const double spaceXxs = 2.0; // 2dp - smallest unit
  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceSmPlus = 12.0; // spaceSm + spaceXs (8 + 4)
  static const double spaceLayout = 14.0; // Specific layout spacing
  static const double spaceMd = 16.0;
  static const double spaceLg = 24.0;
  static const double spaceXl = 32.0;
  static const double space2Xl = 40.0;
  static const double space3Xl = 48.0;

  // Border Radius Scale
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusFull = 999.0;

  // Icon Sizes
  static const double iconXs = 16.0;
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 28.0;
  static const double iconXl = 32.0;
  static const double icon2Xl = 40.0;
  static const double icon3Xl = 48.0;
  static const double iconSize32 = 32.0; // For specific 32px use cases

  // Button Heights
  static const double buttonHeightSm = 36.0;
  static const double buttonHeightMd = 44.0;
  static const double buttonHeightLg = 52.0;

  // Input Heights
  static const double inputHeightSm = 40.0;
  static const double inputHeightMd = 48.0;
  static const double inputHeightLg = 56.0;

  // Elevation Scale
  static const double elevationNone = 0.0;
  static const double elevationXs = 1.0;
  static const double elevationSm = 2.0;
  static const double elevationMd = 4.0;
  static const double elevationLg = 8.0;
  static const double elevationXl = 16.0;

  // Card Dimensions
  static const double cardPadding = spaceMd;
  static const double cardRadius = radiusMd;
  static const double cardElevation = elevationSm;

  // Avatar Sizes
  static const double avatarSm = 32.0;
  static const double avatarMd = 40.0;
  static const double avatarLg = 48.0;
  static const double avatarXl = 64.0;
  static const double avatar2Xl = 80.0;

  // Book Card Specific
  static const double bookCardWidth = 120.0;
  static const double bookCardHeight = 180.0;
  static const double bookCardAspectRatio = bookCardWidth / bookCardHeight; // 0.67
  static const double bookCoverRadius = radiusSm;
  static const double bookCardPadding = spaceSm;

  // Grid System
  static const int gridColumns = 2;
  static const double gridSpacing = spaceMd;
  static const double gridAspectRatio = 0.7;

  // App Bar
  static const double appBarHeight = 56.0;
  static const double appBarElevation = elevationNone;

  // Bottom Navigation
  static const double bottomNavHeight = 60.0;
  static const double bottomNavIconSize = iconMd;

  // Divider
  static const double dividerThickness = 1.0;
  static const double dividerThin = 1.0;
  static const double dividerMedium = 1.5;
  static const double dividerThick = 2.0;
  static const double dividerIndent = spaceMd;

  // Status Indicators & Badges
  static const double dotSize = 8.0;
  static const double dotSizeSm = 6.0;
  static const double dotSizeLg = 12.0;
  static const double badgeSize = 18.0;

  // Modal/Dialog
  static const double modalRadius = radiusLg;
  static const double modalPadding = spaceLg;
  static const double maxDialogWidth = 400.0;
  static const double maxSearchResultsHeight = 300.0;

  // Skeleton Loading
  static const double skeletonRadius = radiusXs;
  static const double skeletonTitleHeight = 14.0;
  static const double skeletonSubtitleHeight = 12.0;
  static const double skeletonImageHeight = 120.0;

  // Image/Book Card Heights
  static const double bookDetailImageHeight = 300.0;
  static const double bookCarouselHeight = 300.0;

  // Badge
  static const double badgeRadius = radiusFull;
  static const double badgeMinSize = 16.0;
  static const double badgePadding = spaceXs;

  // Responsive breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;
}