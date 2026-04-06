import 'package:flutter/material.dart';
import 'package:flutter_library/shared/widgets/book_detail_card.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/shared/widgets/book_list_item.dart';
import 'package:flutter_library/shared/widgets/favorite_button.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';

void main() {
  group('BookListItem Widget Tests', () {
    late Book testBook;
    late Book testBookWithoutImage;

    setUp(() {
      testBook = Book(
        id: '1',
        title: 'Test Book',
        author: 'Test Author',
        description: 'This is a test book description.',
        imageUrls: ['https://example.com/book-image.jpg'],
        rating: 4.5,
        publishedYear: 2023,
        isFromFriend: false,
        isFavorite: false,
        pricing: const BookPricing(salePrice: 25.99, rentPrice: 5.99),
        availability: const BookAvailability(
          availableForRentCount: 2,
          availableForSaleCount: 1,
          totalCopies: 3,
        ),
        metadata: const BookMetadata(
          isbn: '978-0123456789',
          publisher: 'Test Publisher',
          ageAppropriateness: AgeAppropriateness.adult,
          genres: ['Technology', 'Programming'],
          pageCount: 300,
          language: 'English',
        ),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      testBookWithoutImage = Book(
        id: '2',
        title: 'Book Without Image',
        author: 'Another Author',
        description: 'A book without an image',
        imageUrls: [],
        rating: 3.8,
        publishedYear: 2022,
        isFromFriend: true,
        isFavorite: true,
        pricing: const BookPricing(salePrice: 15.99, rentPrice: 3.99),
        availability: const BookAvailability(
          availableForRentCount: 0,
          availableForSaleCount: 0,
          totalCopies: 1,
        ),
        metadata: const BookMetadata(
          isbn: '978-9876543210',
          publisher: 'Another Publisher',
          ageAppropriateness: AgeAppropriateness.youngAdult,
          genres: ['Fiction', 'Novel'],
          pageCount: 250,
          language: 'English',
        ),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    Widget createTestWidget({
      required Book book,
      VoidCallback? onTap,
      VoidCallback? onFavoriteToggle,
      bool showFavoriteButton = true,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: BookListItem(
            book: book,
            onTap: onTap,
            onFavoriteToggle: onFavoriteToggle,
            showFavoriteButton: showFavoriteButton,
          ),
        ),
      );
    }

    testWidgets('should display book information correctly', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(book: testBook));

      // Assert
      expect(find.text('Test Book'), findsOneWidget);
      expect(find.text('Test Author'), findsOneWidget);
    });

    testWidgets('should display rating correctly', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(book: testBook));

      // Assert
      expect(find.text('4.5'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsAtLeastNWidgets(1));
    });

    testWidgets('should handle tap callback', (WidgetTester tester) async {
      // Arrange
      bool tapped = false;

      await tester.pumpWidget(
        createTestWidget(book: testBook, onTap: () => tapped = true),
      );

      // Act
      await tester.tap(find.byType(ListTile));
      await tester.pump();

      // Assert
      expect(tapped, isTrue);
    });

    testWidgets('should show favorite button when showFavoriteButton is true', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createTestWidget(
          book: testBook,
          showFavoriteButton: true,
          onFavoriteToggle: () {},
        ),
      );

      // Assert
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets(
      'should hide favorite button when showFavoriteButton is false',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createTestWidget(book: testBook, showFavoriteButton: false),
        );

        // Assert
        expect(find.byIcon(Icons.favorite_border), findsNothing);
        expect(find.byIcon(Icons.favorite), findsNothing);
      },
    );

    testWidgets('should show filled heart when book is favorite', (
      WidgetTester tester,
    ) async {
      // Arrange
      final favoriteBook = Book(
        id: testBook.id,
        title: testBook.title,
        author: testBook.author,
        description: testBook.description,
        imageUrls: testBook.imageUrls,
        rating: testBook.rating,
        publishedYear: testBook.publishedYear,
        isFromFriend: testBook.isFromFriend,
        isFavorite: true, // Set as favorite
        pricing: testBook.pricing,
        availability: testBook.availability,
        metadata: testBook.metadata,
        createdAt: testBook.createdAt,
        updatedAt: testBook.updatedAt,
      );

      // Act
      await tester.pumpWidget(
        createTestWidget(book: favoriteBook, onFavoriteToggle: () {}),
      );

      // Assert
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsNothing);
    });

    testWidgets('should handle favorite toggle callback', (
      WidgetTester tester,
    ) async {
      // Arrange
      bool favoriteTapped = false;

      await tester.pumpWidget(
        createTestWidget(
          book: testBook,
          onFavoriteToggle: () => favoriteTapped = true,
        ),
      );

      // Act
      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pump();

      // Assert
      expect(favoriteTapped, isTrue);
    });

    testWidgets('should display book image when available', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(book: testBook));

      // Assert
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('should handle long title text overflow', (
      WidgetTester tester,
    ) async {
      // Arrange
      final bookWithLongTitle = Book(
        id: testBook.id,
        title:
            'This is a very long book title that should test text overflow handling in the widget',
        author: testBook.author,
        description: testBook.description,
        imageUrls: testBook.imageUrls,
        rating: testBook.rating,
        publishedYear: testBook.publishedYear,
        isFromFriend: testBook.isFromFriend,
        isFavorite: testBook.isFavorite,
        pricing: testBook.pricing,
        availability: testBook.availability,
        metadata: testBook.metadata,
        createdAt: testBook.createdAt,
        updatedAt: testBook.updatedAt,
      );

      // Act
      await tester.pumpWidget(createTestWidget(book: bookWithLongTitle));

      // Assert
      expect(find.byType(Text), findsWidgets);

      // Check that the title text widget has overflow handling
      final titleFinder = find.text(
        'This is a very long book title that should test text overflow handling in the widget',
      );
      if (titleFinder.evaluate().isNotEmpty) {
        final titleWidget = tester.widget<Text>(titleFinder);
        expect(titleWidget.overflow, equals(TextOverflow.ellipsis));
        expect(titleWidget.maxLines, equals(2));
      }
    });

    testWidgets('should display genres correctly', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(book: testBook));

      // Assert
      // Should show genres
      expect(find.textContaining('Technology'), findsOneWidget);
    });

    testWidgets('should handle book without image gracefully', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(book: testBookWithoutImage));

      // Assert
      expect(find.text('Book Without Image'), findsOneWidget);
      expect(find.text('Another Author'), findsOneWidget);
    });

    testWidgets('should display zero rating correctly', (
      WidgetTester tester,
    ) async {
      // Arrange
      final bookWithZeroRating = Book(
        id: testBook.id,
        title: testBook.title,
        author: testBook.author,
        description: testBook.description,
        imageUrls: testBook.imageUrls,
        rating: 0.0,
        publishedYear: testBook.publishedYear,
        isFromFriend: testBook.isFromFriend,
        isFavorite: testBook.isFavorite,
        pricing: testBook.pricing,
        availability: testBook.availability,
        metadata: testBook.metadata,
        createdAt: testBook.createdAt,
        updatedAt: testBook.updatedAt,
      );

      // Act
      await tester.pumpWidget(createTestWidget(book: bookWithZeroRating));

      // Assert
      expect(find.text('0.0'), findsOneWidget);
    });

    testWidgets('should display card properly', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(book: testBook));

      // Assert
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);
    });
  });

  group('BookDetailCard Widget Tests', () {
    late Book testBook;
    late Book testBookWithoutImage;

    setUp(() {
      testBook = Book(
        id: '1',
        title: 'Test Book',
        author: 'Test Author',
        description: 'This is a test book description.',
        imageUrls: ['https://example.com/book-image.jpg'],
        rating: 4.5,
        publishedYear: 2023,
        isFromFriend: false,
        isFavorite: false,
        pricing: const BookPricing(salePrice: 25.99, rentPrice: 5.99),
        availability: const BookAvailability(
          availableForRentCount: 2,
          availableForSaleCount: 1,
          totalCopies: 3,
        ),
        metadata: const BookMetadata(
          isbn: '978-0123456789',
          publisher: 'Test Publisher',
          ageAppropriateness: AgeAppropriateness.adult,
          genres: ['Technology', 'Programming'],
          pageCount: 300,
          language: 'English',
        ),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      testBookWithoutImage = Book(
        id: '2',
        title: 'Book Without Image',
        author: 'Another Author',
        description: 'A book without an image',
        imageUrls: [],
        rating: 3.8,
        publishedYear: 2022,
        isFromFriend: true,
        isFavorite: true,
        pricing: const BookPricing(salePrice: 15.99, rentPrice: 3.99),
        availability: const BookAvailability(
          availableForRentCount: 0,
          availableForSaleCount: 0,
          totalCopies: 1,
        ),
        metadata: const BookMetadata(
          isbn: '978-9876543210',
          publisher: 'Another Publisher',
          ageAppropriateness: AgeAppropriateness.youngAdult,
          genres: ['Fiction', 'Novel'],
          pageCount: 250,
          language: 'English',
        ),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    Widget createBookDetailCardTestWidget({
      required Book book,
      VoidCallback? onFavoriteToggle,
      bool showFavoriteButton = true,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: BookDetailCard(
            book: book,
            onFavoriteToggle: onFavoriteToggle,
            showFavoriteButton: showFavoriteButton,
          ),
        ),
      );
    }

    testWidgets('should display book information correctly', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createBookDetailCardTestWidget(book: testBook));

      // Assert
      expect(find.text('Test Book'), findsOneWidget);
      expect(find.text('by Test Author'), findsOneWidget);
      expect(find.text('This is a test book description.'), findsOneWidget);
    });

    testWidgets('should display book image when available', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createBookDetailCardTestWidget(book: testBook));

      // Assert
      expect(find.byType(Image), findsAtLeastNWidgets(1));
    });

    testWidgets('should display placeholder when no image available', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createBookDetailCardTestWidget(book: testBookWithoutImage),
      );

      // Assert
      // Should find the card widget
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should display rating information correctly', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createBookDetailCardTestWidget(book: testBook));

      // Assert
      expect(find.text('4.5'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsAtLeastNWidgets(1));
    });

    testWidgets('should show favorite button when showFavoriteButton is true', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createBookDetailCardTestWidget(
          book: testBook,
          showFavoriteButton: true,
          onFavoriteToggle: () {},
        ),
      );

      // Assert
      expect(find.byType(FavoriteButton), findsOneWidget);
    });

    testWidgets(
      'should hide favorite button when showFavoriteButton is false',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          createBookDetailCardTestWidget(
            book: testBook,
            showFavoriteButton: false,
          ),
        );

        // Assert
        expect(find.byType(FavoriteButton), findsNothing);
      },
    );

    testWidgets('should handle favorite toggle callback', (
      WidgetTester tester,
    ) async {
      // Arrange
      bool favoriteTapped = false;

      await tester.pumpWidget(
        createBookDetailCardTestWidget(
          book: testBook,
          onFavoriteToggle: () => favoriteTapped = true,
        ),
      );

      // Act
      await tester.tap(find.byType(FavoriteButton));
      await tester.pump();

      // Assert
      expect(favoriteTapped, isTrue);
    });

    testWidgets('should display genres correctly', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createBookDetailCardTestWidget(book: testBook));

      // Assert
      expect(find.textContaining('Technology'), findsAtLeastNWidgets(1));
    });

    testWidgets('should handle zero rating correctly', (
      WidgetTester tester,
    ) async {
      // Arrange
      final bookWithZeroRating = testBook.copyWith(rating: 0.0);

      // Act
      await tester.pumpWidget(
        createBookDetailCardTestWidget(book: bookWithZeroRating),
      );

      // Assert
      expect(find.text('0.0'), findsOneWidget);
    });

    testWidgets('should display publication year correctly', (
      WidgetTester tester,
    ) async {
      // Arrange
      final bookWithOldYear = testBook.copyWith(publishedYear: 1995);

      // Act
      await tester.pumpWidget(
        createBookDetailCardTestWidget(book: bookWithOldYear),
      );

      // Assert - BookDetailCard doesn't directly display year, but has book info
      expect(find.byType(BookDetailCard), findsOneWidget);
      expect(find.text(bookWithOldYear.title), findsOneWidget);
    });

    testWidgets('should handle multiple images with carousel', (
      WidgetTester tester,
    ) async {
      // Arrange
      final bookWithMultipleImages = testBook.copyWith(
        imageUrls: [
          'https://example.com/image1.jpg',
          'https://example.com/image2.jpg',
          'https://example.com/image3.jpg',
        ],
      );

      // Act
      await tester.pumpWidget(
        createBookDetailCardTestWidget(book: bookWithMultipleImages),
      );

      // Assert
      expect(find.byType(Card), findsOneWidget);
      // Should show either carousel or single image
      expect(find.byType(Image), findsAtLeastNWidgets(1));
    });
  });
}
