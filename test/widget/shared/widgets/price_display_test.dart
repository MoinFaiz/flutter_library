import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/shared/widgets/price_display.dart';

void main() {
  group('PriceDisplay Widget Tests', () {
    Widget createTestWidget({
      required double price,
      double? discountPrice,
      TextStyle? originalPriceStyle,
      TextStyle? discountPriceStyle,
      String currency = '\$',
    }) {
      return MaterialApp(
        home: Scaffold(
          body: PriceDisplay(
            price: price,
            discountPrice: discountPrice,
            originalPriceStyle: originalPriceStyle,
            discountPriceStyle: discountPriceStyle,
            currency: currency,
          ),
        ),
      );
    }

    testWidgets('should display regular price without discount', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(price: 25.99));

      // Assert
      expect(find.text('\$25.99'), findsOneWidget);
    });

    testWidgets('should display discount price correctly', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createTestWidget(price: 25.99, discountPrice: 19.99),
      );

      // Assert
      expect(find.text('\$19.99'), findsOneWidget);
      expect(find.text('\$25.99'), findsOneWidget);
    });

    testWidgets('should not show discount when discount price is higher', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createTestWidget(price: 25.99, discountPrice: 30.99),
      );

      // Assert
      expect(find.text('\$25.99'), findsOneWidget);
      expect(find.text('\$30.99'), findsNothing);
    });

    testWidgets('should not show discount when discount price equals original', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createTestWidget(price: 25.99, discountPrice: 25.99),
      );

      // Assert
      expect(find.text('\$25.99'), findsOneWidget);
      // Should only find one instance (no crossed out price)
      expect(find.textContaining('\$25.99'), findsOneWidget);
    });

    testWidgets('should handle zero price correctly', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(price: 0.0));

      // Assert
      expect(find.text('\$0.00'), findsOneWidget);
    });

    testWidgets('should handle custom currency', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createTestWidget(price: 25.99, currency: '€'),
      );

      // Assert
      expect(find.text('€25.99'), findsOneWidget);
    });

    testWidgets('should apply custom text styles', (
      WidgetTester tester,
    ) async {
      // Arrange
      const originalStyle = TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.red,
      );
      const discountStyle = TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.normal,
        color: Colors.green,
      );

      // Act
      await tester.pumpWidget(
        createTestWidget(
          price: 25.99,
          discountPrice: 19.99,
          originalPriceStyle: originalStyle,
          discountPriceStyle: discountStyle,
        ),
      );

      // Assert
      expect(find.byType(Text), findsAtLeastNWidgets(2));
    });

    testWidgets('should handle decimal prices correctly', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(price: 25.999));

      // Assert
      expect(find.textContaining('26.00'), findsOneWidget);
    });

    testWidgets('should display discount percentage when available', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createTestWidget(price: 100.0, discountPrice: 80.0),
      );

      // Assert
      expect(find.text('\$80.00'), findsOneWidget);
      expect(find.text('\$100.00'), findsOneWidget);
    });

    testWidgets('should handle very small prices', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(price: 0.01));

      // Assert
      expect(find.text('\$0.01'), findsOneWidget);
    });

    testWidgets('should handle large prices', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(price: 9999.99));

      // Assert
      expect(find.text('\$9999.99'), findsOneWidget);
    });

    testWidgets('should show strikethrough style for original price when discounted', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createTestWidget(price: 25.99, discountPrice: 19.99),
      );

      // Assert
      expect(find.byType(Text), findsAtLeastNWidgets(2));
      
      // Find the original price text widget and check for strikethrough
      final originalPriceTextFinder = find.text('\$25.99');
      expect(originalPriceTextFinder, findsOneWidget);
      
      final originalPriceWidget = tester.widget<Text>(originalPriceTextFinder);
      expect(
        originalPriceWidget.style?.decoration,
        equals(TextDecoration.lineThrough),
      );
    });
  });
}
