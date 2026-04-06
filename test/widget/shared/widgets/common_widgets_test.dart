import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/shared/widgets/common_widgets.dart' as common;

void main() {
  group('Common Widgets Tests', () {
    group('SearchBar Tests', () {
      Widget createSearchBarWidget({
        String? hintText,
        String? initialValue,
        ValueChanged<String>? onChanged,
        ValueChanged<String>? onSubmitted,
        VoidCallback? onClear,
        bool enabled = true,
        Widget? prefixIcon,
        Widget? suffixIcon,
      }) {
        return MaterialApp(
          home: Scaffold(
            body: common.SearchBar(
              hintText: hintText,
              initialValue: initialValue,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              onClear: onClear,
              enabled: enabled,
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
            ),
          ),
        );
      }

      testWidgets('displays default hint text', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createSearchBarWidget());

        // Assert
        expect(find.text('Search...'), findsOneWidget);
      });

      testWidgets('displays custom hint text', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createSearchBarWidget(hintText: 'Search books...'));

        // Assert
        expect(find.text('Search books...'), findsOneWidget);
      });

      testWidgets('displays initial value', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createSearchBarWidget(initialValue: 'Initial text'));

        // Assert
        expect(find.text('Initial text'), findsOneWidget);
      });

      testWidgets('shows default search icon', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createSearchBarWidget());

        // Assert
        expect(find.byIcon(Icons.search), findsOneWidget);
      });

      testWidgets('shows custom prefix icon', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createSearchBarWidget(
          prefixIcon: const Icon(Icons.book),
        ));

        // Assert
        expect(find.byIcon(Icons.book), findsOneWidget);
        expect(find.byIcon(Icons.search), findsNothing);
      });

      testWidgets('shows clear button when text is entered', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createSearchBarWidget());
        await tester.enterText(find.byType(TextField), 'test');
        await tester.pump();

        // Assert
        expect(find.byIcon(Icons.clear), findsOneWidget);
      });

      testWidgets('hides clear button when text is empty', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createSearchBarWidget());

        // Assert
        expect(find.byIcon(Icons.clear), findsNothing);
      });

      testWidgets('calls onChanged when text changes', (WidgetTester tester) async {
        // Arrange
        String? changedText;

        // Act
        await tester.pumpWidget(createSearchBarWidget(
          onChanged: (text) => changedText = text,
        ));
        await tester.enterText(find.byType(TextField), 'new text');

        // Assert
        expect(changedText, equals('new text'));
      });

      testWidgets('calls onSubmitted when text is submitted', (WidgetTester tester) async {
        // Arrange
        String? submittedText;

        // Act
        await tester.pumpWidget(createSearchBarWidget(
          onSubmitted: (text) => submittedText = text,
        ));
        await tester.enterText(find.byType(TextField), 'submitted text');
        await tester.testTextInput.receiveAction(TextInputAction.done);

        // Assert
        expect(submittedText, equals('submitted text'));
      });

      testWidgets('clears text when clear button is pressed', (WidgetTester tester) async {
        // Arrange
        bool clearCalled = false;

        // Act
        await tester.pumpWidget(createSearchBarWidget(
          onClear: () => clearCalled = true,
        ));
        await tester.enterText(find.byType(TextField), 'text to clear');
        await tester.pump();
        await tester.tap(find.byIcon(Icons.clear));
        await tester.pump();

        // Assert
        expect(find.text('text to clear'), findsNothing);
        expect(clearCalled, isTrue);
      });

      testWidgets('can be disabled', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createSearchBarWidget(enabled: false));

        // Assert
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.enabled, isFalse);
      });

      testWidgets('shows custom suffix icon when no text', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createSearchBarWidget(
          suffixIcon: const Icon(Icons.filter_list),
        ));

        // Assert
        expect(find.byIcon(Icons.filter_list), findsOneWidget);
      });

      testWidgets('prioritizes clear button over custom suffix icon when text exists', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createSearchBarWidget(
          suffixIcon: const Icon(Icons.filter_list),
        ));
        await tester.enterText(find.byType(TextField), 'test');
        await tester.pump();

        // Assert
        expect(find.byIcon(Icons.clear), findsOneWidget);
        expect(find.byIcon(Icons.filter_list), findsNothing);
      });

      testWidgets('has proper layout structure', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createSearchBarWidget());

        // Assert
        expect(find.byType(Container), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);
      });

      testWidgets('maintains state correctly with initial value', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createSearchBarWidget(initialValue: 'initial'));
        
        // Assert - Should show clear button since there's initial text
        expect(find.byIcon(Icons.clear), findsOneWidget);
      });

      testWidgets('updates state when external controller changes', (WidgetTester tester) async {
        // Arrange
        String? changedText;

        // Act
        await tester.pumpWidget(createSearchBarWidget(
          onChanged: (text) => changedText = text,
        ));
        
        // Type text and verify callback
        await tester.enterText(find.byType(TextField), 'dynamic text');
        await tester.pump(); // Pump to update state
        
        // Assert
        expect(changedText, equals('dynamic text'));
        expect(find.byIcon(Icons.clear), findsOneWidget);
      });

      testWidgets('handles rapid text changes correctly', (WidgetTester tester) async {
        // Arrange
        final textChanges = <String>[];

        // Act
        await tester.pumpWidget(createSearchBarWidget(
          onChanged: (text) => textChanges.add(text),
        ));
        
        await tester.enterText(find.byType(TextField), 'a');
        await tester.pump();
        await tester.enterText(find.byType(TextField), 'ab');
        await tester.pump();
        await tester.enterText(find.byType(TextField), 'abc');
        await tester.pump();

        // Assert
        expect(textChanges, contains('a'));
        expect(textChanges, contains('ab'));
        expect(textChanges, contains('abc'));
      });
    });
  });
}
