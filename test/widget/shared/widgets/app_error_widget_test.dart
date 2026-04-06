import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/shared/widgets/app_error_widget.dart';

void main() {
  group('AppErrorWidget Tests', () {
    testWidgets('displays error message correctly', (WidgetTester tester) async {
      // Arrange
      const errorMessage = 'Something went wrong';

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppErrorWidget(
              message: errorMessage,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(errorMessage), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('displays retry button when onRetry is provided', (WidgetTester tester) async {
      // Arrange
      bool retryPressed = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppErrorWidget(
              message: 'Error occurred',
              onRetry: () => retryPressed = true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Try Again'), findsOneWidget);
      
      // Test retry button functionality
      await tester.tap(find.text('Try Again'));
      expect(retryPressed, isTrue);
    });

    testWidgets('hides retry button when onRetry is not provided', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppErrorWidget(
              message: 'Error occurred',
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Try Again'), findsNothing);
    });

    testWidgets('displays custom icon when provided', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppErrorWidget(
              message: 'Custom error',
              icon: Icons.warning,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.warning), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsNothing);
    });

    testWidgets('has proper layout structure', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppErrorWidget(
              message: 'Error message',
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(Icon), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('handles long error messages gracefully', (WidgetTester tester) async {
      // Arrange
      const longMessage = 'This is a very long error message that should wrap properly and not cause any overflow issues in the UI layout when displayed to the user';

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppErrorWidget(
              message: longMessage,
            ),
          ),
        ),
      );

      // Assert
      expect(find.textContaining('This is a very long error message'), findsOneWidget);
      expect(tester.takeException(), isNull); // No overflow exceptions
    });
  });
}
