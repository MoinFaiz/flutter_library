import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/shared/widgets/loading_widget.dart';

void main() {
  group('LoadingWidget Tests', () {
    Widget createLoadingWidget({
      String? message,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: LoadingWidget(
            message: message,
          ),
        ),
      );
    }

    testWidgets('should display circular progress indicator', (tester) async {
      await tester.pumpWidget(createLoadingWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should not display message when none provided', (tester) async {
      await tester.pumpWidget(createLoadingWidget());

      expect(find.byType(Text), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display custom loading message', (tester) async {
      await tester.pumpWidget(createLoadingWidget(
        message: 'Custom loading message',
      ));

      expect(find.text('Custom loading message'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should be centered in available space', (tester) async {
      await tester.pumpWidget(createLoadingWidget());

      expect(find.byType(Center), findsOneWidget);
    });

    testWidgets('should have proper spacing between indicator and message', (tester) async {
      await tester.pumpWidget(createLoadingWidget(message: 'Loading...'));

      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('should handle empty message gracefully', (tester) async {
      await tester.pumpWidget(createLoadingWidget(message: ''));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text(''), findsOneWidget);
    });

    testWidgets('should handle null message gracefully', (tester) async {
      await tester.pumpWidget(createLoadingWidget(message: null));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('should work with different themes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: LoadingWidget(message: 'Loading...'),
          ),
        ),
      );

      expect(find.byType(LoadingWidget), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('should animate continuously', (tester) async {
      await tester.pumpWidget(createLoadingWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Pump animation frames
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Should still be visible and animating
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should handle very long messages', (tester) async {
      const longMessage = 'This is a very long loading message that should wrap properly and not cause overflow issues in the UI';
      
      await tester.pumpWidget(createLoadingWidget(message: longMessage));

      expect(find.text(longMessage), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should use theme text style', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            textTheme: const TextTheme(
              bodyMedium: TextStyle(fontSize: 18, color: Colors.purple),
            ),
          ),
          home: Scaffold(
            body: LoadingWidget(message: 'Loading...'),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Loading...'));
      expect(textWidget.style?.fontSize, equals(18));
      expect(textWidget.style?.color, equals(Colors.purple));
    });

    testWidgets('should have proper layout constraints', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 100,
              child: LoadingWidget(message: 'Loading...'),
            ),
          ),
        ),
      );

      expect(find.byType(LoadingWidget), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should work in minimal space', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 50,
              height: 50,
              child: LoadingWidget(),
            ),
          ),
        ),
      );

      expect(find.byType(LoadingWidget), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should center content vertically and horizontally', (tester) async {
      await tester.pumpWidget(createLoadingWidget(message: 'Loading...'));

      final column = tester.widget<Column>(find.byType(Column));
      expect(column.mainAxisAlignment, equals(MainAxisAlignment.center));
    });

    testWidgets('should align text center', (tester) async {
      await tester.pumpWidget(createLoadingWidget(message: 'Loading...'));

      final textWidget = tester.widget<Text>(find.text('Loading...'));
      expect(textWidget.textAlign, equals(TextAlign.center));
    });

    testWidgets('should handle rapid rebuild without issues', (tester) async {
      await tester.pumpWidget(createLoadingWidget());
      await tester.pumpWidget(createLoadingWidget(message: 'New message'));
      await tester.pumpWidget(createLoadingWidget(message: null));
      await tester.pumpWidget(createLoadingWidget(message: 'Final message'));

      expect(find.byType(LoadingWidget), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Final message'), findsOneWidget);
    });

    testWidgets('should maintain widget tree structure', (tester) async {
      await tester.pumpWidget(createLoadingWidget(message: 'Loading...'));

      // Should have: Center -> Column -> [CircularProgressIndicator, SizedBox, Text]
      expect(find.byType(Center), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('should not show spacing when no message', (tester) async {
      await tester.pumpWidget(createLoadingWidget());

      // Should only have CircularProgressIndicator in the column
      expect(find.byType(SizedBox), findsNothing);
      expect(find.byType(Text), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should handle unicode and special characters in message', (tester) async {
      const specialMessage = 'Loading... 🔄 데이터를 로딩 중입니다 ñoño';
      
      await tester.pumpWidget(createLoadingWidget(message: specialMessage));

      expect(find.text(specialMessage), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should work with different locale settings', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('es', 'ES'),
          home: Scaffold(
            body: LoadingWidget(message: 'Cargando...'),
          ),
        ),
      );

      expect(find.text('Cargando...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
