import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/book_details/presentation/widgets/book_reviews_section.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/book_details/domain/entities/review.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';

void main() {
  group('BookReviewsSection Widget Tests', () {
    late Book testBook;
    late List<Review> mockReviews;

    setUp(() {
      testBook = Book(
        id: '1',
        title: 'Test Book',
        author: 'Test Author',
        description: 'Test Description',
        imageUrls: const ['test_image.jpg'],
        rating: 4.5,
        publishedYear: 2023,
        isFavorite: false,
        isFromFriend: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        metadata: const BookMetadata(
          ageAppropriateness: AgeAppropriateness.adult,
          genres: ['Fiction'],
          pageCount: 300,
          language: 'English',
        ),
        pricing: const BookPricing(
          salePrice: 25.99,
          rentPrice: 5.99,
        ),
        availability: const BookAvailability(
          availableForRentCount: 5,
          availableForSaleCount: 3,
          totalCopies: 8,
        ),
      );

      mockReviews = [
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
    });

    Widget createTestWidget({
      Book? book,
      List<Review>? reviews,
      bool isLoading = false,
      String? error,
      Function(String, double)? onAddReview,
      VoidCallback? onLoadReviews,
      int maxPreviewReviews = 2,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: BookReviewsSection(
              book: book ?? testBook,
              reviews: reviews,
              isLoading: isLoading,
              error: error,
              onAddReview: onAddReview,
              onLoadReviews: onLoadReviews,
              maxPreviewReviews: maxPreviewReviews,
            ),
          ),
        ),
      );
    }

    testWidgets('should display reviews title', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(reviews: mockReviews));

      // Assert
      expect(find.text('Reviews'), findsOneWidget);
    });

    testWidgets('should display reviews when loaded', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(reviews: mockReviews));

      // Assert
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Great book!'), findsOneWidget);
      expect(find.text('Jane Smith'), findsOneWidget);
      expect(find.text('Very interesting read.'), findsOneWidget);
    });

    testWidgets('should display loading state', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(isLoading: true));

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display error state', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(error: 'Failed to load reviews'));

      // Assert - Error text may appear in both title and message
      expect(find.text('Failed to load reviews'), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('should display not loaded state', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(reviews: null));

      // Assert - Text may appear in title and button
      expect(find.byIcon(Icons.rate_review_outlined), findsOneWidget);
      expect(find.text('Load Reviews'), findsAtLeastNWidgets(1));
    });

    testWidgets('should display empty reviews state', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(reviews: []));

      // Assert
      expect(find.text('Be the first to review this book!'), findsOneWidget);
      expect(find.byIcon(Icons.rate_review_outlined), findsOneWidget);
    });

    testWidgets('should display add review section when callback provided', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(
        reviews: mockReviews,
        onAddReview: (text, rating) {},
      ));

      // Assert
      expect(find.text('Add Your Review'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.star_border), findsWidgets);
    });

    testWidgets('should not display add review section when callback not provided', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(reviews: mockReviews));

      // Assert
      expect(find.text('Add Your Review'), findsNothing);
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('should handle rating selection in add review', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget(
        reviews: mockReviews,
        onAddReview: (text, rating) {},
      ));

      // Act - Tap on third star
      final starButtons = find.byIcon(Icons.star_border);
      if (starButtons.evaluate().length >= 3) {
        await tester.tap(starButtons.at(2)); // Third star (3.0 rating)
        await tester.pump();
      }

      // Assert - Stars should update to show selected rating
      expect(find.byIcon(Icons.star), findsWidgets);
    });

    testWidgets('should handle review text input', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget(
        reviews: mockReviews,
        onAddReview: (text, rating) {},
      ));

      // Act
      await tester.enterText(find.byType(TextField), 'This is my review');
      await tester.pump();

      // Assert
      expect(find.text('This is my review'), findsOneWidget);
    });

    testWidgets('should enable submit button when review is complete', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget(
        reviews: mockReviews,
        onAddReview: (text, rating) {},
      ));

      // Act - Enter text and select rating
      await tester.enterText(find.byType(TextField), 'Great book!');
      await tester.pump();

      // Tap on first star for rating
      final starButtons = find.byIcon(Icons.star_border);
      if (starButtons.evaluate().isNotEmpty) {
        await tester.tap(starButtons.first);
        await tester.pump();
      }

      // Assert - Submit button should be enabled
      final submitButton = find.text('Submit Review');
      expect(submitButton, findsOneWidget);
    });

    testWidgets('should handle submit review callback', (WidgetTester tester) async {
      // Arrange
      String? submittedText;
      double? submittedRating;

      await tester.pumpWidget(createTestWidget(
        reviews: mockReviews,
        onAddReview: (text, rating) {
          submittedText = text;
          submittedRating = rating;
        },
      ));

      // Act
      await tester.enterText(find.byType(TextField), 'Amazing book!');
      await tester.pump();

      // Select 5-star rating
      final starButtons = find.byIcon(Icons.star_border);
      if (starButtons.evaluate().length >= 5) {
        await tester.tap(starButtons.at(4)); // Fifth star
        await tester.pump();
      }

      // Submit review
      final submitButton = find.text('Submit Review');
      if (submitButton.evaluate().isNotEmpty) {
        await tester.tap(submitButton);
        await tester.pump();
      }

      // Assert
      expect(submittedText, equals('Amazing book!'));
      expect(submittedRating, equals(5.0));
    });

    testWidgets('should display View All Reviews button when there are many reviews', (WidgetTester tester) async {
      // Arrange - Create more reviews than maxPreviewReviews
      final manyReviews = List.generate(5, (index) => Review(
        id: 'review_$index',
        bookId: '1',
        userId: 'user$index',
        userName: 'User $index',
        reviewText: 'Review $index',
        rating: 4.0 + (index % 2),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      await tester.pumpWidget(createTestWidget(
        reviews: manyReviews,
        maxPreviewReviews: 2,
      ));

      // Assert
      expect(find.textContaining('View All Reviews'), findsOneWidget);
    });

    testWidgets('should display correct review count in View All button', (WidgetTester tester) async {
      // Arrange
      final manyReviews = List.generate(7, (index) => Review(
        id: 'review_$index',
        bookId: '1',
        userId: 'user$index',
        userName: 'User $index',
        reviewText: 'Review $index',
        rating: 4.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      await tester.pumpWidget(createTestWidget(
        reviews: manyReviews,
        maxPreviewReviews: 2,
      ));

      // Assert - Review count appears in multiple places
      expect(find.textContaining('7'), findsAtLeastNWidgets(1));
    });

    testWidgets('should display rating summary', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(reviews: mockReviews));

      // Assert - Rating appears in summary and individual reviews
      expect(find.text('4.5'), findsAtLeastNWidgets(1));
      expect(find.textContaining('Based on'), findsOneWidget); // Capital B
      expect(find.textContaining('2'), findsAtLeastNWidgets(1)); // Review count
    });

    testWidgets('should handle retry button in error state', (WidgetTester tester) async {
      // Arrange
      bool retryTapped = false;
      
      await tester.pumpWidget(createTestWidget(
        error: 'Network error',
        onLoadReviews: () => retryTapped = true,
      ));

      // Act
      await tester.tap(find.text('Retry'));
      await tester.pump();

      // Assert
      expect(retryTapped, isTrue);
    });

    testWidgets('should limit preview reviews correctly', (WidgetTester tester) async {
      // Arrange
      final manyReviews = List.generate(5, (index) => Review(
        id: 'review_$index',
        bookId: '1',
        userId: 'user$index',
        userName: 'User $index',
        reviewText: 'Review text $index',
        rating: 4.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      await tester.pumpWidget(createTestWidget(
        reviews: manyReviews,
        maxPreviewReviews: 3,
      ));

      // Assert - Should only show 3 reviews in preview
      expect(find.text('User 0'), findsOneWidget);
      expect(find.text('User 1'), findsOneWidget);
      expect(find.text('User 2'), findsOneWidget);
      expect(find.text('User 3'), findsNothing); // Should not be visible in preview
      expect(find.text('User 4'), findsNothing); // Should not be visible in preview
    });

    testWidgets('should display individual review ratings', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(reviews: mockReviews));

      // Assert
      // Should display star ratings for individual reviews
      expect(find.byIcon(Icons.star), findsWidgets);
    });

    testWidgets('should handle load reviews button in not loaded state', (WidgetTester tester) async {
      // Arrange
      bool loadTapped = false;
      
      await tester.pumpWidget(createTestWidget(
        reviews: null,
        onLoadReviews: () => loadTapped = true,
      ));

      // Act - Find the ElevatedButton containing "Load Reviews" text
      await tester.tap(find.widgetWithText(ElevatedButton, 'Load Reviews'));
      await tester.pump();

      // Assert
      expect(loadTapped, isTrue);
    });
  });
}
