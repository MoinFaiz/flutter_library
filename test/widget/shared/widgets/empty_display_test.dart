import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/shared/widgets/common_displays.dart';

void main() {
  group('EmptyDisplay Tests', () {
    testWidgets('displays basic empty state with title', (WidgetTester tester) async {
      const testTitle = 'No items found';
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyDisplay(
              title: testTitle,
            ),
          ),
        ),
      );
      
      // Check if title is displayed
      expect(find.text(testTitle), findsOneWidget);
    });

    testWidgets('displays default empty icon', (WidgetTester tester) async {
      const testTitle = 'Empty state';
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyDisplay(
              title: testTitle,
            ),
          ),
        ),
      );
      
      // Check if default empty icon is displayed
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('displays custom icon when provided', (WidgetTester tester) async {
      const testTitle = 'Custom empty state';
      const customIcon = Icons.folder_open;
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyDisplay(
              title: testTitle,
              icon: customIcon,
            ),
          ),
        ),
      );
      
      // Check if custom icon is displayed
      expect(find.byIcon(customIcon), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsNothing);
    });

    testWidgets('displays title and subtitle', (WidgetTester tester) async {
      const testTitle = 'No books available';
      const testSubtitle = 'Try adjusting your search criteria or check back later';
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyDisplay(
              title: testTitle,
              subtitle: testSubtitle,
            ),
          ),
        ),
      );
      
      // Check if both title and subtitle are displayed
      expect(find.text(testTitle), findsOneWidget);
      expect(find.text(testSubtitle), findsOneWidget);
    });

    testWidgets('shows action button when provided', (WidgetTester tester) async {
      const testTitle = 'No results';
      const actionText = 'Refresh';
      bool actionPressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyDisplay(
              title: testTitle,
              actionText: actionText,
              onAction: () {
                actionPressed = true;
              },
            ),
          ),
        ),
      );
      
      // Check if action button is displayed
      expect(find.text(actionText), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      
      // Tap action button
      await tester.tap(find.text(actionText));
      await tester.pump();
      
      // Verify callback was called
      expect(actionPressed, isTrue);
    });

    testWidgets('does not show action button when onAction is null', (WidgetTester tester) async {
      const testTitle = 'Empty state without action';
      const actionText = 'Should not appear';
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyDisplay(
              title: testTitle,
              actionText: actionText,
              // onAction is null
            ),
          ),
        ),
      );
      
      // Check that action button is not displayed
      expect(find.text(actionText), findsNothing);
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('does not show action button when actionText is null', (WidgetTester tester) async {
      const testTitle = 'Empty state without text';
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyDisplay(
              title: testTitle,
              // actionText is null
              onAction: () {},
            ),
          ),
        ),
      );
      
      // Check that action button is not displayed
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('has proper layout structure', (WidgetTester tester) async {
      const testTitle = 'Layout test';
      const testSubtitle = 'Subtitle for testing';
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyDisplay(
              title: testTitle,
              subtitle: testSubtitle,
            ),
          ),
        ),
      );
      
      // Check if main layout components exist
      expect(find.byType(Center), findsWidgets);
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(Padding), findsOneWidget);
    });

    testWidgets('displays proper spacing between elements', (WidgetTester tester) async {
      const testTitle = 'Spacing test';
      const testSubtitle = 'Test subtitle';
      const actionText = 'Test Action';
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyDisplay(
              title: testTitle,
              subtitle: testSubtitle,
              actionText: actionText,
              onAction: () {},
            ),
          ),
        ),
      );
      
      // Check for SizedBox spacing elements
      expect(find.byType(SizedBox), findsWidgets);
      
      // Verify multiple spacing elements exist
      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      expect(sizedBoxes.length, greaterThan(1));
    });

    testWidgets('title has proper text styling', (WidgetTester tester) async {
      const testTitle = 'Styled title';
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyDisplay(
              title: testTitle,
            ),
          ),
        ),
      );
      
      // Find the title text widget
      final titleFinder = find.text(testTitle);
      expect(titleFinder, findsOneWidget);
      
      // Verify text alignment
      final titleWidget = tester.widget<Text>(titleFinder);
      expect(titleWidget.textAlign, TextAlign.center);
    });

    testWidgets('handles long title and subtitle properly', (WidgetTester tester) async {
      const longTitle = 'This is a very long title that should wrap properly and not overflow the screen width';
      const longSubtitle = 'This is an even longer subtitle that provides detailed information about the empty state and should also wrap properly without causing any overflow issues';
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyDisplay(
              title: longTitle,
              subtitle: longSubtitle,
            ),
          ),
        ),
      );
      
      // Check if both texts are displayed (should wrap)
      expect(find.text(longTitle), findsOneWidget);
      expect(find.text(longSubtitle), findsOneWidget);
      
      // Verify no overflow
      expect(tester.takeException(), isNull);
    });
  });
}
