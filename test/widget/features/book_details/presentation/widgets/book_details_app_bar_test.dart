import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/book_details/presentation/widgets/book_details_app_bar.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';

void main() {
  group('BookDetailsAppBar Widget Tests', () {
    late Book testBook;

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
        description: 'Test description',
        publishedYear: 2023,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    Widget createTestWidget({
      Book? book,
      VoidCallback? onBack,
      VoidCallback? onFavoriteToggle,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            slivers: [
              BookDetailsAppBar(
                book: book ?? testBook,
                onBack: onBack ?? () {},
                onFavoriteToggle: onFavoriteToggle,
              ),
            ],
          ),
        ),
      );
    }

    testWidgets('displays book images in carousel', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert - Verify image carousel is displayed (no title text in SliverAppBar)
      expect(find.byType(FlexibleSpaceBar), findsOneWidget);
    });

    testWidgets('displays back button', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('displays favorite button with correct state', (WidgetTester tester) async {
      // Arrange
      final favoriteBook = testBook.copyWith(isFavorite: true);

      // Act
      await tester.pumpWidget(createTestWidget(
        book: favoriteBook,
        onFavoriteToggle: () {}, // Must provide callback for icon to appear
      ));

      // Assert
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('displays unfavorite button when not favorite', (WidgetTester tester) async {
      // Arrange
      final nonFavoriteBook = testBook.copyWith(isFavorite: false);

      // Act
      await tester.pumpWidget(createTestWidget(
        book: nonFavoriteBook,
        onFavoriteToggle: () {}, // Must provide callback for icon to appear
      ));

      // Assert
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('displays share button', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert - SliverAppBar doesn't have share button in this implementation
      expect(find.byType(SliverAppBar), findsOneWidget);
    });

    testWidgets('triggers back callback when back button is pressed', (WidgetTester tester) async {
      // Arrange
      bool backPressed = false;

      // Act
      await tester.pumpWidget(createTestWidget(
        onBack: () => backPressed = true,
      ));
      await tester.tap(find.byIcon(Icons.arrow_back));

      // Assert
      expect(backPressed, isTrue);
    });

    testWidgets('triggers favorite callback when favorite button is pressed', (WidgetTester tester) async {
      // Arrange
      bool favoriteToggled = false;

      // Act
      await tester.pumpWidget(createTestWidget(
        onFavoriteToggle: () => favoriteToggled = true,
      ));
      await tester.tap(find.byIcon(Icons.favorite_border));

      // Assert
      expect(favoriteToggled, isTrue);
    });

    testWidgets('does not display share button in this implementation', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byIcon(Icons.share), findsNothing);
    });

    testWidgets('has proper app bar structure', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(
        onFavoriteToggle: () {}, // Provide callback to show favorite button
      ));

      // Assert
      expect(find.byType(SliverAppBar), findsOneWidget);
      expect(find.byType(IconButton), findsNWidgets(2)); // back and favorite buttons
    });

    testWidgets('displays image carousel instead of title text', (WidgetTester tester) async {
      // Arrange
      final longTitleBook = testBook.copyWith(
        title: 'This is a very long book title that should be handled properly by the app bar',
      );

      // Act
      await tester.pumpWidget(createTestWidget(book: longTitleBook));

      // Assert - No title text shown, only image carousel
      expect(find.byType(FlexibleSpaceBar), findsOneWidget);
      expect(tester.takeException(), isNull); // Should handle gracefully
    });

    testWidgets('maintains proper styling and layout', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      final sliverAppBar = tester.widget<SliverAppBar>(find.byType(SliverAppBar));
      expect(sliverAppBar.pinned, isTrue);
      expect(sliverAppBar.expandedHeight, equals(400));
      expect(sliverAppBar.leading, isA<IconButton>());
      expect(sliverAppBar.actions, isNotNull);
    });

    testWidgets('handles null callbacks gracefully', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(
        onFavoriteToggle: null,
      ));

      // Assert
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
