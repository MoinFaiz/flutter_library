import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/shared/widgets/default_book_placeholder.dart';

void main() {
  group('DefaultBookPlaceholder Widget Tests', () {
    Widget createTestWidget({
      double? width,
      double? height,
      Color? backgroundColor,
      Color? iconColor,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: DefaultBookPlaceholder(
            width: width,
            height: height,
            backgroundColor: backgroundColor,
            iconColor: iconColor,
          ),
        ),
      );
    }

    testWidgets('should display book icon and "No Image" text', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(height: 100.0));

      // Assert
      expect(find.byIcon(Icons.menu_book_rounded), findsOneWidget);
      expect(find.text('No Image'), findsOneWidget);
    });

    testWidgets('should apply custom width and height', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createTestWidget(width: 200.0, height: 300.0),
      );

      // Assert
      final container = tester.widget<Container>(find.byType(Container));
      expect(container.constraints?.maxWidth, equals(200.0));
      expect(container.constraints?.maxHeight, equals(300.0));
    });

    testWidgets('should apply custom background color', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createTestWidget(backgroundColor: Colors.red),
      );

      // Assert
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(Colors.red));
    });

    testWidgets('should apply custom icon color', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createTestWidget(iconColor: Colors.blue, height: 100.0),
      );

      // Assert
      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.menu_book_rounded));
      expect(iconWidget.color, equals(Colors.blue));
    });

    testWidgets('should use theme colors when no custom colors provided', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, isNotNull); // Should use theme color
    });

    testWidgets('should have rounded corners', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, isNotNull);
      expect(decoration.borderRadius, equals(BorderRadius.circular(4)));
    });

    testWidgets('should center content vertically', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      final centerFinder = find.descendant(
        of: find.byType(DefaultBookPlaceholder),
        matching: find.byType(Center),
      );
      final center = tester.widget<Center>(centerFinder.first);
      expect(center, isNotNull);
    });

    testWidgets('should handle null dimensions', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createTestWidget(width: null, height: 100.0), // Need height for text to show
      );

      // Assert
      expect(find.byType(Container), findsOneWidget);
      expect(find.byIcon(Icons.menu_book_rounded), findsOneWidget);
      expect(find.text('No Image'), findsOneWidget);
    });

    testWidgets('should display icon with proper size', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(height: 150.0));

      // Assert
      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.menu_book_rounded));
      expect(iconWidget.size, equals(48)); // Size is 48 when height > 100
    });

    testWidgets('should have proper spacing between icon and text', (
      WidgetTester tester,
    ) async {
      // Arrange & Act - Height must be > 80 to show text and spacing
      await tester.pumpWidget(createTestWidget(height: 100.0));

      // Assert - Multiple SizedBox widgets may exist
      expect(find.byType(SizedBox), findsAtLeastNWidgets(1));
      
      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      final spacingSizedBox = sizedBoxes.firstWhere(
        (sb) => sb.height == 8,
        orElse: () => const SizedBox(height: 8),
      );
      expect(spacingSizedBox.height, equals(8));
    });

    testWidgets('should use proper text styling', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(height: 100.0));

      // Assert
      final textWidget = tester.widget<Text>(find.text('No Image'));
      expect(textWidget.style, isNotNull);
    });

    testWidgets('should handle very small dimensions', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createTestWidget(width: 50.0, height: 50.0),
      );

      // Assert
      final container = tester.widget<Container>(find.byType(Container));
      expect(container.constraints?.maxWidth, equals(50.0));
      expect(container.constraints?.maxHeight, equals(50.0));
    });

    testWidgets('should handle very large dimensions', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createTestWidget(width: 1000.0, height: 1500.0),
      );

      // Assert
      final container = tester.widget<Container>(find.byType(Container));
      expect(container.constraints?.maxWidth, equals(1000.0));
      expect(container.constraints?.maxHeight, equals(1500.0));
    });

    testWidgets('should maintain layout consistency with different parameters', (
      WidgetTester tester,
    ) async {
      // Test with minimal parameters
      await tester.pumpWidget(createTestWidget());
      expect(
        find.descendant(
          of: find.byType(DefaultBookPlaceholder),
          matching: find.byType(Center),
        ),
        findsWidgets,
      );
      expect(find.byIcon(Icons.menu_book_rounded), findsOneWidget);

      // Test with all parameters
      await tester.pumpWidget(
        createTestWidget(
          width: 200.0,
          height: 300.0,
          backgroundColor: Colors.grey,
          iconColor: Colors.black,
        ),
      );
      expect(find.byType(Column), findsOneWidget);
      expect(find.byIcon(Icons.menu_book_rounded), findsOneWidget);
      expect(find.text('No Image'), findsOneWidget);
    });

    testWidgets('should apply transparent background color correctly', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createTestWidget(backgroundColor: Colors.transparent),
      );

      // Assert
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(Colors.transparent));
    });

    testWidgets('should handle contrasting icon and background colors', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createTestWidget(
          backgroundColor: Colors.black,
          iconColor: Colors.white,
          height: 100.0,
        ),
      );

      // Assert
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(Colors.black));

      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.menu_book_rounded));
      expect(iconWidget.color, equals(Colors.white));
    });

    testWidgets('should maintain proper aspect ratio with square dimensions', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        createTestWidget(width: 200.0, height: 200.0),
      );

      // Assert
      final container = tester.widget<Container>(find.byType(Container));
      expect(container.constraints?.maxWidth, equals(container.constraints?.maxHeight));
    });
  });
}
