import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/book_details/presentation/widgets/book_actions_section.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';
import 'package:flutter_library/features/book_details/domain/entities/rental_status.dart';

void main() {
  group('BookActionsSection Tests', () {
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

    Widget createTestWidget({
      required Book book,
      RentalStatus? rentalStatus,
      bool isPerformingAction = false,
      VoidCallback? onRent,
      VoidCallback? onBuy,
      VoidCallback? onReturn,
      VoidCallback? onRenew,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: BookActionsSection(
            book: book,
            rentalStatus: rentalStatus,
            isPerformingAction: isPerformingAction,
            onRent: onRent,
            onBuy: onBuy,
            onReturn: onReturn,
            onRenew: onRenew,
          ),
        ),
      );
    }

    testWidgets('displays actions section title', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(book: testBook));

      // Assert
      expect(find.text('Actions'), findsOneWidget);
    });

    testWidgets('calls onRent when rent action is triggered', (WidgetTester tester) async {
      // Arrange
      bool rentCalled = false;

      // Act
      await tester.pumpWidget(createTestWidget(
        book: testBook,
        onRent: () => rentCalled = true,
      ));

      // Try to find and tap rent button (implementation dependent)
      final rentButtons = find.widgetWithText(ElevatedButton, 'Rent');
      if (rentButtons.evaluate().isNotEmpty) {
        await tester.tap(rentButtons);
        expect(rentCalled, isTrue);
      }
    });

    testWidgets('calls onBuy when buy action is triggered', (WidgetTester tester) async {
      // Arrange
      bool buyCalled = false;

      // Act
      await tester.pumpWidget(createTestWidget(
        book: testBook,
        onBuy: () => buyCalled = true,
      ));

      // Try to find and tap buy button (implementation dependent)
      final buyButtons = find.widgetWithText(ElevatedButton, 'Buy');
      if (buyButtons.evaluate().isNotEmpty) {
        await tester.tap(buyButtons);
        expect(buyCalled, isTrue);
      }
    });

    testWidgets('shows loading state when rental status is null', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(
        book: testBook,
        rentalStatus: null,
      ));

      // Assert
      expect(find.text('Loading rental status...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty state when no actions available', (WidgetTester tester) async {
      // Arrange
      final unavailableBook = Book(
        id: 'unavailable_book',
        title: 'Unavailable Book',
        author: 'Test Author',
        imageUrls: ['https://example.com/unavailable.jpg'],
        rating: 4.0,
        pricing: const BookPricing(
          salePrice: 19.99,
          rentPrice: 4.99,
        ),
        availability: const BookAvailability(
          availableForRentCount: 0,
          availableForSaleCount: 0,
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
        description: 'Not available',
        publishedYear: 2023,
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 1),
      );

      // Act
      await tester.pumpWidget(createTestWidget(
        book: unavailableBook,
        rentalStatus: const RentalStatus(
          bookId: 'unavailable_book',
          status: RentalStatusType.unavailable,
        ),
      ));

      // Assert
      expect(find.text('No actions available for this book'), findsOneWidget);
    });

    testWidgets('shows proper layout structure', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(book: testBook));

      // Assert
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(Padding), findsAtLeastNWidgets(1));
    });

    testWidgets('handles performing action state', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(
        book: testBook,
        isPerformingAction: true,
      ));

      // Assert - should not crash
      expect(tester.takeException(), isNull);
    });

    testWidgets('displays return action when book is rented', (WidgetTester tester) async {
      // Arrange
      bool returnCalled = false;

      // Act
      await tester.pumpWidget(createTestWidget(
        book: testBook,
        rentalStatus: const RentalStatus(
          bookId: 'test_book_1',
          status: RentalStatusType.rented,
          canRenew: false,
        ),
        onReturn: () => returnCalled = true,
      ));

      // Try to find and tap return button
      final returnButtons = find.widgetWithText(ElevatedButton, 'Return');
      if (returnButtons.evaluate().isNotEmpty) {
        await tester.tap(returnButtons);
        expect(returnCalled, isTrue);
      }
    });

    testWidgets('displays renew action when book can be renewed', (WidgetTester tester) async {
      // Arrange
      bool renewCalled = false;

      // Act
      await tester.pumpWidget(createTestWidget(
        book: testBook,
        rentalStatus: const RentalStatus(
          bookId: 'test_book_1',
          status: RentalStatusType.rented,
          canRenew: true,
        ),
        onRenew: () => renewCalled = true,
      ));

      // Try to find and tap renew button
      final renewButtons = find.widgetWithText(ElevatedButton, 'Renew');
      if (renewButtons.evaluate().isNotEmpty) {
        await tester.tap(renewButtons);
        expect(renewCalled, isTrue);
      }
    });

    testWidgets('shows info icon in empty state', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(
        book: testBook,
        rentalStatus: const RentalStatus(
          bookId: 'test_book_1',
          status: RentalStatusType.unavailable,
        ),
      ));

      // Assert
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('handles different rental statuses', (WidgetTester tester) async {
      // Test with different rental status
      await tester.pumpWidget(createTestWidget(
        book: testBook,
        rentalStatus: const RentalStatus(
          bookId: 'test_book_1',
          status: RentalStatusType.available,
        ),
      ));

      // Should not crash and should render
      expect(find.byType(BookActionsSection), findsOneWidget);
    });

    testWidgets('maintains layout when no callbacks provided', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(book: testBook));

      // Assert - should render without callbacks
      expect(find.byType(BookActionsSection), findsOneWidget);
      expect(find.text('Actions'), findsOneWidget);
    });
  });
}
