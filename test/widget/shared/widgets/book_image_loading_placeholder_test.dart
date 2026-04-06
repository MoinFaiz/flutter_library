import 'package:flutter/material.dart';
import 'package:flutter_library/shared/widgets/default_book_placeholder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BookImageLoadingPlaceholder Widget Tests', () {
    testWidgets('should render with default properties', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BookImageLoadingPlaceholder(),
          ),
        ),
      );

      // Verify container exists
      expect(find.byType(Container), findsOneWidget);
      
      // Verify CircularProgressIndicator exists
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Verify compact center layout is used by default
      expect(find.byType(Center), findsOneWidget);
    });

    testWidgets('should render with custom width and height', (WidgetTester tester) async {
      const customWidth = 200.0;
      const customHeight = 300.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BookImageLoadingPlaceholder(
              width: customWidth,
              height: customHeight,
            ),
          ),
        ),
      );

      final containerWidget = tester.widget<Container>(find.byType(Container).first);
      // Container with width/height creates constraints, not null
      final constraints = containerWidget.constraints;
      expect(constraints, isNotNull);
      expect(constraints!.maxWidth, customWidth);
      expect(constraints.maxHeight, customHeight);
      
      // Verify the widget is rendered
      expect(find.byType(BookImageLoadingPlaceholder), findsOneWidget);
    });

    testWidgets('should show loading text when height is greater than 80', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BookImageLoadingPlaceholder(
              height: 100.0,
            ),
          ),
        ),
      );

      // Should show loading text
      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('should not show loading text when height is 80 or less', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BookImageLoadingPlaceholder(
              height: 80.0,
            ),
          ),
        ),
      );

      // Should not show loading text
      expect(find.text('Loading...'), findsNothing);
    });

    testWidgets('should not show loading text when height is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BookImageLoadingPlaceholder(),
          ),
        ),
      );

      // Should not show loading text when height is null
      expect(find.text('Loading...'), findsNothing);
    });

    testWidgets('should apply custom background color', (WidgetTester tester) async {
      const customColor = Colors.red;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BookImageLoadingPlaceholder(
              backgroundColor: customColor,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, customColor);
    });

    testWidgets('should use theme color when no background color provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: const ColorScheme.light().copyWith(
              surfaceContainerHighest: Colors.blue,
            ),
          ),
          home: const Scaffold(
            body: BookImageLoadingPlaceholder(),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.blue);
    });

    testWidgets('should have correct border radius', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BookImageLoadingPlaceholder(),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      final borderRadius = decoration.borderRadius as BorderRadius;
      
      expect(borderRadius, BorderRadius.circular(4));
    });

    testWidgets('should center content properly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BookImageLoadingPlaceholder(),
          ),
        ),
      );

      final center = tester.widget<Center>(find.byType(Center));
      expect(center, isNotNull);
    });

    testWidgets('should have properly sized progress indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BookImageLoadingPlaceholder(),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find.byWidgetPredicate(
          (widget) => widget is SizedBox && widget.width == 20 && widget.height == 20,
        ),
      );
      
      expect(sizedBox.width, 20);
      expect(sizedBox.height, 20);
    });

    testWidgets('should have correct progress indicator stroke width', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BookImageLoadingPlaceholder(),
          ),
        ),
      );

      final progressIndicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      
      expect(progressIndicator.strokeWidth, 2);
    });
  });
}
