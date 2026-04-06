import 'package:flutter/material.dart';
import 'package:flutter_library/core/theme/app_dimensions.dart';

/// Theme extension for custom app-specific styling
@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color? bookCardBackground;
  final Color? bookCardShadow;
  final Color? favoriteActiveColor;
  final Color? favoriteInactiveColor;
  final Color? ratingColor;
  final Color? searchBarBackground;
  final Color? searchBarBorder;
  final BorderRadius? cardBorderRadius;
  final BorderRadius? inputBorderRadius;
  final double? bookCardElevation;
  final TextStyle? bookTitleStyle;
  final TextStyle? bookAuthorStyle;
  final TextStyle? bookRatingStyle;

  const AppThemeExtension({
    this.bookCardBackground,
    this.bookCardShadow,
    this.favoriteActiveColor,
    this.favoriteInactiveColor,
    this.ratingColor,
    this.searchBarBackground,
    this.searchBarBorder,
    this.cardBorderRadius,
    this.inputBorderRadius,
    this.bookCardElevation,
    this.bookTitleStyle,
    this.bookAuthorStyle,
    this.bookRatingStyle,
  });

  @override
  AppThemeExtension copyWith({
    Color? bookCardBackground,
    Color? bookCardShadow,
    Color? favoriteActiveColor,
    Color? favoriteInactiveColor,
    Color? ratingColor,
    Color? searchBarBackground,
    Color? searchBarBorder,
    BorderRadius? cardBorderRadius,
    BorderRadius? inputBorderRadius,
    double? bookCardElevation,
    TextStyle? bookTitleStyle,
    TextStyle? bookAuthorStyle,
    TextStyle? bookRatingStyle,
  }) {
    return AppThemeExtension(
      bookCardBackground: bookCardBackground ?? this.bookCardBackground,
      bookCardShadow: bookCardShadow ?? this.bookCardShadow,
      favoriteActiveColor: favoriteActiveColor ?? this.favoriteActiveColor,
      favoriteInactiveColor: favoriteInactiveColor ?? this.favoriteInactiveColor,
      ratingColor: ratingColor ?? this.ratingColor,
      searchBarBackground: searchBarBackground ?? this.searchBarBackground,
      searchBarBorder: searchBarBorder ?? this.searchBarBorder,
      cardBorderRadius: cardBorderRadius ?? this.cardBorderRadius,
      inputBorderRadius: inputBorderRadius ?? this.inputBorderRadius,
      bookCardElevation: bookCardElevation ?? this.bookCardElevation,
      bookTitleStyle: bookTitleStyle ?? this.bookTitleStyle,
      bookAuthorStyle: bookAuthorStyle ?? this.bookAuthorStyle,
      bookRatingStyle: bookRatingStyle ?? this.bookRatingStyle,
    );
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) {
      return this;
    }
    return AppThemeExtension(
      bookCardBackground: Color.lerp(bookCardBackground, other.bookCardBackground, t),
      bookCardShadow: Color.lerp(bookCardShadow, other.bookCardShadow, t),
      favoriteActiveColor: Color.lerp(favoriteActiveColor, other.favoriteActiveColor, t),
      favoriteInactiveColor: Color.lerp(favoriteInactiveColor, other.favoriteInactiveColor, t),
      ratingColor: Color.lerp(ratingColor, other.ratingColor, t),
      searchBarBackground: Color.lerp(searchBarBackground, other.searchBarBackground, t),
      searchBarBorder: Color.lerp(searchBarBorder, other.searchBarBorder, t),
      cardBorderRadius: BorderRadius.lerp(cardBorderRadius, other.cardBorderRadius, t),
      inputBorderRadius: BorderRadius.lerp(inputBorderRadius, other.inputBorderRadius, t),
      bookCardElevation: t < 0.5 ? bookCardElevation : other.bookCardElevation,
      bookTitleStyle: TextStyle.lerp(bookTitleStyle, other.bookTitleStyle, t),
      bookAuthorStyle: TextStyle.lerp(bookAuthorStyle, other.bookAuthorStyle, t),
      bookRatingStyle: TextStyle.lerp(bookRatingStyle, other.bookRatingStyle, t),
    );
  }

  /// Light theme extension  
  static const AppThemeExtension light = AppThemeExtension(
    bookCardBackground: Color(0xFFFFFFFF),
    bookCardShadow: Color(0x1A000000),
    favoriteActiveColor: Color(0xFFE91E63),
    favoriteInactiveColor: Color(0xFF757575),
    ratingColor: Color(0xFFFFC107),
    searchBarBackground: Color(0xFFF5F5F5),
    searchBarBorder: Color(0xFFE0E0E0),
    cardBorderRadius: BorderRadius.all(Radius.circular(12)),
    inputBorderRadius: BorderRadius.all(Radius.circular(8)),
    bookCardElevation: AppDimensions.elevationSm,
  );

  /// Dark theme extension
  static const AppThemeExtension dark = AppThemeExtension(
    bookCardBackground: Color(0xFF1E1E1E),
    bookCardShadow: Color(0x3A000000),
    favoriteActiveColor: Color(0xFFE91E63),
    favoriteInactiveColor: Color(0xFF9E9E9E),
    ratingColor: Color(0xFFFFC107),
    searchBarBackground: Color(0xFF2C2C2C),
    searchBarBorder: Color(0xFF3A3A3A),
    cardBorderRadius: BorderRadius.all(Radius.circular(12)),
    inputBorderRadius: BorderRadius.all(Radius.circular(8)),
    bookCardElevation: AppDimensions.elevationMd,
  );
}

/// Extension to easily access theme extension from BuildContext
extension AppThemeExtensionContext on BuildContext {
  AppThemeExtension get appTheme {
    return Theme.of(this).extension<AppThemeExtension>() ?? AppThemeExtension.light;
  }
}
