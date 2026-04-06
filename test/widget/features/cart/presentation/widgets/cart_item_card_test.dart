import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_item.dart';
import 'package:flutter_library/features/cart/presentation/widgets/cart_item_card.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';

void main() {
  late CartItem testCartItem;
  late Book testBook;

  setUp(() {
    testBook = Book(
      id: 'book1',
      title: 'Test Book Title',
      author: 'Test Author',
      imageUrls: ['https://example.com/test.jpg'],
      rating: 4.5,
      pricing: const BookPricing(
        salePrice: 20.0,
        rentPrice: 5.0,
      ),
      availability: const BookAvailability(
        availableForRentCount: 3,
        availableForSaleCount: 5,
        totalCopies: 10,
      ),
      metadata: const BookMetadata(
        isbn: '1234567890',
        publisher: 'Test Publisher',
        ageAppropriateness: AgeAppropriateness.adult,
        genres: ['Fiction'],
        pageCount: 350,
        language: 'English',
      ),
      isFromFriend: false,
      isFavorite: false,
      description: 'Test description',
      publishedYear: 2024,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    testCartItem = CartItem(
      id: 'cart1',
      book: testBook,
      type: CartItemType.rent,
      addedAt: DateTime.now(),
      rentalPeriodInDays: 14,
    );
  });

  Widget buildTestWidget(CartItem item, {
    VoidCallback? onRemove,
    VoidCallback? onSendRequest,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: CartItemCard(
          item: item,
          onRemove: onRemove ?? () {},
          onSendRequest: onSendRequest ?? () {},
        ),
      ),
    );
  }

  group('CartItemCard Widget Tests', () {
    testWidgets('displays book title and author', (tester) async {
      await tester.pumpWidget(buildTestWidget(testCartItem));

      expect(find.text('Test Book Title'), findsOneWidget);
      expect(find.text('Test Author'), findsOneWidget);
    });

    testWidgets('displays rental badge for rental items', (tester) async {
      await tester.pumpWidget(buildTestWidget(testCartItem));

      expect(find.text('Rent (14 days)'), findsOneWidget);
    });

    testWidgets('displays purchase badge for purchase items', (tester) async {
      final purchaseItem = testCartItem.copyWith(type: CartItemType.purchase);
      await tester.pumpWidget(buildTestWidget(purchaseItem));

      expect(find.text('Purchase'), findsOneWidget);
      expect(find.textContaining('Rent'), findsNothing);
    });

    testWidgets('displays correct price for rental', (tester) async {
      await tester.pumpWidget(buildTestWidget(testCartItem));

      expect(find.text('\$5.00'), findsOneWidget);
    });

    testWidgets('displays correct price for purchase', (tester) async {
      final purchaseItem = testCartItem.copyWith(type: CartItemType.purchase);
      await tester.pumpWidget(buildTestWidget(purchaseItem));

      expect(find.text('\$20.00'), findsOneWidget);
    });

    testWidgets('shows send request button when no request sent', (tester) async {
      await tester.pumpWidget(buildTestWidget(testCartItem));

      expect(find.text('Request'), findsOneWidget);
      expect(find.text('Requested'), findsNothing);
    });

    testWidgets('shows request sent when request exists', (tester) async {
      final itemWithRequest = testCartItem.copyWith(requestId: 'req123');
      await tester.pumpWidget(buildTestWidget(itemWithRequest));

      expect(find.text('Requested'), findsOneWidget);
      expect(find.text('Request'), findsNothing);
    });

    testWidgets('calls onRemove when delete button tapped', (tester) async {
      var deleteCalled = false;
      await tester.pumpWidget(buildTestWidget(
        testCartItem,
        onRemove: () => deleteCalled = true,
      ));

      final deleteButton = find.byIcon(Icons.delete_outline);
      expect(deleteButton, findsOneWidget);

      await tester.tap(deleteButton);
      await tester.pump();

      expect(deleteCalled, isTrue);
    });

    testWidgets('calls onSendRequest when send request button tapped', (tester) async {
      var sendRequestCalled = false;
      await tester.pumpWidget(buildTestWidget(
        testCartItem,
        onSendRequest: () => sendRequestCalled = true,
      ));

      final sendButton = find.text('Request');
      expect(sendButton, findsOneWidget);

      await tester.tap(sendButton);
      await tester.pump();

      expect(sendRequestCalled, isTrue);
    });

    testWidgets('send request button is disabled when request already sent', (tester) async {
      final itemWithRequest = testCartItem.copyWith(requestId: 'req123');
      await tester.pumpWidget(buildTestWidget(itemWithRequest));

      final requestSentChip = find.text('Requested');
      expect(requestSentChip, findsOneWidget);
      
      // Verify it's a Chip widget, not a button
      final chipWidget = tester.widget<Chip>(find.byType(Chip));
      expect(chipWidget, isNotNull);
    });
  });
}
