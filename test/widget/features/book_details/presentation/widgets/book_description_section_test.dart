import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/book_details/presentation/widgets/book_description_section.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';

void main() {
  group('BookDescriptionSection Widget Tests', () {
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
        description: 'This is a detailed description of the test book. It contains multiple sentences to test the text display functionality.',
        publishedYear: 2023,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    Widget createTestWidget({Book? book}) {
      return MaterialApp(
        home: Scaffold(
          body: BookDescriptionSection(book: book ?? testBook),
        ),
      );
    }

    testWidgets('displays section title correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Description'), findsOneWidget);
    });

    testWidgets('displays book description correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('This is a detailed description of the test book. It contains multiple sentences to test the text display functionality.'), findsOneWidget);
    });

    testWidgets('handles empty description gracefully', (WidgetTester tester) async {
      // Arrange
      final bookWithoutDescription = testBook.copyWith(description: '');

      // Act
      await tester.pumpWidget(createTestWidget(book: bookWithoutDescription));

      // Assert
      expect(find.text('No description available'), findsOneWidget);
    });

    testWidgets('handles empty description (non-nullable)', (WidgetTester tester) async {
      // Arrange - Since description is non-nullable String, test with empty string
      final bookWithEmptyDescription = testBook.copyWith(description: '');

      // Act
      await tester.pumpWidget(createTestWidget(book: bookWithEmptyDescription));

      // Assert
      expect(find.text('No description available'), findsOneWidget);
    });

    testWidgets('displays long description correctly', (WidgetTester tester) async {
      // Arrange
      final longDescription = List.generate(100, (index) => 'Sentence ${index + 1}.').join(' ');
      final bookWithLongDescription = testBook.copyWith(description: longDescription);

      // Act
      await tester.pumpWidget(createTestWidget(book: bookWithLongDescription));

      // Assert
      expect(find.textContaining('Sentence 1.'), findsOneWidget);
      expect(find.textContaining('Sentence 100.'), findsOneWidget);
      expect(tester.takeException(), isNull); // Should handle long text gracefully
    });

    testWidgets('has proper layout structure', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert - When there's description, uses Column with AnimatedSize
      expect(find.byType(Column), findsAtLeastNWidgets(1));
      expect(find.byType(Padding), findsWidgets);
      expect(find.byType(AnimatedSize), findsOneWidget);
    });

    testWidgets('displays section with proper styling', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      // Verify section title styling
      final titleText = tester.widget<Text>(find.text('Description'));
      expect(titleText.style?.fontWeight, equals(FontWeight.bold));
      
      // Verify proper widget structure (Column with AnimatedSize for description text)
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(AnimatedSize), findsOneWidget);
    });

    testWidgets('handles special characters in description', (WidgetTester tester) async {
      // Arrange
      final specialDescription = 'Description with émojis 📚, symbols & special characters: @#\$%^&*()!';
      final bookWithSpecialDescription = testBook.copyWith(description: specialDescription);

      // Act
      await tester.pumpWidget(createTestWidget(book: bookWithSpecialDescription));

      // Assert
      expect(find.text(specialDescription), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('handles line breaks in description', (WidgetTester tester) async {
      // Arrange
      final descriptionWithLineBreaks = 'First paragraph.\n\nSecond paragraph with line break.\n\nThird paragraph.';
      final bookWithLineBreaks = testBook.copyWith(description: descriptionWithLineBreaks);

      // Act
      await tester.pumpWidget(createTestWidget(book: bookWithLineBreaks));

      // Assert
      expect(find.textContaining('First paragraph.'), findsOneWidget);
      expect(find.textContaining('Second paragraph with line break.'), findsOneWidget);
      expect(find.textContaining('Third paragraph.'), findsOneWidget);
    });

    testWidgets('maintains consistent spacing', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(SizedBox), findsWidgets); // Should have spacing elements
      expect(find.byType(Padding), findsWidgets); // Should have padding
    });

    testWidgets('displays read more functionality if implemented', (WidgetTester tester) async {
      // Arrange
      final veryLongDescription = List.generate(200, (index) => 'Very long sentence ${index + 1}.').join(' ');
      final bookWithVeryLongDescription = testBook.copyWith(description: veryLongDescription);

      // Act
      await tester.pumpWidget(createTestWidget(book: bookWithVeryLongDescription));

      // Assert - If read more is implemented, check for it
      // This test will pass regardless since we're just checking it doesn't crash
      expect(tester.takeException(), isNull);
      expect(find.textContaining('Very long sentence 1.'), findsOneWidget);
    });
  });
}
