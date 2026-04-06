import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/shared/widgets/book_genre_display.dart';

void main() {
  group('BookGenreDisplay Widget Tests', () {
    Widget createTestWidget({
      required List<String> genres,
      int? maxGenres,
      bool showAsChips = false,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: BookGenreDisplay(
            genres: genres,
            maxGenres: maxGenres,
            showAsChips: showAsChips,
          ),
        ),
      );
    }

    testWidgets('should display single genre as chip when showAsChips is true', (
      WidgetTester tester,
    ) async {
      // Arrange
      const genres = ['Fiction'];

      // Act
      await tester.pumpWidget(createTestWidget(genres: genres, showAsChips: true));

      // Assert
      expect(find.text('Fiction'), findsOneWidget);
      expect(find.byType(Chip), findsOneWidget);
    });

    testWidgets('should display multiple genres as chips when showAsChips is true', (
      WidgetTester tester,
    ) async {
      // Arrange
      const genres = ['Fiction', 'Mystery', 'Thriller'];

      // Act
      await tester.pumpWidget(createTestWidget(genres: genres, showAsChips: true));

      // Assert
      expect(find.text('Fiction'), findsOneWidget);
      expect(find.text('Mystery'), findsOneWidget);
      expect(find.text('Thriller'), findsOneWidget);
      expect(find.byType(Chip), findsNWidgets(3));
    });

    testWidgets('should display genres as text when showAsChips is false', (
      WidgetTester tester,
    ) async {
      // Arrange
      const genres = ['Fiction', 'Mystery'];

      // Act
      await tester.pumpWidget(
        createTestWidget(genres: genres, showAsChips: false),
      );

      // Assert
      expect(find.byType(Chip), findsNothing);
      expect(find.text('Fiction, Mystery'), findsOneWidget);
    });

    testWidgets('should limit genres when maxGenres is specified in text mode', (
      WidgetTester tester,
    ) async {
      // Arrange
      const genres = ['Fiction', 'Mystery', 'Thriller', 'Adventure', 'Romance'];

      // Act
      await tester.pumpWidget(createTestWidget(
        genres: genres, 
        maxGenres: 3,
        showAsChips: false,
      ));

      // Assert
      expect(find.text('Fiction, Mystery, Thriller...'), findsOneWidget);
    });

    testWidgets('should limit genres when maxGenres is specified in chip mode', (
      WidgetTester tester,
    ) async {
      // Arrange
      const genres = ['Fiction', 'Mystery', 'Thriller', 'Adventure', 'Romance'];

      // Act
      await tester.pumpWidget(createTestWidget(
        genres: genres, 
        maxGenres: 3,
        showAsChips: true,
      ));

      // Assert
      expect(find.byType(Chip), findsNWidgets(3));
      expect(find.text('Fiction'), findsOneWidget);
      expect(find.text('Mystery'), findsOneWidget);
      expect(find.text('Thriller'), findsOneWidget);
      expect(find.text('Adventure'), findsNothing);
      expect(find.text('Romance'), findsNothing);
    });

    testWidgets('should show all genres when genres equal maxGenres', (
      WidgetTester tester,
    ) async {
      // Arrange
      const genres = ['Fiction', 'Mystery', 'Thriller'];

      // Act
      await tester.pumpWidget(createTestWidget(
        genres: genres, 
        maxGenres: 3,
        showAsChips: true,
      ));

      // Assert
      expect(find.byType(Chip), findsNWidgets(3));
      expect(find.text('Fiction'), findsOneWidget);
      expect(find.text('Mystery'), findsOneWidget);
      expect(find.text('Thriller'), findsOneWidget);
    });

    testWidgets('should handle empty genres list', (
      WidgetTester tester,
    ) async {
      // Arrange
      const genres = <String>[];

      // Act
      await tester.pumpWidget(createTestWidget(genres: genres));

      // Assert
      expect(find.text('No genre'), findsOneWidget);
      expect(find.byType(Chip), findsNothing);
    });

    testWidgets('should display chips with proper styling', (
      WidgetTester tester,
    ) async {
      // Arrange
      const genres = ['Fiction'];

      // Act
      await tester.pumpWidget(
        createTestWidget(genres: genres, showAsChips: true),
      );

      // Assert
      expect(find.byType(Chip), findsOneWidget);
      final chipWidget = tester.widget<Chip>(find.byType(Chip));
      expect(chipWidget.materialTapTargetSize, equals(MaterialTapTargetSize.shrinkWrap));
      expect(chipWidget.visualDensity, equals(VisualDensity.compact));
    });

    testWidgets('should handle long genre names', (
      WidgetTester tester,
    ) async {
      // Arrange
      const genres = [
        'Science Fiction and Fantasy with Very Long Name',
        'Mystery'
      ];

      // Act
      await tester.pumpWidget(createTestWidget(genres: genres, showAsChips: true));

      // Assert
      expect(find.byType(Chip), findsNWidgets(2));
      expect(
        find.text('Science Fiction and Fantasy with Very Long Name'),
        findsOneWidget,
      );
    });

    testWidgets('should handle special characters in genre names', (
      WidgetTester tester,
    ) async {
      // Arrange
      const genres = ['Sci-Fi & Fantasy', 'Non-Fiction'];

      // Act
      await tester.pumpWidget(createTestWidget(genres: genres, showAsChips: true));

      // Assert
      expect(find.text('Sci-Fi & Fantasy'), findsOneWidget);
      expect(find.text('Non-Fiction'), findsOneWidget);
      expect(find.byType(Chip), findsNWidgets(2));
    });

    testWidgets('should use ellipsis for text overflow in text mode', (
      WidgetTester tester,
    ) async {
      // Arrange
      const genres = ['Fiction', 'Mystery'];

      // Act
      await tester.pumpWidget(
        createTestWidget(genres: genres, showAsChips: false),
      );

      // Assert
      final textWidget = tester.widget<Text>(find.text('Fiction, Mystery'));
      expect(textWidget.maxLines, equals(1));
      expect(textWidget.overflow, equals(TextOverflow.ellipsis));
    });

    testWidgets('should handle maxGenres of 1', (
      WidgetTester tester,
    ) async {
      // Arrange
      const genres = ['Fiction', 'Mystery', 'Thriller'];

      // Act
      await tester.pumpWidget(createTestWidget(
        genres: genres, 
        maxGenres: 1,
        showAsChips: true,
      ));

      // Assert
      expect(find.byType(Chip), findsNWidgets(1));
      expect(find.text('Fiction'), findsOneWidget);
      expect(find.text('Mystery'), findsNothing);
      expect(find.text('Thriller'), findsNothing);
    });

    testWidgets('should handle maxGenres larger than genres list', (
      WidgetTester tester,
    ) async {
      // Arrange
      const genres = ['Fiction', 'Mystery'];

      // Act
      await tester.pumpWidget(createTestWidget(
        genres: genres, 
        maxGenres: 5,
        showAsChips: true,
      ));

      // Assert
      expect(find.byType(Chip), findsNWidgets(2));
      expect(find.text('Fiction'), findsOneWidget);
      expect(find.text('Mystery'), findsOneWidget);
    });

    testWidgets('should wrap chips properly in available space', (
      WidgetTester tester,
    ) async {
      // Arrange
      const genres = ['Fiction', 'Mystery', 'Thriller', 'Adventure'];

      // Act
      await tester.pumpWidget(
        createTestWidget(genres: genres, showAsChips: true),
      );

      // Assert
      expect(find.byType(Chip), findsNWidgets(4));
      expect(find.byType(Wrap), findsOneWidget);
    });

    testWidgets('should handle single genre in text mode', (
      WidgetTester tester,
    ) async {
      // Arrange
      const genres = ['Fiction'];

      // Act
      await tester.pumpWidget(
        createTestWidget(genres: genres, showAsChips: false),
      );

      // Assert
      expect(find.text('Fiction'), findsOneWidget);
      expect(find.byType(Chip), findsNothing);
    });
  });
}
