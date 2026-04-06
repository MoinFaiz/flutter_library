import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/book_details/presentation/widgets/book_pricing_section.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';

void main() {
  group('BookPricingSection Tests', () {
    final testBook = Book(
      id: 'test_book_1',
      title: 'Test Book',
      author: 'Test Author',
      imageUrls: ['https://example.com/book.jpg'],
      rating: 4.5,
      pricing: const BookPricing(
        salePrice: 19.99,
        rentPrice: 4.99,
      ),
      availability: const BookAvailability(
        availableForRentCount: 3,
        availableForSaleCount: 2,
        totalCopies: 10,
      ),
      metadata: const BookMetadata(
        ageAppropriateness: AgeAppropriateness.adult,
        genres: ['Fiction', 'Mystery'],
        pageCount: 350,
        language: 'English',
      ),
      isFromFriend: false,
      isFavorite: false,
      description: 'A captivating mystery novel',
      publishedYear: 2023,
      createdAt: DateTime(2023, 1, 1),
      updatedAt: DateTime(2023, 1, 1),
    );

    final testBookUnavailable = Book(
      id: 'test_book_2',
      title: 'Unavailable Book',
      author: 'Test Author',
      imageUrls: ['https://example.com/book2.jpg'],
      rating: 4.0,
      pricing: const BookPricing(
        salePrice: 24.99,
        rentPrice: 5.99,
      ),
      availability: const BookAvailability(
        availableForRentCount: 0,
        availableForSaleCount: 0,
        totalCopies: 5,
      ),
      metadata: const BookMetadata(
        ageAppropriateness: AgeAppropriateness.adult,
        genres: ['Non-Fiction'],
        pageCount: 400,
        language: 'English',
      ),
      isFromFriend: false,
      isFavorite: false,
      description: 'An educational book',
      publishedYear: 2022,
      createdAt: DateTime(2022, 1, 1),
      updatedAt: DateTime(2022, 1, 1),
    );

    Widget createTestWidget({
      required Book book,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: BookPricingSection(
            book: book,
          ),
        ),
      );
    }

    testWidgets('displays sale price correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(book: testBook));

      // Assert
      expect(find.text('\$19.99'), findsOneWidget);
    });

    testWidgets('displays rent price correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(book: testBook));

      // Assert
      expect(find.text('\$4.99'), findsOneWidget);
    });

    testWidgets('shows buy pricing when book is available for sale', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(book: testBook));

      // Assert
      expect(find.text('Buy'), findsOneWidget);
    });

    testWidgets('shows rent pricing when book is available for rent', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(book: testBook));

      // Assert
      expect(find.text('Rent'), findsOneWidget);
    });

    testWidgets('shows unavailable state when no copies available', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(book: testBookUnavailable));

      // Assert
      expect(find.text('Currently not available for rent or purchase'), findsOneWidget);
    });

    testWidgets('displays pricing section title', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(book: testBook));

      // Assert
      expect(find.text('Pricing'), findsOneWidget);
    });

    testWidgets('shows proper icons for rent and sale', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(book: testBook));

      // Assert
      expect(find.byIcon(Icons.schedule), findsOneWidget); // Rent icon
      expect(find.byIcon(Icons.shopping_cart), findsOneWidget); // Sale icon
    });

    testWidgets('displays currency symbols correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(book: testBook));

      // Assert
      expect(find.textContaining('\$'), findsNWidgets(2)); // Both sale and rent prices
    });

    testWidgets('shows proper layout structure', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(book: testBook));

      // Assert
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('handles free book pricing', (WidgetTester tester) async {
      // Arrange
      final freeBook = Book(
        id: 'free_book',
        title: 'Free Book',
        author: 'Free Author',
        imageUrls: ['https://example.com/free.jpg'],
        rating: 4.0,
        pricing: const BookPricing(
          salePrice: 0.0,
          rentPrice: 0.0,
        ),
        availability: const BookAvailability(
          availableForRentCount: 5,
          availableForSaleCount: 3,
          totalCopies: 10,
        ),
        metadata: const BookMetadata(
          ageAppropriateness: AgeAppropriateness.adult,
          genres: ['Free'],
          pageCount: 200,
          language: 'English',
        ),
        isFromFriend: false,
        isFavorite: false,
        description: 'A free book',
        publishedYear: 2023,
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 1),
      );

      // Act
      await tester.pumpWidget(createTestWidget(book: freeBook));

      // Assert
      expect(find.text('\$0.00'), findsWidgets);
    });

    testWidgets('shows different states for partial availability', (WidgetTester tester) async {
      // Arrange
      final partialBook = Book(
        id: 'partial_book',
        title: 'Partial Book',
        author: 'Partial Author',
        imageUrls: ['https://example.com/partial.jpg'],
        rating: 3.5,
        pricing: const BookPricing(
          salePrice: 15.99,
          rentPrice: 3.99,
        ),
        availability: const BookAvailability(
          availableForRentCount: 0,
          availableForSaleCount: 1,
          totalCopies: 5,
        ),
        metadata: const BookMetadata(
          ageAppropriateness: AgeAppropriateness.adult,
          genres: ['Partial'],
          pageCount: 250,
          language: 'English',
        ),
        isFromFriend: false,
        isFavorite: false,
        description: 'A partially available book',
        publishedYear: 2023,
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 1),
      );

      // Act
      await tester.pumpWidget(createTestWidget(book: partialBook));

      // Assert
      expect(find.text('Buy'), findsOneWidget);
      expect(find.text('Rent'), findsNothing); // Should not show rent option
    });

    testWidgets('handles high price values correctly', (WidgetTester tester) async {
      // Arrange
      final expensiveBook = Book(
        id: 'expensive_book',
        title: 'Expensive Book',
        author: 'Expensive Author',
        imageUrls: ['https://example.com/expensive.jpg'],
        rating: 5.0,
        pricing: const BookPricing(
          salePrice: 199.99,
          rentPrice: 29.99,
        ),
        availability: const BookAvailability(
          availableForRentCount: 1,
          availableForSaleCount: 1,
          totalCopies: 2,
        ),
        metadata: const BookMetadata(
          ageAppropriateness: AgeAppropriateness.adult,
          genres: ['Premium'],
          pageCount: 500,
          language: 'English',
        ),
        isFromFriend: false,
        isFavorite: false,
        description: 'A premium book',
        publishedYear: 2023,
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 1),
      );

      // Act
      await tester.pumpWidget(createTestWidget(book: expensiveBook));

      // Assert
      expect(find.text('\$199.99'), findsOneWidget);
      expect(find.text('\$29.99'), findsOneWidget);
    });

    testWidgets('displays appropriate padding and spacing', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(book: testBook));

      // Assert
      expect(find.byType(Padding), findsWidgets);
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('shows info icon for unavailable books', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(book: testBookUnavailable));

      // Assert
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('handles rent-only availability', (WidgetTester tester) async {
      // Arrange
      final rentOnlyBook = Book(
        id: 'rent_only_book',
        title: 'Rent Only Book',
        author: 'Rent Author',
        imageUrls: ['https://example.com/rent.jpg'],
        rating: 4.2,
        pricing: const BookPricing(
          salePrice: 25.99,
          rentPrice: 5.99,
        ),
        availability: const BookAvailability(
          availableForRentCount: 3,
          availableForSaleCount: 0,
          totalCopies: 3,
        ),
        metadata: const BookMetadata(
          ageAppropriateness: AgeAppropriateness.adult,
          genres: ['Rental'],
          pageCount: 280,
          language: 'English',
        ),
        isFromFriend: false,
        isFavorite: false,
        description: 'A rental only book',
        publishedYear: 2023,
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 1),
      );

      // Act
      await tester.pumpWidget(createTestWidget(book: rentOnlyBook));

      // Assert
      expect(find.text('Rent'), findsOneWidget);
      expect(find.text('Buy'), findsNothing);
    });

    testWidgets('handles sale-only availability', (WidgetTester tester) async {
      // Arrange
      final saleOnlyBook = Book(
        id: 'sale_only_book',
        title: 'Sale Only Book',
        author: 'Sale Author',
        imageUrls: ['https://example.com/sale.jpg'],
        rating: 4.8,
        pricing: const BookPricing(
          salePrice: 18.99,
          rentPrice: 4.99,
        ),
        availability: const BookAvailability(
          availableForRentCount: 0,
          availableForSaleCount: 2,
          totalCopies: 2,
        ),
        metadata: const BookMetadata(
          ageAppropriateness: AgeAppropriateness.adult,
          genres: ['Sale'],
          pageCount: 320,
          language: 'English',
        ),
        isFromFriend: false,
        isFavorite: false,
        description: 'A sale only book',
        publishedYear: 2023,
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 1),
      );

      // Act
      await tester.pumpWidget(createTestWidget(book: saleOnlyBook));

      // Assert
      expect(find.text('Buy'), findsOneWidget);
      expect(find.text('Rent'), findsNothing);
    });
  });
}
