import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/shared/widgets/rating_display.dart';

void main() {
  group('RatingDisplay Widget Tests', () {
    Widget createTestWidget({
      required double rating,
      double? iconSize,
      Color? iconColor,
      TextStyle? textStyle,
      MainAxisAlignment alignment = MainAxisAlignment.start,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: RatingDisplay(
            rating: rating,
            iconSize: iconSize ?? 24.0,
            iconColor: iconColor,
            textStyle: textStyle,
            alignment: alignment,
          ),
        ),
      );
    }

    testWidgets('should display rating with stars correctly', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(rating: 4.5));

      // Assert
      expect(find.text('4.5'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsAtLeastNWidgets(1));
    });

    testWidgets('should display zero rating correctly', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(rating: 0.0));

      // Assert
      expect(find.text('0.0'), findsOneWidget);
    });

    testWidgets('should handle maximum rating correctly', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(rating: 5.0));

      // Assert
      expect(find.text('5.0'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsAtLeastNWidgets(1));
    });

    testWidgets('should display rating without text when using default', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(rating: 4.5));

      // Assert
      expect(find.text('4.5'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsAtLeastNWidgets(1));
    });

    testWidgets('should display partial rating correctly', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(rating: 3.7));

      // Assert
      expect(find.text('3.7'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsAtLeastNWidgets(1));
    });

    testWidgets('should handle high ratings gracefully', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(rating: 4.9));

      // Assert
      expect(find.text('4.9'), findsOneWidget);
    });

    testWidgets('should handle custom color if provided', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(
        rating: 4.0,
        iconColor: Colors.red,
      ));

      // Assert
      expect(find.text('4.0'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsAtLeastNWidgets(1));
    });

    testWidgets('should handle custom size if provided', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(
        rating: 4.0,
        iconSize: 32.0,
      ));

      // Assert
      expect(find.text('4.0'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsAtLeastNWidgets(1));
    });

    testWidgets('should handle edge case ratings', (WidgetTester tester) async {
      // Test very low rating
      await tester.pumpWidget(createTestWidget(rating: 0.1));
      expect(find.text('0.1'), findsOneWidget);

      // Test very high rating - should round to fixed 1 decimal place
      await tester.pumpWidget(createTestWidget(rating: 4.99));
      expect(find.text('5.0'), findsOneWidget); // toStringAsFixed(1) converts 4.99 to 5.0
    });

    testWidgets('should display widget without errors', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(rating: 3.5));

      // Assert - No exceptions should be thrown
      expect(find.byType(RatingDisplay), findsOneWidget);
    });
  });
}
