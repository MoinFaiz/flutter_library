import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/book_details/presentation/widgets/book_info_section.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';
import 'package:flutter_library/shared/widgets/rating_display.dart';

void main() {
  group('BookInfoSection Tests', () {
    final testBook = Book(
      id: '1',
      title: 'Test Book Title',
      author: 'Test Author Name',
      imageUrls: const ['https://example.com/book.jpg'],
      rating: 4.5,
      pricing: const BookPricing(
        salePrice: 19.99,
        rentPrice: 4.99,
      ),
      availability: const BookAvailability(
        availableForRentCount: 2,
        availableForSaleCount: 1,
        totalCopies: 5,
      ),
      metadata: const BookMetadata(
        isbn: '1234567890',
        publisher: 'Test Publisher',
        ageAppropriateness: AgeAppropriateness.adult,
        genres: ['Fiction', 'Mystery'],
        pageCount: 300,
        language: 'English',
      ),
      isFromFriend: false,
      isFavorite: false,
      description: 'A test book description',
      publishedYear: 2023,
      createdAt: DateTime(2023, 1, 1),
      updatedAt: DateTime(2023, 1, 1),
    );

    Widget createTestWidget({required Book book}) {
      return MaterialApp(
        home: Scaffold(
          body: BookInfoSection(book: book),
        ),
      );
    }

    testWidgets('displays book title correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(book: testBook));

      // Assert
      expect(find.text('Test Book Title'), findsOneWidget);
    });

    testWidgets('displays book author correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(book: testBook));

      // Assert
      expect(find.text('by Test Author Name'), findsOneWidget);
    });

    testWidgets('displays rating display widget', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(book: testBook));

      // Assert
      expect(find.byType(RatingDisplay), findsOneWidget);
    });

    testWidgets('displays book rating value', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(book: testBook));

      // Assert
      expect(find.textContaining('4.5'), findsOneWidget);
    });

    testWidgets('displays genres correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(book: testBook));

      // Assert - Genres are displayed as individual chips, not comma-separated
      expect(find.text('Fiction'), findsOneWidget);
      expect(find.text('Mystery'), findsOneWidget);
    });

    testWidgets('displays published year', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(book: testBook));

      // Assert
      expect(find.textContaining('Published 2023'), findsOneWidget);
    });

    testWidgets('has proper layout structure', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(book: testBook));

      // Assert
      expect(find.byType(Padding), findsAtLeastNWidgets(1));
      expect(find.byType(Column), findsAtLeastNWidgets(1));
    });

    testWidgets('displays availability information', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(book: testBook));

      // Assert
      expect(find.textContaining('Available'), findsOneWidget);
    });

    testWidgets('handles books with single genre', (WidgetTester tester) async {
      // Arrange
      final singleGenreBook = Book(
        id: '2',
        title: 'Single Genre Book',
        author: 'Another Author',
        imageUrls: const ['https://example.com/book2.jpg'],
        rating: 3.8,
        pricing: const BookPricing(
          salePrice: 15.99,
          rentPrice: 3.99,
        ),
        availability: const BookAvailability(
          availableForRentCount: 1,
          availableForSaleCount: 1,
          totalCopies: 2,
        ),
        metadata: const BookMetadata(
          ageAppropriateness: AgeAppropriateness.youngAdult,
          genres: ['Romance'],
          pageCount: 250,
          language: 'English',
        ),
        isFromFriend: false,
        isFavorite: false,
        description: 'A romance book',
        publishedYear: 2022,
        createdAt: DateTime(2022, 1, 1),
        updatedAt: DateTime(2022, 1, 1),
      );

      // Act
      await tester.pumpWidget(createTestWidget(book: singleGenreBook));

      // Assert
      expect(find.text('Romance'), findsOneWidget);
    });

    testWidgets('handles books without publisher', (WidgetTester tester) async {
      // Arrange
      final noPublisherBook = Book(
        id: '3',
        title: 'No Publisher Book',
        author: 'Independent Author',
        imageUrls: const ['https://example.com/book3.jpg'],
        rating: 4.2,
        pricing: const BookPricing(
          salePrice: 12.99,
          rentPrice: 2.99,
        ),
        availability: const BookAvailability(
          availableForRentCount: 3,
          availableForSaleCount: 2,
          totalCopies: 5,
        ),
        metadata: const BookMetadata(
          ageAppropriateness: AgeAppropriateness.adult,
          genres: ['Science Fiction'],
          pageCount: 400,
          language: 'English',
        ),
        isFromFriend: false,
        isFavorite: false,
        description: 'An independent sci-fi book',
        publishedYear: 2024,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      // Act
      await tester.pumpWidget(createTestWidget(book: noPublisherBook));

      // Assert
      expect(find.text('No Publisher Book'), findsOneWidget);
      expect(find.text('Independent Author'), findsNothing); // Should display as "by Independent Author"
      expect(find.text('by Independent Author'), findsOneWidget);
    });

    testWidgets('handles books with high ratings', (WidgetTester tester) async {
      // Arrange
      final highRatedBook = testBook.copyWith(rating: 5.0);

      // Act
      await tester.pumpWidget(createTestWidget(book: highRatedBook));

      // Assert
      expect(find.textContaining('5.0'), findsOneWidget);
    });

    testWidgets('handles books with low ratings', (WidgetTester tester) async {
      // Arrange
      final lowRatedBook = testBook.copyWith(rating: 1.5);

      // Act
      await tester.pumpWidget(createTestWidget(book: lowRatedBook));

      // Assert
      expect(find.textContaining('1.5'), findsOneWidget);
    });

    testWidgets('shows proper text styling', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(book: testBook));

      // Assert
      final titleText = tester.widget<Text>(find.text('Test Book Title'));
      expect(titleText.style?.fontWeight, equals(FontWeight.bold));
    });
  });
}
