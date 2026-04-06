import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/shared/widgets/common_displays.dart';

void main() {
  group('CommonDisplays Tests', () {
    Widget createTestWidget(Widget child) {
      return MaterialApp(
        home: Scaffold(
          body: child,
        ),
      );
    }

    group('ErrorDisplay Tests', () {
      testWidgets('displays error message correctly', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(
          ErrorDisplay(
            message: 'Something went wrong',
          ),
        ));

        // Assert
        expect(find.text('Something went wrong'), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      });

      testWidgets('shows retry button when onRetry is provided', (WidgetTester tester) async {
        // Arrange
        bool retryCalled = false;

        // Act
        await tester.pumpWidget(createTestWidget(
          ErrorDisplay(
            message: 'Network error',
            onRetry: () => retryCalled = true,
          ),
        ));

        await tester.tap(find.text('Retry'));

        // Assert
        expect(find.text('Retry'), findsOneWidget);
        expect(retryCalled, isTrue);
      });

      testWidgets('shows custom action text when provided', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(
          ErrorDisplay(
            message: 'Failed to load',
            actionText: 'Try Again',
            onRetry: () {},
          ),
        ));

        // Assert
        expect(find.text('Try Again'), findsOneWidget);
      });

      testWidgets('uses custom icon when provided', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(
          ErrorDisplay(
            message: 'Custom error',
            icon: Icons.warning,
          ),
        ));

        // Assert
        expect(find.byIcon(Icons.warning), findsOneWidget);
      });

      testWidgets('hides retry button when onRetry is null', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(
          ErrorDisplay(
            message: 'Error without retry',
          ),
        ));

        // Assert
        expect(find.byType(ElevatedButton), findsNothing);
      });

      testWidgets('applies proper styling and layout', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(
          ErrorDisplay(
            message: 'Test error',
          ),
        ));

        // Assert - Multiple centers may exist in widget tree (scaffold + error display)
        expect(find.byType(Center), findsAtLeastNWidgets(1));
        expect(find.byType(Column), findsAtLeastNWidgets(1));
        expect(find.byType(Padding), findsAtLeastNWidgets(1));
      });
    });

    group('LoadingDisplay Tests', () {
      testWidgets('displays loading indicator', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(
          LoadingDisplay(),
        ));

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('shows message when provided', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(
          LoadingDisplay(
            message: 'Loading books...',
          ),
        ));

        // Assert
        expect(find.text('Loading books...'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('hides message when not provided', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(
          LoadingDisplay(),
        ));

        // Assert
        expect(find.byType(Text), findsNothing);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('applies proper centering and layout', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(
          LoadingDisplay(message: 'Loading...'),
        ));

        // Assert
        expect(find.byType(Center), findsOneWidget);
        expect(find.byType(Column), findsOneWidget);
      });
    });

    group('EmptyDisplay Tests', () {
      testWidgets('displays title correctly', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(
          EmptyDisplay(
            title: 'No books found',
          ),
        ));

        // Assert
        expect(find.text('No books found'), findsOneWidget);
        expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
      });

      testWidgets('shows subtitle when provided', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(
          EmptyDisplay(
            title: 'No items',
            subtitle: 'Try adjusting your search criteria',
          ),
        ));

        // Assert
        expect(find.text('No items'), findsOneWidget);
        expect(find.text('Try adjusting your search criteria'), findsOneWidget);
      });

      testWidgets('shows action button when provided', (WidgetTester tester) async {
        // Arrange
        bool actionCalled = false;

        // Act
        await tester.pumpWidget(createTestWidget(
          EmptyDisplay(
            title: 'No data',
            actionText: 'Add New',
            onAction: () => actionCalled = true,
          ),
        ));

        await tester.tap(find.text('Add New'));

        // Assert
        expect(find.text('Add New'), findsOneWidget);
        expect(actionCalled, isTrue);
      });

      testWidgets('uses custom icon when provided', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(
          EmptyDisplay(
            title: 'No favorites',
            icon: Icons.favorite_border,
          ),
        ));

        // Assert
        expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      });

      testWidgets('hides action button when onAction is null', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(
          EmptyDisplay(
            title: 'Empty state',
            actionText: 'Action',
          ),
        ));

        // Assert
        expect(find.byType(ElevatedButton), findsNothing);
      });

      testWidgets('hides action button when actionText is null', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(
          EmptyDisplay(
            title: 'Empty state',
            onAction: () {},
          ),
        ));

        // Assert
        expect(find.byType(ElevatedButton), findsNothing);
      });

      testWidgets('applies proper layout and styling', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(
          EmptyDisplay(
            title: 'Test empty state',
            subtitle: 'Test subtitle',
          ),
        ));

        // Assert - Multiple centers may exist in widget tree (scaffold + empty display)
        expect(find.byType(Center), findsAtLeastNWidgets(1));
        expect(find.byType(Column), findsAtLeastNWidgets(1));
        expect(find.byType(Padding), findsAtLeastNWidgets(1));
      });

      testWidgets('handles long title text', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(
          EmptyDisplay(
            title: 'This is a very long title that should be handled properly by the widget',
          ),
        ));

        // Assert
        expect(find.text('This is a very long title that should be handled properly by the widget'), findsOneWidget);
      });

      testWidgets('handles both subtitle and action button', (WidgetTester tester) async {
        // Arrange
        bool actionCalled = false;

        // Act
        await tester.pumpWidget(createTestWidget(
          EmptyDisplay(
            title: 'Complete example',
            subtitle: 'With subtitle and action',
            actionText: 'Take Action',
            onAction: () => actionCalled = true,
          ),
        ));

        // Assert
        expect(find.text('Complete example'), findsOneWidget);
        expect(find.text('With subtitle and action'), findsOneWidget);
        expect(find.text('Take Action'), findsOneWidget);

        await tester.tap(find.text('Take Action'));
        expect(actionCalled, isTrue);
      });

      testWidgets('shows proper spacing between elements', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createTestWidget(
          EmptyDisplay(
            title: 'Spacing test',
            subtitle: 'Check spacing',
            actionText: 'Action',
            onAction: () {},
          ),
        ));

        // Assert
        expect(find.byType(SizedBox), findsWidgets);
      });
    });
  });
}
