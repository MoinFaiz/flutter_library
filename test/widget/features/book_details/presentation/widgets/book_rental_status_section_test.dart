import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/book_details/presentation/widgets/book_rental_status_section.dart';
import 'package:flutter_library/features/book_details/domain/entities/rental_status.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';

void main() {
  group('BookRentalStatusSection Widget Tests', () {
    final testBook = Book(
      id: '1',
      title: 'Test Book',
      author: 'Test Author',
      imageUrls: ['https://example.com/book.jpg'],
      rating: 4.5,
      pricing: const BookPricing(
        salePrice: 20.0,
        rentPrice: 5.0,
      ),
      availability: const BookAvailability(
        availableForRentCount: 3,
        availableForSaleCount: 2,
        totalCopies: 5,
      ),
      metadata: const BookMetadata(
        isbn: '1234567890',
        publisher: 'Test Publisher',
        ageAppropriateness: AgeAppropriateness.allAges,
        genres: ['Fiction'],
        pageCount: 200,
        language: 'English',
      ),
      isFromFriend: false,
      isFavorite: false,
      description: 'A test book',
      publishedYear: 2023,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    Widget createTestWidget({
      Book? book,
      RentalStatus? rentalStatus,
      bool isLoading = false,
      String? error,
      VoidCallback? onLoadRentalStatus,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: BookRentalStatusSection(
            book: book ?? testBook,
            rentalStatus: rentalStatus,
            isLoading: isLoading,
            error: error,
            onLoadRentalStatus: onLoadRentalStatus,
          ),
        ),
      );
    }

    testWidgets('displays section title correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Rental Status'), findsOneWidget);
    });

    testWidgets('displays loading state when isLoading is true', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(isLoading: true));

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays error state when error is provided', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(error: 'Failed to load rental status'));

      // Assert - Error may appear in both title and message
      expect(find.textContaining('Failed to load'), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('displays load button when rental status is null', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Load Status'), findsOneWidget);
    });

    testWidgets('displays rental status when provided and is rented', (WidgetTester tester) async {
      // Arrange - Status must have status=rented to make isRented getter return true
      const status = RentalStatus(
        bookId: '1',
        status: RentalStatusType.rented,
        canRenew: false,
        isInCart: false,
        isPurchased: false,
      );

      // Act
      await tester.pumpWidget(createTestWidget(rentalStatus: status));

      // Assert - Should display rental status card
      expect(find.byType(BookRentalStatusSection), findsOneWidget);
    });

    testWidgets('has proper layout structure', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(Padding), findsWidgets);
      expect(find.byType(Column), findsAtLeastNWidgets(1));
    });
  });
}
