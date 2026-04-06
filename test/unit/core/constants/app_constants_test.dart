import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/core/constants/app_constants.dart';

void main() {
  group('AppConstants Tests', () {
    group('App Info', () {
      test('should have correct app name', () {
        expect(AppConstants.appName, equals('Library App'));
      });

      test('should have correct app version', () {
        expect(AppConstants.appVersion, equals('1.0.0'));
      });
    });

    group('Storage Keys', () {
      test('should have correct theme key', () {
        expect(AppConstants.themeKey, equals('theme_mode'));
      });

      test('should have correct favorites key', () {
        expect(AppConstants.favoritesKey, equals('favorites'));
      });
    });

    group('API Constants', () {
      test('should have valid base URL', () {
        expect(AppConstants.baseUrl, isNotEmpty);
        expect(AppConstants.baseUrl, contains('https://'));
      });

      test('should have reasonable request timeout', () {
        expect(AppConstants.requestTimeout, greaterThan(0));
        expect(AppConstants.requestTimeout, equals(30000));
      });
    });

    group('UI Constants', () {
      test('should have positive padding values', () {
        expect(AppConstants.defaultPadding, greaterThan(0));
        expect(AppConstants.smallPadding, greaterThan(0));
        expect(AppConstants.largePadding, greaterThan(0));
        expect(AppConstants.smallPadding, lessThan(AppConstants.defaultPadding));
        expect(AppConstants.largePadding, greaterThan(AppConstants.defaultPadding));
      });

      test('should have positive dimension values', () {
        expect(AppConstants.borderRadius, greaterThan(0));
        expect(AppConstants.iconSize, greaterThan(0));
        expect(AppConstants.ratingSize, greaterThan(0));
      });

      test('should have correct book card dimensions', () {
        expect(AppConstants.horizontalBookCardWidth, greaterThan(0));
        expect(AppConstants.horizontalBookCardHeight, greaterThan(0));
        expect(AppConstants.horizontalBookCardAspectRatio, greaterThan(0));
        expect(AppConstants.horizontalBookCardAspectRatio, lessThan(1));
      });

      test('should have positive skeleton dimensions', () {
        expect(AppConstants.skeletonTitleHeight, greaterThan(0));
        expect(AppConstants.skeletonSubtitleHeight, greaterThan(0));
        expect(AppConstants.skeletonRatingHeight, greaterThan(0));
        expect(AppConstants.skeletonBorderRadius, greaterThanOrEqualTo(0));
      });

      test('should have valid grid constants', () {
        expect(AppConstants.gridCrossAxisCount, greaterThan(0));
        expect(AppConstants.gridAspectRatio, greaterThan(0));
        expect(AppConstants.gridSpacing, greaterThanOrEqualTo(0));
      });
    });

    group('Animation Durations', () {
      test('should have increasing duration values', () {
        expect(AppConstants.shortDuration.inMilliseconds, lessThan(AppConstants.mediumDuration.inMilliseconds));
        expect(AppConstants.mediumDuration.inMilliseconds, lessThan(AppConstants.longDuration.inMilliseconds));
      });

      test('should have reasonable duration values', () {
        expect(AppConstants.shortDuration.inMilliseconds, equals(200));
        expect(AppConstants.mediumDuration.inMilliseconds, equals(300));
        expect(AppConstants.longDuration.inMilliseconds, equals(500));
      });
    });

    group('Error Messages', () {
      test('should have non-empty error messages', () {
        expect(AppConstants.noInternetError, isNotEmpty);
        expect(AppConstants.serverError, isNotEmpty);
        expect(AppConstants.unknownError, isNotEmpty);
        expect(AppConstants.noDataError, isNotEmpty);
        expect(AppConstants.loadingError, isNotEmpty);
      });

      test('should have descriptive error messages', () {
        expect(AppConstants.noInternetError.toLowerCase(), contains('internet'));
        expect(AppConstants.serverError.toLowerCase(), contains('server'));
        expect(AppConstants.loadingError.toLowerCase(), contains('load'));
      });
    });

    group('Library Page Strings', () {
      test('should have non-empty library strings', () {
        expect(AppConstants.myLibraryTitle, isNotEmpty);
        expect(AppConstants.borrowedBooksTitle, isNotEmpty);
        expect(AppConstants.myUploadedBooksTitle, isNotEmpty);
        expect(AppConstants.loadingLibraryMessage, isNotEmpty);
      });

      test('should have appropriate button text', () {
        expect(AppConstants.tryAgainButton, isNotEmpty);
        expect(AppConstants.moreButton, isNotEmpty);
      });
    });

    group('Review Page Constants', () {
      test('should have positive review dimensions', () {
        expect(AppConstants.reviewBookCoverWidth, greaterThan(0));
        expect(AppConstants.reviewBookCoverHeight, greaterThan(0));
        expect(AppConstants.reviewAvatarRadius, greaterThan(0));
        expect(AppConstants.reviewStarSize, greaterThan(0));
      });

      test('should have valid modal size values', () {
        expect(AppConstants.reviewModalInitialSize, greaterThan(0));
        expect(AppConstants.reviewModalInitialSize, lessThanOrEqualTo(1));
        expect(AppConstants.reviewModalMaxSize, greaterThan(AppConstants.reviewModalInitialSize));
        expect(AppConstants.reviewModalMinSize, lessThan(AppConstants.reviewModalInitialSize));
      });

      test('should have reasonable review text field max lines', () {
        expect(AppConstants.reviewTextFieldMaxLines, greaterThan(0));
        expect(AppConstants.reviewTextFieldMaxLines, equals(6));
      });

      test('should have reasonable default max preview reviews', () {
        expect(AppConstants.defaultMaxPreviewReviews, greaterThan(0));
        expect(AppConstants.defaultMaxPreviewReviews, equals(2));
      });
    });

    group('Review Page Strings', () {
      test('should have non-empty review strings', () {
        expect(AppConstants.reviewsTitle, isNotEmpty);
        expect(AppConstants.addReviewFabLabel, isNotEmpty);
        expect(AppConstants.submitReviewButtonText, isNotEmpty);
      });

      test('should have singular and plural review text', () {
        expect(AppConstants.reviewSingular, equals('review'));
        expect(AppConstants.reviewPlural, equals('reviews'));
      });

      test('should have time-related strings', () {
        expect(AppConstants.todayText, equals('Today'));
        expect(AppConstants.yesterdayText, equals('Yesterday'));
        expect(AppConstants.daysAgoSuffix, isNotEmpty);
      });
    });

    group('Repository Error Messages', () {
      test('should have non-empty repository error messages', () {
        expect(AppConstants.failedToGetBorrowedBooksError, isNotEmpty);
        expect(AppConstants.failedToGetUploadedBooksError, isNotEmpty);
        expect(AppConstants.failedToGetAllBorrowedBooksError, isNotEmpty);
        expect(AppConstants.failedToGetAllUploadedBooksError, isNotEmpty);
      });

      test('should contain descriptive error information', () {
        expect(AppConstants.failedToGetBorrowedBooksError.toLowerCase(), contains('borrowed'));
        expect(AppConstants.failedToGetUploadedBooksError.toLowerCase(), contains('uploaded'));
      });
    });

    group('Additional UI Strings', () {
      test('should have success messages', () {
        expect(AppConstants.addedToFavoritesMessage, isNotEmpty);
        expect(AppConstants.removedFromFavoritesMessage, isNotEmpty);
        expect(AppConstants.reviewSubmittedMessage, isNotEmpty);
      });

      test('should have helpful empty state messages', () {
        expect(AppConstants.noBooksYetTitle, isNotEmpty);
        expect(AppConstants.noBorrowedBooksMessage, isNotEmpty);
        expect(AppConstants.noUploadedBooksMessage, isNotEmpty);
      });
    });
  });
}
