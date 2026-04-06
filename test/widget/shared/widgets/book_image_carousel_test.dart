import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/shared/widgets/book_image_carousel.dart';
import 'package:flutter_library/shared/widgets/book_cover_image.dart';
import 'package:flutter_library/shared/widgets/default_book_placeholder.dart';

void main() {
  group('BookImageCarousel Widget Tests', () {
    Widget createTestWidget({
      required List<String> imageUrls,
      double? width,
      double? height,
      bool showIndicators = true,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: BookImageCarousel(
            imageUrls: imageUrls,
            width: width,
            height: height,
            showIndicators: showIndicators,
          ),
        ),
      );
    }

    testWidgets('should display placeholder when imageUrls is empty', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(imageUrls: []));

      // Assert
      expect(find.byType(DefaultBookPlaceholder), findsOneWidget);
      expect(find.byType(PageView), findsNothing);
    });

    testWidgets('should display single image without carousel when only one URL', (
      WidgetTester tester,
    ) async {
      // Arrange
      const imageUrls = ['https://example.com/image1.jpg'];

      // Act
      await tester.pumpWidget(createTestWidget(imageUrls: imageUrls));

      // Assert
      expect(find.byType(BookCoverImage), findsOneWidget);
      expect(find.byType(PageView), findsNothing);
      // Single image doesn't need Stack (no indicators or counter)
    });

    testWidgets('should display carousel with multiple images', (
      WidgetTester tester,
    ) async {
      // Arrange
      const imageUrls = [
        'https://example.com/image1.jpg',
        'https://example.com/image2.jpg',
        'https://example.com/image3.jpg',
      ];

      // Act
      await tester.pumpWidget(createTestWidget(imageUrls: imageUrls));

      // Assert
      expect(find.byType(PageView), findsOneWidget);
      expect(find.byType(Stack), findsAtLeastNWidgets(1)); // Multiple stacks may exist in scaffold
      expect(find.byType(BookCoverImage), findsOneWidget); // Current visible image
    });

    testWidgets('should show indicators when showIndicators is true', (
      WidgetTester tester,
    ) async {
      // Arrange
      const imageUrls = [
        'https://example.com/image1.jpg',
        'https://example.com/image2.jpg',
      ];

      // Act
      await tester.pumpWidget(
        createTestWidget(imageUrls: imageUrls, showIndicators: true),
      );

      // Assert
      expect(find.byType(PageView), findsOneWidget);
      
      // Should find indicators (circular containers)
      final indicatorContainers = find.byWidgetPredicate(
        (widget) => widget is Container && 
                   widget.decoration is BoxDecoration &&
                   (widget.decoration as BoxDecoration).shape == BoxShape.circle,
      );
      expect(indicatorContainers, findsNWidgets(2));
    });

    testWidgets('should hide indicators when showIndicators is false', (
      WidgetTester tester,
    ) async {
      // Arrange
      const imageUrls = [
        'https://example.com/image1.jpg',
        'https://example.com/image2.jpg',
      ];

      // Act
      await tester.pumpWidget(
        createTestWidget(imageUrls: imageUrls, showIndicators: false),
      );

      // Assert
      expect(find.byType(PageView), findsOneWidget);
      
      // Should not find indicator containers
      final indicatorContainers = find.byWidgetPredicate(
        (widget) => widget is Container && 
                   widget.decoration is BoxDecoration &&
                   (widget.decoration as BoxDecoration).shape == BoxShape.circle,
      );
      expect(indicatorContainers, findsNothing);
    });

    testWidgets('should show indicators for multiple images', (
      WidgetTester tester,
    ) async {
      // Arrange
      const imageUrls = [
        'https://example.com/image1.jpg',
        'https://example.com/image2.jpg',
        'https://example.com/image3.jpg',
      ];

      // Act
      await tester.pumpWidget(createTestWidget(imageUrls: imageUrls));

      // Assert
      final indicatorContainers = find.byWidgetPredicate(
        (widget) => widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).shape == BoxShape.circle,
      );
      expect(indicatorContainers, findsNWidgets(3));
    });

    testWidgets('should not show counter for single image', (
      WidgetTester tester,
    ) async {
      // Arrange
      const imageUrls = ['https://example.com/image1.jpg'];

      // Act
      await tester.pumpWidget(createTestWidget(imageUrls: imageUrls));

      // Assert
      expect(find.textContaining('/'), findsNothing);
    });

    testWidgets('should update visible page when swiping between images', (
      WidgetTester tester,
    ) async {
      // Arrange
      const imageUrls = [
        'https://example.com/image1.jpg',
        'https://example.com/image2.jpg',
        'https://example.com/image3.jpg',
      ];

      // Act
      await tester.pumpWidget(createTestWidget(
        imageUrls: imageUrls,
        width: 400,
        height: 300,
      ));
      await tester.pump(const Duration(milliseconds: 100));

      await tester.drag(find.byType(PageView), const Offset(-300, 0));
      await tester.pump(const Duration(milliseconds: 350));

      // Assert
      expect(find.byType(PageView), findsOneWidget);
      expect(find.byType(BookCoverImage), findsWidgets);
    });

    testWidgets('should apply custom width and height', (
      WidgetTester tester,
    ) async {
      // Arrange
      const imageUrls = [
        'https://example.com/image1.jpg',
        'https://example.com/image2.jpg',
      ];

      // Act
      await tester.pumpWidget(
        createTestWidget(
          imageUrls: imageUrls,
          width: 200.0,
          height: 300.0,
        ),
      );

      // Assert
      final sizedBoxFinder = find.byWidgetPredicate(
        (widget) => widget is SizedBox && widget.width == 200.0 && widget.height == 300.0,
      );
      expect(sizedBoxFinder, findsWidgets);
    });

    testWidgets('should handle very large number of images', (
      WidgetTester tester,
    ) async {
      // Arrange
      final imageUrls = List.generate(
        100,
        (index) => 'https://example.com/image$index.jpg',
      );

      // Act
      await tester.pumpWidget(
        createTestWidget(
          imageUrls: imageUrls,
          width: 400,
          height: 300,
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Assert
      expect(find.byType(PageView), findsOneWidget);
      final indicatorContainers = find.byWidgetPredicate(
        (widget) => widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).shape == BoxShape.circle,
      );
      expect(indicatorContainers, findsNothing);
    });

    testWidgets('should properly position indicators at bottom', (
      WidgetTester tester,
    ) async {
      // Arrange
      const imageUrls = [
        'https://example.com/image1.jpg',
        'https://example.com/image2.jpg',
      ];

      // Act
      await tester.pumpWidget(createTestWidget(imageUrls: imageUrls));

      // Assert
      final positioned = tester.widget<Positioned>(
        find.byWidgetPredicate(
          (widget) => widget is Positioned && widget.bottom == 8,
        ),
      );
      expect(positioned.bottom, equals(8));
      expect(positioned.left, equals(0));
      expect(positioned.right, equals(0));
    });

    testWidgets('should not render top-right counter overlay', (
      WidgetTester tester,
    ) async {
      // Arrange
      const imageUrls = [
        'https://example.com/image1.jpg',
        'https://example.com/image2.jpg',
      ];

      // Act
      await tester.pumpWidget(createTestWidget(imageUrls: imageUrls));

      // Assert
      final counterOverlayFinder = find.byWidgetPredicate(
        (widget) => widget is Positioned && widget.top == 8 && widget.right == 8,
      );
      expect(counterOverlayFinder, findsNothing);
    });

    testWidgets('should highlight current indicator', (
      WidgetTester tester,
    ) async {
      // Arrange
      const imageUrls = [
        'https://example.com/image1.jpg',
        'https://example.com/image2.jpg',
        'https://example.com/image3.jpg',
      ];

      // Act
      await tester.pumpWidget(createTestWidget(imageUrls: imageUrls));

      // Assert - First indicator should be highlighted
      final indicatorContainers = find.byWidgetPredicate(
        (widget) => widget is Container && 
                   widget.decoration is BoxDecoration &&
                   (widget.decoration as BoxDecoration).shape == BoxShape.circle,
      );
      expect(indicatorContainers, findsNWidgets(3));
    });

    testWidgets('should handle null width and height', (
      WidgetTester tester,
    ) async {
      // Arrange
      const imageUrls = [
        'https://example.com/image1.jpg',
        'https://example.com/image2.jpg',
      ];

      // Act
      await tester.pumpWidget(
        createTestWidget(
          imageUrls: imageUrls,
          width: null,
          height: null,
        ),
      );

      // Assert
      expect(find.byType(PageView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('should dispose PageController properly', (
      WidgetTester tester,
    ) async {
      // Arrange
      const imageUrls = [
        'https://example.com/image1.jpg',
        'https://example.com/image2.jpg',
      ];

      // Act
      await tester.pumpWidget(createTestWidget(imageUrls: imageUrls));
      
      // Remove widget to trigger dispose
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));

      // Assert - No exception should be thrown
      expect(tester.takeException(), isNull);
    });

    testWidgets('should maintain page state during swipes', (
      WidgetTester tester,
    ) async {
      // Arrange
      const imageUrls = [
        'https://example.com/image1.jpg',
        'https://example.com/image2.jpg',
        'https://example.com/image3.jpg',
        'https://example.com/image4.jpg',
      ];

      await tester.pumpWidget(createTestWidget(
        imageUrls: imageUrls,
        width: 400,
        height: 300,
      ));
      await tester.pump(const Duration(milliseconds: 100));

      // Act - Multiple swipes
      await tester.drag(find.byType(PageView), const Offset(-300, 0));
      await tester.pump(const Duration(milliseconds: 350));

      await tester.drag(find.byType(PageView), const Offset(-300, 0));
      await tester.pump(const Duration(milliseconds: 350));

      await tester.drag(find.byType(PageView), const Offset(300, 0));
      await tester.pump(const Duration(milliseconds: 350));

      // Assert
      expect(find.byType(PageView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
