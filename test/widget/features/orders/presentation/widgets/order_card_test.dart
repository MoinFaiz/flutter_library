import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/orders/presentation/widgets/order_card.dart';
import 'package:flutter_library/features/orders/domain/entities/order.dart';

void main() {
  group('OrderCard Tests', () {
    final testOrder = Order(
      id: '1',
      bookId: 'book_1',
      bookTitle: 'Test Book',
      bookImageUrl: 'https://example.com/book.jpg',
      bookAuthor: 'Test Author',
      type: OrderType.purchase,
      status: OrderStatus.pending,
      price: 19.99,
      orderDate: DateTime(2023, 1, 1),
    );

    Widget createTestWidget({
      required Order order,
      bool isActive = false,
      VoidCallback? onTap,
      VoidCallback? onCancel,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: OrderCard(
            order: order,
            isActive: isActive,
            onTap: onTap,
            onCancel: onCancel,
          ),
        ),
      );
    }

    testWidgets('displays order information correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(order: testOrder));

      // Assert
      expect(find.text('Test Book'), findsOneWidget);
      expect(find.text('by Test Author'), findsOneWidget); // Author is prefixed with "by"
      expect(find.text('Purchase'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('\$19.99'), findsOneWidget);
    });

    testWidgets('shows different styles for active and inactive orders', (WidgetTester tester) async {
      // Test active order
      await tester.pumpWidget(createTestWidget(
        order: testOrder,
        isActive: true,
      ));

      Card activeCard = tester.widget(find.byType(Card));
      expect(activeCard.elevation, equals(4));

      // Test inactive order
      await tester.pumpWidget(createTestWidget(
        order: testOrder,
        isActive: false,
      ));

      Card inactiveCard = tester.widget(find.byType(Card));
      expect(inactiveCard.elevation, equals(2));
    });

    testWidgets('calls onTap when card is tapped', (WidgetTester tester) async {
      // Arrange
      bool wasTapped = false;

      // Act
      await tester.pumpWidget(createTestWidget(
        order: testOrder,
        onTap: () => wasTapped = true,
      ));

      await tester.tap(find.byType(OrderCard));

      // Assert
      expect(wasTapped, isTrue);
    });

    testWidgets('accepts onCancel callback when provided', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(
        order: testOrder,
        onCancel: () {}, // Provide a callback
      ));

      // Assert - The card should render with onCancel callback
      // (Note: OrderCard doesn't show a cancel button in the UI, 
      // it just accepts the callback for potential future use)
      expect(find.byType(OrderCard), findsOneWidget);
    });

    testWidgets('works without onCancel callback', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(order: testOrder));

      // Assert - The card should render normally without onCancel
      expect(find.byType(OrderCard), findsOneWidget);
    });

    testWidgets('displays rental order correctly', (WidgetTester tester) async {
      // Arrange
      final rentalOrder = Order(
        id: '2',
        bookId: 'book_2',
        bookTitle: 'Rental Book',
        bookImageUrl: 'https://example.com/rental.jpg',
        bookAuthor: 'Rental Author',
        type: OrderType.rental,
        status: OrderStatus.shipped,
        price: 4.99,
        orderDate: DateTime(2023, 2, 1),
      );

      // Act
      await tester.pumpWidget(createTestWidget(order: rentalOrder));

      // Assert
      expect(find.text('Rental Book'), findsOneWidget);
      expect(find.text('Rental'), findsOneWidget);
      expect(find.text('Shipped'), findsOneWidget);
      expect(find.text('\$4.99'), findsOneWidget);
    });

    testWidgets('displays different order statuses correctly', (WidgetTester tester) async {
      final statuses = [
        (OrderStatus.pending, 'Pending'),
        (OrderStatus.processing, 'Processing'),
        (OrderStatus.shipped, 'Shipped'),
        (OrderStatus.delivered, 'Delivered'),
        (OrderStatus.completed, 'Completed'),
        (OrderStatus.cancelled, 'Cancelled'),
        (OrderStatus.returned, 'Returned'),
      ];

      for (final (status, displayText) in statuses) {
        final orderWithStatus = Order(
          id: '1',
          bookId: 'book_1',
          bookTitle: 'Test Book',
          bookImageUrl: 'https://example.com/book.jpg',
          bookAuthor: 'Test Author',
          type: OrderType.purchase,
          status: status,
          price: 19.99,
          orderDate: DateTime(2023, 1, 1),
        );

        await tester.pumpWidget(createTestWidget(order: orderWithStatus));
        expect(find.text(displayText), findsOneWidget);
      }
    });

    testWidgets('displays book cover image', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(order: testOrder));

      // Assert
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('has proper layout structure', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(order: testOrder));

      // Assert
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
      expect(find.byType(Row), findsWidgets);
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('formats order date correctly', (WidgetTester tester) async {
      // Arrange
      final orderWithDate = Order(
        id: '1',
        bookId: 'book_1',
        bookTitle: 'Test Book',
        bookImageUrl: 'https://example.com/book.jpg',
        bookAuthor: 'Test Author',
        type: OrderType.purchase,
        status: OrderStatus.pending,
        price: 19.99,
        orderDate: DateTime(2023, 12, 25),
      );

      // Act
      await tester.pumpWidget(createTestWidget(order: orderWithDate));

      // Assert - Check if some form of date display exists
      // (exact format depends on implementation)
      expect(find.textContaining('2023'), findsOneWidget);
    });
  });
}
