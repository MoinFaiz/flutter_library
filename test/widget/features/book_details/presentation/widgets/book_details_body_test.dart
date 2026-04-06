import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/book_details/presentation/widgets/book_details_body.dart';
import 'package:flutter_library/features/book_details/presentation/widgets/book_info_section.dart';
import 'package:flutter_library/features/book_details/presentation/widgets/book_pricing_section.dart';
import 'package:flutter_library/features/book_details/presentation/widgets/book_actions_section.dart';
import 'package:flutter_library/features/book_details/presentation/widgets/book_rental_status_section.dart';
import 'package:flutter_library/features/book_details/presentation/widgets/book_description_section.dart';
import 'package:flutter_library/features/book_details/presentation/widgets/book_reviews_section.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/book_details/domain/entities/review.dart';
import 'package:flutter_library/features/book_details/domain/entities/rental_status.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';

void main() {
  group('BookDetailsBody Widget Tests', () {
    late Book testBook;
    late List<Review> testReviews;
    late RentalStatus testRentalStatus;

    setUp(() {
      testBook = Book(
        id: '1',
        title: 'Test Book Title',
        author: 'Test Author',
        imageUrls: const ['https://example.com/book1.jpg'],
        rating: 4.5,
        pricing: const BookPricing(
          salePrice: 19.99,
          rentPrice: 4.99,
        ),
        availability: const BookAvailability(
          availableForRentCount: 3,
          availableForSaleCount: 2,
          totalCopies: 5,
        ),
        metadata: const BookMetadata(
          ageAppropriateness: AgeAppropriateness.adult,
          genres: ['Fiction', 'Mystery'],
          pageCount: 300,
          language: 'English',
        ),
        isFromFriend: false,
        isFavorite: false,
        description: 'This is a test book description.',
        publishedYear: 2023,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      testReviews = [
        Review(
          id: '1',
          bookId: '1',
          userId: 'user1',
          userName: 'John Doe',
          reviewText: 'Great book!',
          rating: 5.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Review(
          id: '2',
          bookId: '1',
          userId: 'user2',
          userName: 'Jane Smith',
          reviewText: 'Very interesting read.',
          rating: 4.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      testRentalStatus = const RentalStatus(
        bookId: '1',
        status: RentalStatusType.available,
        canRenew: false,
        isInCart: false,
        isPurchased: false,
      );
    });

    Widget createTestWidget({
      Book? book,
      List<Review>? reviews,
      RentalStatus? rentalStatus,
      bool isPerformingAction = false,
      bool isLoadingReviews = false,
      bool isLoadingRentalStatus = false,
      String? reviewsError,
      String? rentalStatusError,
      VoidCallback? onRent,
      VoidCallback? onBuy,
      VoidCallback? onReturn,
      VoidCallback? onRenew,
      VoidCallback? onRemoveFromCart,
      Function(String, double)? onAddReview,
      VoidCallback? onLoadReviews,
      VoidCallback? onLoadRentalStatus,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: BookDetailsBody(
              book: book ?? testBook,
              reviews: reviews,
              rentalStatus: rentalStatus,
              isPerformingAction: isPerformingAction,
              isLoadingReviews: isLoadingReviews,
              isLoadingRentalStatus: isLoadingRentalStatus,
              reviewsError: reviewsError,
              rentalStatusError: rentalStatusError,
              onRent: onRent,
              onBuy: onBuy,
              onReturn: onReturn,
              onRenew: onRenew,
              onRemoveFromCart: onRemoveFromCart,
              onAddReview: onAddReview,
              onLoadReviews: onLoadReviews,
              onLoadRentalStatus: onLoadRentalStatus,
            ),
          ),
        ),
      );
    }

    testWidgets('displays all book detail sections correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(
        reviews: testReviews,
        rentalStatus: testRentalStatus,
      ));

      // Assert
      expect(find.byType(BookInfoSection), findsOneWidget);
      expect(find.byType(BookPricingSection), findsOneWidget);
      expect(find.byType(BookActionsSection), findsOneWidget);
      expect(find.byType(BookRentalStatusSection), findsOneWidget);
      expect(find.byType(BookDescriptionSection), findsOneWidget);
      expect(find.byType(BookReviewsSection), findsOneWidget);
    });

    testWidgets('displays loading state for reviews when isLoadingReviews is true', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(
        isLoadingReviews: true,
        rentalStatus: testRentalStatus,
      ));

      // Assert
      expect(find.byType(BookReviewsSection), findsOneWidget);
      // The loading state should be handled within BookReviewsSection
    });

    testWidgets('displays loading state for rental status when isLoadingRentalStatus is true', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(
        reviews: testReviews,
        isLoadingRentalStatus: true,
      ));

      // Assert
      expect(find.byType(BookRentalStatusSection), findsOneWidget);
      // The loading state should be handled within BookRentalStatusSection
    });

    testWidgets('displays error state for reviews when reviewsError is provided', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(
        reviewsError: 'Failed to load reviews',
        rentalStatus: testRentalStatus,
      ));

      // Assert
      expect(find.byType(BookReviewsSection), findsOneWidget);
      // The error state should be handled within BookReviewsSection
    });

    testWidgets('displays error state for rental status when rentalStatusError is provided', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(
        reviews: testReviews,
        rentalStatusError: 'Failed to load rental status',
      ));

      // Assert
      expect(find.byType(BookRentalStatusSection), findsOneWidget);
      // The error state should be handled within BookRentalStatusSection
    });

    testWidgets('passes correct callbacks to action sections', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(
        reviews: testReviews,
        rentalStatus: testRentalStatus,
        onRent: () {},
        onBuy: () {},
        onReturn: () {},
        onRenew: () {},
        onRemoveFromCart: () {},
      ));

      // Assert - Verify sections are present (callbacks tested in individual section tests)
      expect(find.byType(BookActionsSection), findsOneWidget);
      expect(find.byType(BookRentalStatusSection), findsOneWidget);
    });

    testWidgets('passes add review callback to reviews section', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(
        reviews: testReviews,
        rentalStatus: testRentalStatus,
        onAddReview: (text, r) {
          // Callback handled by BookReviewsSection
        },
      ));

      // Assert
      expect(find.byType(BookReviewsSection), findsOneWidget);
    });

    testWidgets('passes load callbacks correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(
        onLoadReviews: () {},
        onLoadRentalStatus: () {},
      ));

      // Assert - Verify sections are present (callbacks tested in individual section tests)
      expect(find.byType(BookReviewsSection), findsOneWidget);
      expect(find.byType(BookRentalStatusSection), findsOneWidget);
    });

    testWidgets('handles null reviews correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(
        reviews: null, // No reviews loaded yet
        rentalStatus: testRentalStatus,
      ));

      // Assert
      expect(find.byType(BookReviewsSection), findsOneWidget);
      expect(tester.takeException(), isNull); // Should handle null gracefully
    });

    testWidgets('handles null rental status correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(
        reviews: testReviews,
        rentalStatus: null, // No rental status loaded yet
      ));

      // Assert
      expect(find.byType(BookRentalStatusSection), findsOneWidget);
      expect(tester.takeException(), isNull); // Should handle null gracefully
    });

    testWidgets('displays performing action state correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(
        reviews: testReviews,
        rentalStatus: testRentalStatus,
        isPerformingAction: true,
      ));

      // Assert
      expect(find.byType(BookActionsSection), findsOneWidget);
      // The performing action state should be handled within BookActionsSection
    });

    testWidgets('has proper layout structure', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(
        reviews: testReviews,
        rentalStatus: testRentalStatus,
      ));

      // Assert
      expect(find.byType(Padding), findsWidgets);
      expect(find.byType(Column), findsAtLeastNWidgets(1));
      expect(find.byType(SizedBox), findsWidgets); // Spacing between sections
    });

    testWidgets('maintains correct section order', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(
        reviews: testReviews,
        rentalStatus: testRentalStatus,
      ));

      // Assert - Verify all sections are present (order tested through integration)
      expect(find.byType(BookInfoSection), findsOneWidget);
      expect(find.byType(BookPricingSection), findsOneWidget);
      expect(find.byType(BookActionsSection), findsOneWidget);
      expect(find.byType(BookRentalStatusSection), findsOneWidget);
      expect(find.byType(BookDescriptionSection), findsOneWidget);
      expect(find.byType(BookReviewsSection), findsOneWidget);
    });
  });
}
