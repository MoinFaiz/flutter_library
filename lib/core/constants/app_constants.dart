import '../theme/app_dimensions.dart';
import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'Library App';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String themeKey = 'theme_mode';
  static const String favoritesKey = 'favorites';
  
  // API Constants
  static const String baseUrl = 'https://api.example.com/v1';
  static const int requestTimeout = 30000;
  
  // UI Constants - Use standardized dimensions
  static const double defaultPadding = AppDimensions.spaceMd;
  static const double smallPadding = AppDimensions.spaceSm;
  static const double xsPadding = AppDimensions.spaceXs;
  static const double largePadding = AppDimensions.spaceLg;
  static const double borderRadius = AppDimensions.radiusMd;
  static const double iconSize = AppDimensions.iconMd;
  static const double ratingSize = AppDimensions.iconSm;
  
  // Book Card Responsive Dimensions
  static const double horizontalBookCardWidth = AppDimensions.bookCardWidth;
  static const double horizontalBookCardHeight = AppDimensions.bookCardHeight;
  static const double horizontalBookCardAspectRatio = AppDimensions.bookCardAspectRatio;
  
  // Skeleton Loading Constants
  static const double skeletonTitleHeight = AppDimensions.skeletonTitleHeight;
  static const double skeletonSubtitleHeight = AppDimensions.skeletonSubtitleHeight;
  static const double skeletonRatingHeight = 10.0;
  static const double skeletonBorderRadius = AppDimensions.skeletonRadius;
  
  // Grid Constants
  static const int gridCrossAxisCount = AppDimensions.gridColumns;
  static const double gridAspectRatio = AppDimensions.gridAspectRatio;
  static const double gridSpacing = AppDimensions.gridSpacing;
  
  // Animation Durations
  static const Duration shortDuration = Duration(milliseconds: 200);
  static const Duration mediumDuration = Duration(milliseconds: 300);
  static const Duration longDuration = Duration(milliseconds: 500);
  
  // Animation Curves - Standard animation paths
  static const Curve standardCurve = Curves.easeInOut;
  static const Curve bouncyCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.ease;
  static const Curve snappyCurve = Curves.easeOutCubic;
  
  // Micro-interaction Settings
  static const bool enableHapticFeedback = true;
  static const double shadowElevation = 4.0;
  static const double subtleShadowElevation = 2.0;
  
  // Animation Speeds for UI transitions
  static const Duration fabAnimationDuration = Duration(milliseconds: 250);
  static const Duration buttonPressAnimationDuration = Duration(milliseconds: 100);
  static const Duration cardHoverAnimationDuration = Duration(milliseconds: 150);
  static const Duration loadingIndicatorDuration = Duration(milliseconds: 1500);
  
  // Error Messages
  static const String noInternetError = 'No internet connection';
  static const String serverError = 'Server error occurred';
  static const String unknownError = 'Unknown error occurred';
  static const String noDataError = 'No data available';
  static const String loadingError = 'Failed to load data';
  
  // Library Page Strings
  static const String myLibraryTitle = 'My Library';
  static const String borrowedBooksTitle = 'Borrowed Books';
  static const String myUploadedBooksTitle = 'My Uploaded Books';
  static const String loadingLibraryMessage = 'Loading your library...';
  static const String errorLoadingLibraryTitle = 'Error Loading Library';
  static const String tryAgainButton = 'Try Again';
  static const String moreButton = 'More';
  
  // Horizontal Book List Strings
  static const String errorLoadingBooksMessage = 'Error loading books';
  static const String noBooksYetTitle = 'No books yet';
  static const String noBorrowedBooksMessage = 'You haven\'t borrowed any books yet';
  static const String noUploadedBooksMessage = 'You haven\'t uploaded any books yet';
  
  // Full Book List Page Strings
  static const String noBorrowedBooksTitle = 'No borrowed books';
  static const String noUploadedBooksTitle = 'No uploaded books';
  static const String noBorrowedBooksSubtitle = 'You haven\'t borrowed any books yet.\nStart exploring and borrow some books!';
  static const String noUploadedBooksSubtitle = 'You haven\'t uploaded any books yet.\nShare your books with the community!';
  static const String addedToFavoritesMessage = 'Added to favorites';
  static const String removedFromFavoritesMessage = 'Removed from favorites';
  static const String unexpectedErrorMessage = 'An unexpected error occurred';
  
  // Repository Error Messages
  static const String failedToGetBorrowedBooksError = 'Failed to get borrowed books';
  static const String failedToGetUploadedBooksError = 'Failed to get uploaded books';
  static const String failedToGetAllBorrowedBooksError = 'Failed to get all borrowed books';
  static const String failedToGetAllUploadedBooksError = 'Failed to get all uploaded books';

  // Pagination — upper bound for "fetch all" queries until cursor-based API is available
  static const int maxBooksPerBatch = 500;
  
  // Review Page Constants
  static const double reviewBookCoverWidth = 60.0;
  static const double reviewBookCoverHeight = 80.0;
  static const double reviewAvatarRadius = 20.0;
  static const double reviewStarSize = 40.0;
  static const double reviewFormStarPadding = 4.0;
  static const double reviewModalHandleWidth = 40.0;
  static const double reviewModalHandleHeight = 4.0;
  static const double reviewModalInitialSize = 0.7;
  static const double reviewModalMaxSize = 0.9;
  static const double reviewModalMinSize = 0.5;
  static const int reviewTextFieldMaxLines = 6;
  static const int defaultMaxPreviewReviews = 2;
  
  // Review Page Strings
  static const String reviewsTitle = 'Reviews';
  static const String addReviewFabLabel = 'Add Review';
  static const String failedToLoadReviewsTitle = 'Failed to load reviews';
  static const String retryButtonText = 'Retry';
  static const String loadReviewsTitle = 'Load Reviews';
  static const String loadReviewsSubtitle = 'Tap to see what others think about this book';
  static const String loadReviewsButtonText = 'Load Reviews';
  static const String noReviewsYetTitle = 'No Reviews Yet';
  static const String noReviewsYetSubtitle = 'Be the first to review this book!';
  static const String addFirstReviewButtonText = 'Add First Review';
  static const String addYourReviewTitle = 'Add Your Review';
  static const String ratingLabel = 'Rating';
  static const String reviewLabel = 'Review';
  static const String reviewHintText = 'Share your thoughts about this book...';
  static const String submitReviewButtonText = 'Submit Review';
  static const String reviewSubmittedMessage = 'Review submitted successfully!';
  static const String viewAllReviewsButtonText = 'View All Reviews';
  static const String basedOnReviewsText = 'Based on';
  static const String reviewSingular = 'review';
  static const String reviewPlural = 'reviews';
  static const String todayText = 'Today';
  static const String yesterdayText = 'Yesterday';
  static const String daysAgoSuffix = 'days ago';
}
