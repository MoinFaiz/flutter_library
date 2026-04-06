import 'package:flutter/material.dart';

/// Standardized typography system for the app
class AppTypography {
  // Font Family
  static const String primaryFontFamily = 'SF Pro Display'; // Default system font
  static const String monospaceFontFamily = 'SF Mono'; // For code/monospace text

  // Font Weights
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semibold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extrabold = FontWeight.w800;

  // Font Sizes
  static const double fontSizeXs = 12.0;
  static const double fontSizeSm = 14.0;
  static const double fontSizeMd = 16.0;
  static const double fontSizeLg = 18.0;
  static const double fontSizeXl = 20.0;
  static const double fontSize2Xl = 24.0;
  static const double fontSize3Xl = 30.0;
  static const double fontSize4Xl = 36.0;

  // Line Heights (as multipliers)
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.4;
  static const double lineHeightRelaxed = 1.6;
  static const double lineHeightLoose = 1.8;

  // Letter Spacing
  static const double letterSpacingTight = -0.5;
  static const double letterSpacingNormal = 0.0;
  static const double letterSpacingWide = 0.5;
  static const double letterSpacingWider = 1.0;

  /// Create a standardized text style
  static TextStyle createTextStyle({
    required double fontSize,
    FontWeight fontWeight = regular,
    double? height,
    double letterSpacing = letterSpacingNormal,
    Color? color,
    String fontFamily = primaryFontFamily,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
      fontFamily: fontFamily,
    );
  }

  // Heading Styles
  static TextStyle get heading1 => createTextStyle(
    fontSize: fontSize4Xl,
    fontWeight: bold,
    height: lineHeightTight,
    letterSpacing: letterSpacingTight,
  );

  static TextStyle get heading2 => createTextStyle(
    fontSize: fontSize3Xl,
    fontWeight: bold,
    height: lineHeightTight,
    letterSpacing: letterSpacingTight,
  );

  static TextStyle get heading3 => createTextStyle(
    fontSize: fontSize2Xl,
    fontWeight: semibold,
    height: lineHeightNormal,
  );

  static TextStyle get heading4 => createTextStyle(
    fontSize: fontSizeXl,
    fontWeight: semibold,
    height: lineHeightNormal,
  );

  static TextStyle get heading5 => createTextStyle(
    fontSize: fontSizeLg,
    fontWeight: semibold,
    height: lineHeightNormal,
  );

  static TextStyle get heading6 => createTextStyle(
    fontSize: fontSizeMd,
    fontWeight: semibold,
    height: lineHeightNormal,
  );

  // Body Styles
  static TextStyle get bodyLarge => createTextStyle(
    fontSize: fontSizeLg,
    fontWeight: regular,
    height: lineHeightRelaxed,
  );

  static TextStyle get bodyMedium => createTextStyle(
    fontSize: fontSizeMd,
    fontWeight: regular,
    height: lineHeightRelaxed,
  );

  static TextStyle get bodySmall => createTextStyle(
    fontSize: fontSizeSm,
    fontWeight: regular,
    height: lineHeightNormal,
  );

  // Label Styles
  static TextStyle get labelLarge => createTextStyle(
    fontSize: fontSizeMd,
    fontWeight: medium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingWide,
  );

  static TextStyle get labelMedium => createTextStyle(
    fontSize: fontSizeSm,
    fontWeight: medium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingWide,
  );

  static TextStyle get labelSmall => createTextStyle(
    fontSize: fontSizeXs,
    fontWeight: medium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingWider,
  );

  // Button Styles
  static TextStyle get buttonLarge => createTextStyle(
    fontSize: fontSizeLg,
    fontWeight: semibold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingWide,
  );

  static TextStyle get buttonMedium => createTextStyle(
    fontSize: fontSizeMd,
    fontWeight: semibold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingWide,
  );

  static TextStyle get buttonSmall => createTextStyle(
    fontSize: fontSizeSm,
    fontWeight: semibold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingWider,
  );

  // Caption and Overline
  static TextStyle get caption => createTextStyle(
    fontSize: fontSizeXs,
    fontWeight: regular,
    height: lineHeightNormal,
    letterSpacing: letterSpacingWide,
  );

  static TextStyle get overline => createTextStyle(
    fontSize: fontSizeXs,
    fontWeight: medium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingWider,
  );

  // Book-specific styles
  static TextStyle get bookTitle => createTextStyle(
    fontSize: fontSizeMd,
    fontWeight: semibold,
    height: lineHeightNormal,
  );

  static TextStyle get bookAuthor => createTextStyle(
    fontSize: fontSizeSm,
    fontWeight: regular,
    height: lineHeightNormal,
  );

  static TextStyle get bookRating => createTextStyle(
    fontSize: fontSizeSm,
    fontWeight: medium,
    height: lineHeightNormal,
  );

  // Notification styles
  static TextStyle get notificationTitle => createTextStyle(
    fontSize: fontSizeMd,
    fontWeight: semibold,
    height: lineHeightNormal,
  );

  static TextStyle get notificationBody => createTextStyle(
    fontSize: fontSizeSm,
    fontWeight: regular,
    height: lineHeightRelaxed,
  );

  static TextStyle get notificationTime => createTextStyle(
    fontSize: fontSizeXs,
    fontWeight: regular,
    height: lineHeightNormal,
  );

  // Code style
  static TextStyle get code => createTextStyle(
    fontSize: fontSizeSm,
    fontWeight: regular,
    height: lineHeightNormal,
    fontFamily: monospaceFontFamily,
  );
}