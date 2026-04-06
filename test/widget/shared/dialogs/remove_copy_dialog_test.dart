import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/book_upload/presentation/widgets/dialogs/remove_copy_dialog.dart';

void main() {
  group('RemoveCopyDialog Widget Tests', () {
    testWidgets('should display dialog title and warning icon', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => RemoveCopyDialog(
                      copyIndex: 0,
                      onRemove: (reason) {},
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Trigger dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Remove Copy'), findsNWidgets(2)); // Title and button
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      expect(find.textContaining('Are you sure you want to remove Copy 1?'), findsOneWidget);
    });

    testWidgets('should display removal reason selection components', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => RemoveCopyDialog(
                      copyIndex: 0,
                      onRemove: (reason) {},
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Trigger dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Assert - Check for reason selection components
      expect(find.text('Please select a reason for removal:'), findsOneWidget);
      expect(find.text('Select reason'), findsOneWidget);
      expect(find.byType(InputDecorator), findsOneWidget); // Dropdown has InputDecorator
    });

    testWidgets('should properly handle different copy indices', (tester) async {
      // Test with different copy index
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => RemoveCopyDialog(
                      copyIndex: 2,
                      onRemove: (reason) {},
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Trigger dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Assert - Check copy index is correctly displayed (copyIndex + 1)
      expect(find.textContaining('Copy 3'), findsOneWidget);
    });

    testWidgets('should have remove button initially disabled', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => RemoveCopyDialog(
                      copyIndex: 0,
                      onRemove: (reason) {},
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Trigger dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Find the "Remove Copy" button (not the title)
      final removeButtons = find.text('Remove Copy');
      expect(removeButtons, findsNWidgets(2)); // Title and button

      // Get the button widget (second occurrence)
      final buttonFinder = find.byWidgetPredicate((widget) => 
          widget is ElevatedButton && 
          (widget.child as Text?)?.data == 'Remove Copy');
      
      expect(buttonFinder, findsOneWidget);
      
      // Check if button is disabled (onPressed should be null)
      final ElevatedButton button = tester.widget(buttonFinder);
      expect(button.onPressed, isNull);
    });

    testWidgets('should cancel dialog when cancel button is pressed', (tester) async {
      // Arrange
      bool callbackCalled = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => RemoveCopyDialog(
                      copyIndex: 0,
                      onRemove: (reason) {
                        callbackCalled = true;
                      },
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Trigger dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify dialog is open
      expect(find.text('Remove Copy'), findsNWidgets(2));

      // Cancel dialog
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Assert
      expect(callbackCalled, isFalse);
      expect(find.text('Remove Copy'), findsNothing); // Dialog should be closed
    });

    testWidgets('has proper dialog structure and elements', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => RemoveCopyDialog(
                      copyIndex: 1,
                      onRemove: (reason) {},
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Trigger dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Assert - Basic dialog structure
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.textContaining('Copy 2'), findsOneWidget); // copyIndex + 1
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Remove Copy'), findsNWidgets(2)); // Title and button
      expect(find.text('Please select a reason for removal:'), findsOneWidget);
      expect(find.text('Select reason'), findsOneWidget);
    });

    testWidgets('should be accessible and properly structured', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => RemoveCopyDialog(
                      copyIndex: 0,
                      onRemove: (reason) {},
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Trigger dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Assert - Check for accessibility and structure
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget); // Content is scrollable
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      
      // Check that all required text elements are present
      expect(find.text('Remove Copy'), findsNWidgets(2));
      expect(find.text('Please select a reason for removal:'), findsOneWidget);
      expect(find.text('Select reason'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });
  });
}
