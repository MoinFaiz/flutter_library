import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/shared/widgets/common_displays.dart';

void main() {
  group('LoadingDisplay Tests', () {
    testWidgets('displays loading indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingDisplay(),
          ),
        ),
      );
      
      // Check if loading indicator is displayed
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays loading indicator without message', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingDisplay(),
          ),
        ),
      );
      
      // Check if loading indicator is displayed
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Check that no message text is displayed
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('displays loading indicator with message', (WidgetTester tester) async {
      const testMessage = 'Loading data...';
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingDisplay(
              message: testMessage,
            ),
          ),
        ),
      );
      
      // Check if loading indicator is displayed
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Check if message is displayed
      expect(find.text(testMessage), findsOneWidget);
    });

    testWidgets('has proper layout structure', (WidgetTester tester) async {
      const testMessage = 'Loading...';
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingDisplay(
              message: testMessage,
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
      const testMessage = 'Loading content...';
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingDisplay(
              message: testMessage,
            ),
          ),
        ),
      );
      
      // Check for SizedBox spacing
      expect(find.byType(SizedBox), findsOneWidget);
      
      // Verify spacing exists between indicator and text
      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(sizedBox.height, isNotNull);
    });

    testWidgets('message has proper text styling', (WidgetTester tester) async {
      const testMessage = 'Loading with style...';
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingDisplay(
              message: testMessage,
            ),
          ),
        ),
      );
      
      // Find the text widget
      final textFinder = find.text(testMessage);
      expect(textFinder, findsOneWidget);
      
      // Verify text alignment
      final textWidget = tester.widget<Text>(textFinder);
      expect(textWidget.textAlign, TextAlign.center);
    });

    testWidgets('handles long messages properly', (WidgetTester tester) async {
      const longMessage = 'This is a very long loading message that should wrap properly and not overflow the screen width when displayed to the user';
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingDisplay(
              message: longMessage,
            ),
          ),
        ),
      );
      
      // Check if message is displayed (should wrap)
      expect(find.text(longMessage), findsOneWidget);
      
      // Verify no overflow
      expect(tester.takeException(), isNull);
    });
  });
}
