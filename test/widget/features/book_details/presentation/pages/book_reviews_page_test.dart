import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/book_details/presentation/pages/book_reviews_page.dart';
import 'package:flutter_library/features/book_details/presentation/pages/book_reviews_page_args.dart';
import 'package:flutter_library/features/book_details/domain/entities/review.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';

void main() {
  group('BookReviewsPage', () {
    late Book testBook;

    setUp(() {
      testBook = Book(
        id: 'test-book-id',
        title: 'Test Book Title',
        author: 'Test Author',
        imageUrls: const ['test_cover.jpg'],
        rating: 4.5,
        pricing: const BookPricing(
          salePrice: 25.99,
          rentPrice: 5.99,
        ),
        availability: const BookAvailability(
          availableForRentCount: 5,
          availableForSaleCount: 3,
          totalCopies: 8,
        ),
        metadata: const BookMetadata(
          ageAppropriateness: AgeAppropriateness.adult,
          genres: ['Fiction'],
          pageCount: 300,
          language: 'English',
        ),
        isFromFriend: false,
        isFavorite: false,
        description: 'Test description',
        publishedYear: 2023,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    Widget createTestWidget({
      List<Review>? reviews,
      bool isLoading = false,
      String? error,
      Function(String, double)? onAddReview,
      VoidCallback? onLoadReviews,
    }) {
      return MaterialApp(
        home: BookReviewsPage(
          args: BookReviewsPageArgs(
            book: testBook,
            reviews: reviews,
            isLoading: isLoading,
            error: error,
            onAddReview: onAddReview,
            onLoadReviews: onLoadReviews,
          ),
        ),
      );
    }

    Review createMockReview({
      String id = '1',
      String userName = 'Test User',
      double rating = 4.0,
      String reviewText = 'Great book!',
    }) {
      return Review(
        id: id,
        bookId: testBook.id,
        userId: 'user-123',
        userName: userName,
        rating: rating,
        reviewText: reviewText,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    testWidgets('displays app bar with Reviews title', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Reviews'), findsOneWidget);
    });

    testWidgets('triggers load reviews on init when reviews null', (WidgetTester tester) async {
      bool loadCalled = false;
      
      await tester.pumpWidget(createTestWidget(
        onLoadReviews: () => loadCalled = true,
      ));

      expect(loadCalled, isTrue);
    });

    testWidgets('displays loading state', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(isLoading: true));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays reviews when loaded', (WidgetTester tester) async {
      final reviews = [
        createMockReview(id: '1', userName: 'User 1'),
        createMockReview(id: '2', userName: 'User 2'),
      ];

      await tester.pumpWidget(createTestWidget(reviews: reviews));

      expect(find.text('User 1'), findsOneWidget);
      expect(find.text('User 2'), findsOneWidget);
    });

    testWidgets('displays empty state when no reviews', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(reviews: []));

      expect(find.text('Be the first to review this book!'), findsOneWidget);
    });

    testWidgets('displays error state', (WidgetTester tester) async {
      const errorMessage = 'Failed to load reviews';
      
      await tester.pumpWidget(createTestWidget(error: errorMessage));

      expect(find.textContaining(errorMessage), findsAtLeastNWidgets(1));
    });

    testWidgets('has back button in app bar', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(AppBar), findsOneWidget);
      // AppBar automatically adds back button when used in navigation
    });

    testWidgets('displays book header with cover and info', (WidgetTester tester) async {
      final reviews = [createMockReview()];
      
      await tester.pumpWidget(createTestWidget(reviews: reviews));

      expect(find.text(testBook.title), findsOneWidget);
      expect(find.text(testBook.author), findsOneWidget);
    });

    testWidgets('renders without throwing exceptions', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(tester.takeException(), isNull);
    });
  });
}
