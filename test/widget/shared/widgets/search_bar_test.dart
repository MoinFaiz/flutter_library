import 'package:flutter/material.dart' hide SearchBar;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/shared/widgets/common_widgets.dart';

void main() {
  group('SearchBar Tests', () {
    testWidgets('displays basic search bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SearchBar(),
          ),
        ),
      );
      
      // Check if search field is displayed
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('displays default hint text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SearchBar(),
          ),
        ),
      );
      
      // Check if default hint text is displayed
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.decoration?.hintText, equals('Search...'));
    });

    testWidgets('displays custom hint text', (WidgetTester tester) async {
      const customHint = 'Search for books...';
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SearchBar(
              hintText: customHint,
            ),
          ),
        ),
      );
      
      // Check if custom hint text is displayed
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.decoration?.hintText, equals(customHint));
    });

    testWidgets('displays initial value', (WidgetTester tester) async {
      const initialValue = 'Initial search';
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SearchBar(
              initialValue: initialValue,
            ),
          ),
        ),
      );
      
      // Check if initial value is displayed
      expect(find.text(initialValue), findsOneWidget);
    });

    testWidgets('shows search icon by default', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SearchBar(),
          ),
        ),
      );
      
      // Check if search icon is displayed
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('shows custom prefix icon when provided', (WidgetTester tester) async {
      const customIcon = Icon(Icons.filter_list);
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SearchBar(
              prefixIcon: customIcon,
            ),
          ),
        ),
      );
      
      // Check if custom prefix icon is displayed
      expect(find.byIcon(Icons.filter_list), findsOneWidget);
      expect(find.byIcon(Icons.search), findsNothing);
    });

    testWidgets('shows clear button when text is entered', (WidgetTester tester) async {
      const testText = 'search query';
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SearchBar(),
          ),
        ),
      );
      
      // Initially no clear button
      expect(find.byIcon(Icons.clear), findsNothing);
      
      // Enter text
      await tester.enterText(find.byType(TextField), testText);
      await tester.pump();
      
      // Clear button should appear
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('clears text when clear button is tapped', (WidgetTester tester) async {
      const testText = 'search query';
      bool clearCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchBar(
              onClear: () {
                clearCalled = true;
              },
            ),
          ),
        ),
      );
      
      // Enter text
      await tester.enterText(find.byType(TextField), testText);
      await tester.pump();
      
      // Tap clear button
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();
      
      // Text should be cleared
      expect(find.text(testText), findsNothing);
      expect(clearCalled, isTrue);
      
      // Clear button should disappear
      expect(find.byIcon(Icons.clear), findsNothing);
    });

    testWidgets('calls onChanged when text changes', (WidgetTester tester) async {
      String? changedText;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchBar(
              onChanged: (text) {
                changedText = text;
              },
            ),
          ),
        ),
      );
      
      const testText = 'search';
      await tester.enterText(find.byType(TextField), testText);
      await tester.pump();
      
      expect(changedText, equals(testText));
    });

    testWidgets('calls onSubmitted when submitted', (WidgetTester tester) async {
      String? submittedText;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchBar(
              onSubmitted: (text) {
                submittedText = text;
              },
            ),
          ),
        ),
      );
      
      const testText = 'search query';
      await tester.enterText(find.byType(TextField), testText);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      
      expect(submittedText, equals(testText));
    });

    testWidgets('can be disabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SearchBar(
              enabled: false,
            ),
          ),
        ),
      );
      
      // Check if field is disabled
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);
    });

    testWidgets('shows custom suffix icon when no text', (WidgetTester tester) async {
      const customSuffixIcon = Icon(Icons.mic);
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SearchBar(
              suffixIcon: customSuffixIcon,
            ),
          ),
        ),
      );
      
      // Check if custom suffix icon is displayed
      expect(find.byIcon(Icons.mic), findsOneWidget);
    });

    testWidgets('replaces suffix icon with clear button when text is present', (WidgetTester tester) async {
      const customSuffixIcon = Icon(Icons.mic);
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SearchBar(
              suffixIcon: customSuffixIcon,
            ),
          ),
        ),
      );
      
      // Initially shows custom suffix icon
      expect(find.byIcon(Icons.mic), findsOneWidget);
      
      // Enter text
      await tester.enterText(find.byType(TextField), 'search');
      await tester.pump();
      
      // Should show clear button instead of custom suffix icon
      expect(find.byIcon(Icons.clear), findsOneWidget);
      expect(find.byIcon(Icons.mic), findsNothing);
    });

    testWidgets('has proper styling and layout', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SearchBar(),
          ),
        ),
      );
      
      // Check if container and proper styling exist
      expect(find.byType(Container), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      
      // Verify border and fill properties
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.decoration?.border, isA<OutlineInputBorder>());
      expect(textField.decoration?.filled, isTrue);
    });
  });
}
