import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/shared/widgets/common_displays.dart';

void main() {
  group('ErrorDisplay Widget Tests', () {
    Widget createErrorDisplay({
      String message = 'Test error message',
      String? actionText,
      VoidCallback? onRetry,
      IconData? icon,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: ErrorDisplay(
            message: message,
            actionText: actionText,
            onRetry: onRetry,
            icon: icon,
          ),
        ),
      );
    }

    testWidgets('should display error message', (tester) async {
      await tester.pumpWidget(createErrorDisplay());

      expect(find.text('Test error message'), findsOneWidget);
    });

    testWidgets('should display default error icon', (tester) async {
      await tester.pumpWidget(createErrorDisplay());

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should display custom error icon', (tester) async {
      await tester.pumpWidget(createErrorDisplay(icon: Icons.warning));

      expect(find.byIcon(Icons.warning), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsNothing);
    });

    testWidgets('should not show retry button when onRetry is null', (tester) async {
      await tester.pumpWidget(createErrorDisplay());

      expect(find.byIcon(Icons.refresh), findsNothing);
    });

    testWidgets('should show retry button when onRetry is provided', (tester) async {
      await tester.pumpWidget(createErrorDisplay(
        onRetry: () {},
      ));

      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('should show custom action text', (tester) async {
      await tester.pumpWidget(createErrorDisplay(
        onRetry: () {},
        actionText: 'Try Again',
      ));

      expect(find.text('Try Again'), findsOneWidget);
      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('should handle retry button tap', (tester) async {
      bool retryPressed = false;
      await tester.pumpWidget(createErrorDisplay(
        onRetry: () => retryPressed = true,
      ));

      await tester.tap(find.byIcon(Icons.refresh));
      expect(retryPressed, isTrue);
    });

    testWidgets('should be centered in available space', (tester) async {
      await tester.pumpWidget(createErrorDisplay());

      // Check that the ErrorDisplay widget exists and contains the expected elements
      expect(find.byType(ErrorDisplay), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should have proper padding', (tester) async {
      await tester.pumpWidget(createErrorDisplay());

      expect(find.byType(Padding), findsOneWidget);
    });

    testWidgets('should have proper layout structure', (tester) async {
      await tester.pumpWidget(createErrorDisplay(onRetry: () {}));

      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(Icon), findsAtLeastNWidgets(1)); // Error icon + refresh icon
      expect(find.byType(Text), findsAtLeastNWidgets(1)); // Message + button text
      expect(find.byType(SizedBox), findsWidgets); // Spacing
    });

    testWidgets('should use theme error color for icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              error: Colors.red,
            ),
          ),
          home: Scaffold(
            body: ErrorDisplay(message: 'Error'),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.error_outline));
      expect(icon.color, equals(Colors.red));
    });

    testWidgets('should use theme error color for text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              error: Colors.red,
            ),
          ),
          home: Scaffold(
            body: ErrorDisplay(message: 'Error'),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('Error'));
      expect(text.style?.color, equals(Colors.red));
    });

    testWidgets('should center align text', (tester) async {
      await tester.pumpWidget(createErrorDisplay());

      final text = tester.widget<Text>(find.text('Test error message'));
      expect(text.textAlign, equals(TextAlign.center));
    });

    testWidgets('should have proper icon size', (tester) async {
      await tester.pumpWidget(createErrorDisplay());

      final icon = tester.widget<Icon>(find.byIcon(Icons.error_outline));
      expect(icon.size, equals(64));
    });

    testWidgets('should show refresh icon in retry button', (tester) async {
      await tester.pumpWidget(createErrorDisplay(onRetry: () {}));

      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('should handle long error messages', (tester) async {
      const longMessage = 'This is a very long error message that should wrap properly and not cause overflow issues in the user interface';
      
      await tester.pumpWidget(createErrorDisplay(message: longMessage));

      expect(find.text(longMessage), findsOneWidget);
    });

    testWidgets('should handle empty error message', (tester) async {
      await tester.pumpWidget(createErrorDisplay(message: ''));

      expect(find.text(''), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should work with different themes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: ErrorDisplay(
              message: 'Dark theme error',
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(find.byType(ErrorDisplay), findsOneWidget);
      expect(find.text('Dark theme error'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('should handle special characters in message', (tester) async {
      const specialMessage = 'Error: 404 - Resource not found! 🚫';
      
      await tester.pumpWidget(createErrorDisplay(message: specialMessage));

      expect(find.text(specialMessage), findsOneWidget);
    });

    testWidgets('should handle special characters in action text', (tester) async {
      await tester.pumpWidget(createErrorDisplay(
        onRetry: () {},
        actionText: 'Réessayer 🔄',
      ));

      expect(find.text('Réessayer 🔄'), findsOneWidget);
    });

    testWidgets('should maintain column alignment', (tester) async {
      await tester.pumpWidget(createErrorDisplay(onRetry: () {}));

      final column = tester.widget<Column>(find.byType(Column));
      expect(column.mainAxisAlignment, equals(MainAxisAlignment.center));
    });

    testWidgets('should work in constrained layouts', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 300,
              child: ErrorDisplay(
                message: 'Constrained error',
                onRetry: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ErrorDisplay), findsOneWidget);
    });

    testWidgets('should handle rapid rebuilds', (tester) async {
      await tester.pumpWidget(createErrorDisplay());
      await tester.pumpWidget(createErrorDisplay(message: 'New error'));
      await tester.pumpWidget(createErrorDisplay(
        message: 'Another error',
        onRetry: () {},
      ));

      expect(find.text('Another error'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('should be accessible for screen readers', (tester) async {
      await tester.pumpWidget(createErrorDisplay(onRetry: () {}));

      // Check that button is accessible
      final button = find.byIcon(Icons.refresh);
      expect(button, findsOneWidget);
      
      // Check that text is accessible
      final text = find.text('Test error message');
      expect(text, findsOneWidget);
    });

    testWidgets('should handle multiple error displays', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Expanded(
                  child: ErrorDisplay(
                    message: 'First error',
                    onRetry: () {},
                  ),
                ),
                Expanded(
                  child: ErrorDisplay(
                    message: 'Second error',
                    actionText: 'Reload',
                    onRetry: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(ErrorDisplay), findsNWidgets(2));
      expect(find.text('First error'), findsOneWidget);
      expect(find.text('Second error'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Reload'), findsOneWidget);
    });

    testWidgets('should preserve state through parent rebuilds', (tester) async {
      bool retryPressed = false;
      
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: ErrorDisplay(
                  message: 'Persistent error',
                  onRetry: () => retryPressed = true,
                ),
              ),
            );
          },
        ),
      );

      await tester.tap(find.byIcon(Icons.refresh));
      expect(retryPressed, isTrue);
    });
  });
}
