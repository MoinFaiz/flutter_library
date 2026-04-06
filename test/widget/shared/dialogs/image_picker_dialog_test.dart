import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/book_upload/presentation/widgets/dialogs/image_picker_dialog.dart';
import 'package:flutter_library/features/book_upload/domain/entities/entities.dart';

void main() {
  group('ImagePickerDialog Widget Tests', () {
    testWidgets('should display dialog title and options', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => ImagePickerDialog(
                      onSourceSelected: (source) {
                        // Test callback - no action needed
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

      // Assert
      expect(find.text('Add Image'), findsOneWidget);
      expect(find.text('Take Photo'), findsOneWidget);
      expect(find.text('Choose from Gallery'), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
      expect(find.byIcon(Icons.photo_library), findsOneWidget);
    });

    testWidgets('should call callback when camera option is selected', (tester) async {
      // Arrange
      ImageSource? selectedSource;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => ImagePickerDialog(
                      onSourceSelected: (source) {
                        selectedSource = source;
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

      // Tap camera option
      await tester.tap(find.text('Take Photo'));
      await tester.pumpAndSettle();

      // Assert
      expect(selectedSource, equals(ImageSource.camera));
      expect(find.text('Add Image'), findsNothing); // Dialog should be closed
    });

    testWidgets('should call callback when gallery option is selected', (tester) async {
      // Arrange
      ImageSource? selectedSource;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => ImagePickerDialog(
                      onSourceSelected: (source) {
                        selectedSource = source;
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

      // Tap gallery option
      await tester.tap(find.text('Choose from Gallery'));
      await tester.pumpAndSettle();

      // Assert
      expect(selectedSource, equals(ImageSource.gallery));
      expect(find.text('Add Image'), findsNothing); // Dialog should be closed
    });

    testWidgets('should close dialog when option is selected', (tester) async {
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
                    builder: (context) => ImagePickerDialog(
                      onSourceSelected: (source) {
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
      expect(find.text('Add Image'), findsOneWidget);

      // Tap any option
      await tester.tap(find.text('Take Photo'));
      await tester.pumpAndSettle();

      // Assert
      expect(callbackCalled, isTrue);
      expect(find.text('Add Image'), findsNothing); // Dialog should be closed
    });
  });
}
