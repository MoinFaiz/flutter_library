import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/library/presentation/widgets/horizontal_book_list.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';
import 'package:flutter_library/shared/widgets/book_card.dart';

void main() {
  group('HorizontalBookList Tests', () {
    final testBooks = List.generate(3, (index) => Book(
      id: 'book_$index',
      title: 'Test Book ${index + 1}',
      author: 'Test Author ${index + 1}',
      imageUrls: ['https://example.com/book${index + 1}.jpg'],
      rating: 4.0 + (index * 0.2),
      pricing: BookPricing(
        salePrice: 15.99 + index,
        rentPrice: 3.99 + index,
      ),
      availability: BookAvailability(
        availableForRentCount: 2 + index,
        availableForSaleCount: 1 + index,
        totalCopies: 5 + index,
      ),
      metadata: BookMetadata(
        ageAppropriateness: AgeAppropriateness.adult,
        genres: ['Fiction', 'Genre $index'],
        pageCount: 300 + (index * 50),
        language: 'English',
      ),
      isFromFriend: false,
      isFavorite: index.isEven,
      description: 'Test book description ${index + 1}',
      publishedYear: 2023 + index,
      createdAt: DateTime(2023, 1, index + 1),
      updatedAt: DateTime(2023, 1, index + 1),
    ));

    // Create 5 books for testing "More" button which requires >= 5 books
    final fiveBooksForMore = List.generate(5, (index) => Book(
      id: 'book_$index',
      title: 'Test Book ${index + 1}',
      author: 'Test Author ${index + 1}',
      imageUrls: ['https://example.com/book${index + 1}.jpg'],
      rating: 4.0 + (index * 0.2),
      pricing: BookPricing(
        salePrice: 15.99 + index,
        rentPrice: 3.99 + index,
      ),
      availability: BookAvailability(
        availableForRentCount: 2 + index,
        availableForSaleCount: 1 + index,
        totalCopies: 5 + index,
      ),
      metadata: BookMetadata(
        ageAppropriateness: AgeAppropriateness.adult,
        genres: ['Fiction', 'Genre $index'],
        pageCount: 300 + (index * 50),
        language: 'English',
      ),
      isFromFriend: false,
      isFavorite: index.isEven,
      description: 'Test book description ${index + 1}',
      publishedYear: 2023 + index,
      createdAt: DateTime(2023, 1, index + 1),
      updatedAt: DateTime(2023, 1, index + 1),
    ));

    Widget createTestWidget({
      String title = 'Test Section',
      List<Book> books = const [],
      bool isLoading = false,
      String? errorMessage,
      VoidCallback? onMoreTapped,
      Function(Book)? onBookTapped,
      bool showMoreButton = true,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: HorizontalBookList(
            title: title,
            books: books,
            isLoading: isLoading,
            errorMessage: errorMessage,
            onMoreTapped: onMoreTapped,
            onBookTapped: onBookTapped,
            showMoreButton: showMoreButton,
          ),
        ),
      );
    }

    testWidgets('displays section title correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(title: 'Popular Books'));

      // Assert
      expect(find.text('Popular Books'), findsOneWidget);
    });

    testWidgets('displays books in horizontal list', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(books: testBooks));

      // Assert
      expect(find.byType(BookCard), findsNWidgets(3));
      expect(find.text('Test Book 1'), findsOneWidget);
      expect(find.text('Test Book 2'), findsOneWidget);
      expect(find.text('Test Book 3'), findsOneWidget);
    });

    testWidgets('shows more button when showMoreButton is true', (WidgetTester tester) async {
      // Act - Need >= 5 books for More button to appear
      await tester.pumpWidget(createTestWidget(
        books: fiveBooksForMore,
        showMoreButton: true,
        onMoreTapped: () {}, // Need callback for button to show
      ));

      // Assert
      expect(find.text('More'), findsOneWidget);
    });

    testWidgets('hides more button when showMoreButton is false', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(
        books: fiveBooksForMore,
        showMoreButton: false,
      ));

      // Assert
      expect(find.text('More'), findsNothing);
    });

    testWidgets('calls onMoreTapped when more button is pressed', (WidgetTester tester) async {
      // Arrange
      bool moreTapped = false;

      // Act - Need >= 5 books for More button to appear
      await tester.pumpWidget(createTestWidget(
        books: fiveBooksForMore,
        onMoreTapped: () => moreTapped = true,
      ));

      await tester.tap(find.text('More'));

      // Assert
      expect(moreTapped, isTrue);
    });

    testWidgets('calls onBookTapped when book is tapped', (WidgetTester tester) async {
      // Arrange
      Book? tappedBook;

      // Act
      await tester.pumpWidget(createTestWidget(
        books: testBooks,
        onBookTapped: (book) => tappedBook = book,
      ));

      await tester.tap(find.byType(BookCard).first);

      // Assert
      expect(tappedBook, isNotNull);
      expect(tappedBook?.title, equals('Test Book 1'));
    });

    testWidgets('shows loading indicator when isLoading is true', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(isLoading: true));

      // Assert - Shows 3 loading placeholders
      expect(find.byType(CircularProgressIndicator), findsNWidgets(3));
    });

    testWidgets('shows error message when errorMessage is provided', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(
        errorMessage: 'Failed to load books',
      ));

      // Assert
      expect(find.text('Failed to load books'), findsOneWidget);
    });

    testWidgets('shows empty state when no books and not loading', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(
        books: [],
        isLoading: false,
      ));

      // Assert
      expect(find.text('No books yet'), findsOneWidget);
    });

    testWidgets('displays all books provided', (WidgetTester tester) async {
      // Arrange
      final manyBooks = List.generate(10, (index) => Book(
        id: 'book_$index',
        title: 'Book $index',
        author: 'Author $index',
        imageUrls: ['https://example.com/book$index.jpg'],
        rating: 4.0,
        pricing: const BookPricing(salePrice: 19.99, rentPrice: 4.99),
        availability: const BookAvailability(
          availableForRentCount: 2,
          availableForSaleCount: 1,
          totalCopies: 5,
        ),
        metadata: const BookMetadata(
          ageAppropriateness: AgeAppropriateness.adult,
          genres: ['Fiction'],
          pageCount: 300,
          language: 'English',
        ),
        isFromFriend: false,
        isFavorite: false,
        description: 'Book description $index',
        publishedYear: 2023,
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 1),
      ));

      // Act
      await tester.pumpWidget(createTestWidget(books: manyBooks));

      // Assert - ListView displays all books, but only those in viewport are rendered
      // Check that ListView is present and can scroll
      expect(find.byType(ListView), findsOneWidget);
      
      // Verify at least some books are visible (those in the viewport)
      expect(find.byType(BookCard), findsWidgets);
    });

    testWidgets('has proper layout structure', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(books: testBooks));

      // Assert
      expect(find.byType(Column), findsWidgets); // Multiple columns in the structure
      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('shows horizontal scrolling for books', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(books: testBooks));

      // Assert - Uses ListView.builder, not SingleChildScrollView
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('displays book titles correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(books: testBooks.take(2).toList()));

      // Assert
      expect(find.text('Test Book 1'), findsOneWidget);
      expect(find.text('Test Book 2'), findsOneWidget);
    });

    testWidgets('handles empty book list gracefully', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(books: []));

      // Assert
      expect(find.byType(BookCard), findsNothing);
      expect(tester.takeException(), isNull); // No exceptions
    });

    testWidgets('shows section header with proper styling', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(title: 'Featured Books'));

      // Assert
      final titleWidget = tester.widget<Text>(find.text('Featured Books'));
      expect(titleWidget.style?.fontWeight, equals(FontWeight.bold));
    });

    testWidgets('handles book tap correctly for different books', (WidgetTester tester) async {
      // Arrange
      final tappedBooks = <Book>[];

      // Act
      await tester.pumpWidget(createTestWidget(
        books: testBooks,
        onBookTapped: (book) => tappedBooks.add(book),
      ));

      // Tap different books
      await tester.tap(find.byType(BookCard).at(0));
      await tester.tap(find.byType(BookCard).at(1));

      // Assert
      expect(tappedBooks.length, equals(2));
      expect(tappedBooks[0].title, equals('Test Book 1'));
      expect(tappedBooks[1].title, equals('Test Book 2'));
    });

    testWidgets('shows proper spacing between elements', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(books: testBooks));

      // Assert
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('handles loading state without showing books', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(
        books: testBooks,
        isLoading: true,
      ));

      // Assert - Shows 3 loading placeholders
      expect(find.byType(CircularProgressIndicator), findsNWidgets(3));
      expect(find.byType(BookCard), findsNothing); // Books should be hidden during loading
    });
  });
}
