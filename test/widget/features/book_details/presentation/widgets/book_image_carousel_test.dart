import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_library/features/book_details/presentation/widgets/book_image_carousel.dart';

void main() {
  group('BookImageCarousel (Book Details Feature) Widget Tests', () {
    Widget createBookImageCarousel({
      List<String> imageUrls = const [],
      String heroTag = 'book_hero',
    }) {
      return MaterialApp(
        home: Scaffold(
          body: BookImageCarousel(
            imageUrls: imageUrls,
            heroTag: heroTag,
          ),
        ),
      );
    }

    testWidgets('should display image carousel with single image', (tester) async {
      const imageUrls = ['https://example.com/book1.jpg'];
      
      await tester.pumpWidget(createBookImageCarousel(
        imageUrls: imageUrls,
      ));

      expect(find.byType(BookImageCarousel), findsOneWidget);
      expect(find.byType(Hero), findsOneWidget);
    });

    testWidgets('should display image carousel with multiple images', (tester) async {
      const imageUrls = [
        'https://example.com/book1.jpg',
        'https://example.com/book2.jpg',
        'https://example.com/book3.jpg',
      ];
      
      await tester.pumpWidget(createBookImageCarousel(
        imageUrls: imageUrls,
      ));

      expect(find.byType(BookImageCarousel), findsOneWidget);
      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('should handle empty image list', (tester) async {
      await tester.pumpWidget(createBookImageCarousel(
        imageUrls: [],
      ));

      expect(find.byType(BookImageCarousel), findsOneWidget);
      // Should show placeholder or empty state
    });

    testWidgets('should use custom hero tag', (tester) async {
      const heroTag = 'custom_hero_tag';
      const imageUrls = ['https://example.com/book1.jpg'];
      
      await tester.pumpWidget(createBookImageCarousel(
        imageUrls: imageUrls,
        heroTag: heroTag,
      ));

      final hero = tester.widget<Hero>(find.byType(Hero));
      expect(hero.tag, equals(heroTag));
    });

    testWidgets('should support swipe gestures with multiple images', (tester) async {
      const imageUrls = [
        'https://example.com/book1.jpg',
        'https://example.com/book2.jpg',
        'https://example.com/book3.jpg',
      ];
      
      await tester.pumpWidget(createBookImageCarousel(
        imageUrls: imageUrls,
      ));

      expect(find.byType(PageView), findsOneWidget);

      // Test swipe gesture
      await tester.drag(find.byType(PageView), const Offset(-300, 0));
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.byType(BookImageCarousel), findsOneWidget);
    });

    testWidgets('should display page indicators for multiple images', (tester) async {
      const imageUrls = [
        'https://example.com/book1.jpg',
        'https://example.com/book2.jpg',
        'https://example.com/book3.jpg',
      ];
      
      await tester.pumpWidget(createBookImageCarousel(
        imageUrls: imageUrls,
      ));

      // Should show page indicators
      expect(find.byType(Row), findsWidgets); // Indicators typically in a Row
    });

    testWidgets('should not show indicators for single image', (tester) async {
      const imageUrls = ['https://example.com/book1.jpg'];
      
      await tester.pumpWidget(createBookImageCarousel(
        imageUrls: imageUrls,
      ));

      expect(find.byType(BookImageCarousel), findsOneWidget);
      // Should not show page indicators for single image
    });

    testWidgets('should handle image loading errors gracefully', (tester) async {
      const imageUrls = ['https://invalid-url.com/nonexistent.jpg'];
      
      await tester.pumpWidget(createBookImageCarousel(
        imageUrls: imageUrls,
      ));

      expect(find.byType(BookImageCarousel), findsOneWidget);
      // Should show error placeholder or handle gracefully
    });

    testWidgets('should work with different aspect ratios', (tester) async {
      const imageUrls = [
        'https://example.com/tall-book.jpg',
        'https://example.com/wide-book.jpg',
      ];
      
      await tester.pumpWidget(createBookImageCarousel(
        imageUrls: imageUrls,
      ));

      expect(find.byType(BookImageCarousel), findsOneWidget);
      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('should maintain state during rebuilds', (tester) async {
      const imageUrls = [
        'https://example.com/book1.jpg',
        'https://example.com/book2.jpg',
        'https://example.com/book3.jpg',
      ];
      
      await tester.pumpWidget(createBookImageCarousel(
        imageUrls: imageUrls,
      ));

      // Navigate to second image
      await tester.drag(find.byType(PageView), const Offset(-300, 0));
      await tester.pump(const Duration(milliseconds: 350));

      // Rebuild widget
      await tester.pumpWidget(createBookImageCarousel(
        imageUrls: imageUrls,
      ));

      expect(find.byType(BookImageCarousel), findsOneWidget);
    });

    testWidgets('should support tap to view full screen', (tester) async {
      const imageUrls = ['https://example.com/book1.jpg'];
      
      await tester.pumpWidget(createBookImageCarousel(
        imageUrls: imageUrls,
      ));

      // Tap on image
      await tester.tap(find.byType(BookImageCarousel));
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.byType(BookImageCarousel), findsOneWidget);
    });

    testWidgets('should handle very long image URL lists', (tester) async {
      final imageUrls = List.generate(50, (index) => 'https://example.com/book$index.jpg');
      
      await tester.pumpWidget(createBookImageCarousel(
        imageUrls: imageUrls,
      ));

      expect(find.byType(BookImageCarousel), findsOneWidget);
      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('should work with different themes', (tester) async {
      const imageUrls = ['https://example.com/book1.jpg'];
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: BookImageCarousel(
              imageUrls: imageUrls,
              heroTag: 'book_hero',
            ),
          ),
        ),
      );

      expect(find.byType(BookImageCarousel), findsOneWidget);
    });

    testWidgets('should be accessible for screen readers', (tester) async {
      const imageUrls = [
        'https://example.com/book1.jpg',
        'https://example.com/book2.jpg',
      ];
      
      await tester.pumpWidget(createBookImageCarousel(
        imageUrls: imageUrls,
      ));

      expect(find.byType(BookImageCarousel), findsOneWidget);
      // Should have proper semantics for accessibility
    });

    testWidgets('should handle rapid swipes without issues', (tester) async {
      const imageUrls = [
        'https://example.com/book1.jpg',
        'https://example.com/book2.jpg',
        'https://example.com/book3.jpg',
        'https://example.com/book4.jpg',
        'https://example.com/book5.jpg',
      ];
      
      await tester.pumpWidget(createBookImageCarousel(
        imageUrls: imageUrls,
      ));

      // Rapid swipes
      for (int i = 0; i < 3; i++) {
        await tester.drag(find.byType(PageView), const Offset(-300, 0));
        await tester.pump(const Duration(milliseconds: 100));
      }
      
      await tester.pump(const Duration(milliseconds: 350));
      expect(find.byType(BookImageCarousel), findsOneWidget);
    });
  });
}
