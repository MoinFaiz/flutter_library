import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';

void main() {
  group('BookMetadata Tests', () {
    const testBookMetadata = BookMetadata(
      isbn: '978-0-123456-78-9',
      publisher: 'Test Publisher',
      ageAppropriateness: AgeAppropriateness.adult,
      genres: ['Fiction', 'Mystery', 'Thriller'],
      pageCount: 350,
      language: 'English',
      edition: '1st Edition',
    );

    group('Constructor and Basic Properties', () {
      test('should create BookMetadata with all properties', () {
        // Assert
        expect(testBookMetadata.isbn, equals('978-0-123456-78-9'));
        expect(testBookMetadata.publisher, equals('Test Publisher'));
        expect(testBookMetadata.ageAppropriateness, equals(AgeAppropriateness.adult));
        expect(testBookMetadata.genres, equals(['Fiction', 'Mystery', 'Thriller']));
        expect(testBookMetadata.pageCount, equals(350));
        expect(testBookMetadata.language, equals('English'));
        expect(testBookMetadata.edition, equals('1st Edition'));
      });

      test('should create BookMetadata with null optional properties', () {
        // Arrange
        const metadata = BookMetadata(
          ageAppropriateness: AgeAppropriateness.children,
          genres: ['Children'],
          pageCount: 100,
          language: 'Spanish',
        );

        // Assert
        expect(metadata.isbn, isNull);
        expect(metadata.publisher, isNull);
        expect(metadata.edition, isNull);
        expect(metadata.ageAppropriateness, equals(AgeAppropriateness.children));
        expect(metadata.genres, equals(['Children']));
        expect(metadata.pageCount, equals(100));
        expect(metadata.language, equals('Spanish'));
      });

      test('should handle empty genres list', () {
        // Arrange
        const metadata = BookMetadata(
          ageAppropriateness: AgeAppropriateness.allAges,
          genres: [],
          pageCount: 200,
          language: 'French',
        );

        // Assert
        expect(metadata.genres, isEmpty);
      });

      test('should handle all age appropriateness values', () {
        for (final ageType in AgeAppropriateness.values) {
          // Arrange
          final metadata = BookMetadata(
            ageAppropriateness: ageType,
            genres: ['Test'],
            pageCount: 150,
            language: 'English',
          );

          // Assert
          expect(metadata.ageAppropriateness, equals(ageType));
        }
      });
    });

    group('Primary Genre', () {
      test('should return first genre as primary genre', () {
        // Assert
        expect(testBookMetadata.primaryGenre, equals('Fiction'));
      });

      test('should return "Unknown" for empty genres list', () {
        // Arrange
        const metadata = BookMetadata(
          ageAppropriateness: AgeAppropriateness.adult,
          genres: [],
          pageCount: 200,
          language: 'English',
        );

        // Assert
        expect(metadata.primaryGenre, equals('Unknown'));
      });

      test('should return single genre when only one genre exists', () {
        // Arrange
        const metadata = BookMetadata(
          ageAppropriateness: AgeAppropriateness.youngAdult,
          genres: ['Romance'],
          pageCount: 280,
          language: 'English',
        );

        // Assert
        expect(metadata.primaryGenre, equals('Romance'));
      });
    });

    group('Has Multiple Genres', () {
      test('should return true when multiple genres exist', () {
        // Assert
        expect(testBookMetadata.hasMultipleGenres, isTrue);
      });

      test('should return false when single genre exists', () {
        // Arrange
        const metadata = BookMetadata(
          ageAppropriateness: AgeAppropriateness.adult,
          genres: ['Science Fiction'],
          pageCount: 400,
          language: 'English',
        );

        // Assert
        expect(metadata.hasMultipleGenres, isFalse);
      });

      test('should return false when no genres exist', () {
        // Arrange
        const metadata = BookMetadata(
          ageAppropriateness: AgeAppropriateness.adult,
          genres: [],
          pageCount: 300,
          language: 'English',
        );

        // Assert
        expect(metadata.hasMultipleGenres, isFalse);
      });
    });

    group('Genre Display', () {
      test('should join multiple genres with comma and space', () {
        // Assert
        expect(testBookMetadata.genreDisplay, equals('Fiction, Mystery, Thriller'));
      });

      test('should return single genre without comma', () {
        // Arrange
        const metadata = BookMetadata(
          ageAppropriateness: AgeAppropriateness.children,
          genres: ['Educational'],
          pageCount: 50,
          language: 'English',
        );

        // Assert
        expect(metadata.genreDisplay, equals('Educational'));
      });

      test('should return empty string for empty genres list', () {
        // Arrange
        const metadata = BookMetadata(
          ageAppropriateness: AgeAppropriateness.adult,
          genres: [],
          pageCount: 200,
          language: 'English',
        );

        // Assert
        expect(metadata.genreDisplay, equals(''));
      });

      test('should handle genres with special characters', () {
        // Arrange
        const metadata = BookMetadata(
          ageAppropriateness: AgeAppropriateness.adult,
          genres: ['Sci-Fi', 'Non-Fiction', 'Self-Help'],
          pageCount: 250,
          language: 'English',
        );

        // Assert
        expect(metadata.genreDisplay, equals('Sci-Fi, Non-Fiction, Self-Help'));
      });
    });

    group('copyWith', () {
      test('should return BookMetadata with updated values', () {
        // Act
        final result = testBookMetadata.copyWith(
          isbn: '978-0-987654-32-1',
          publisher: 'Updated Publisher',
          ageAppropriateness: AgeAppropriateness.youngAdult,
          genres: ['Updated Genre'],
          pageCount: 500,
          language: 'German',
          edition: '2nd Edition',
        );

        // Assert
        expect(result.isbn, equals('978-0-987654-32-1'));
        expect(result.publisher, equals('Updated Publisher'));
        expect(result.ageAppropriateness, equals(AgeAppropriateness.youngAdult));
        expect(result.genres, equals(['Updated Genre']));
        expect(result.pageCount, equals(500));
        expect(result.language, equals('German'));
        expect(result.edition, equals('2nd Edition'));
      });

      test('should return BookMetadata with original values when no parameters provided', () {
        // Act
        final result = testBookMetadata.copyWith();

        // Assert
        expect(result.isbn, equals(testBookMetadata.isbn));
        expect(result.publisher, equals(testBookMetadata.publisher));
        expect(result.ageAppropriateness, equals(testBookMetadata.ageAppropriateness));
        expect(result.genres, equals(testBookMetadata.genres));
        expect(result.pageCount, equals(testBookMetadata.pageCount));
        expect(result.language, equals(testBookMetadata.language));
        expect(result.edition, equals(testBookMetadata.edition));
      });

      test('should update only specified values', () {
        // Act
        final result = testBookMetadata.copyWith(
          pageCount: 600,
          language: 'French',
        );

        // Assert
        expect(result.isbn, equals(testBookMetadata.isbn)); // Unchanged
        expect(result.publisher, equals(testBookMetadata.publisher)); // Unchanged
        expect(result.ageAppropriateness, equals(testBookMetadata.ageAppropriateness)); // Unchanged
        expect(result.genres, equals(testBookMetadata.genres)); // Unchanged
        expect(result.pageCount, equals(600)); // Changed
        expect(result.language, equals('French')); // Changed
        expect(result.edition, equals(testBookMetadata.edition)); // Unchanged
      });

      test('should preserve current values when null is passed to copyWith', () {
        // Act
        final result = testBookMetadata.copyWith(
          isbn: null,
          publisher: null,
          edition: null,
        );

        // Assert - copyWith preserves original values when null is passed
        expect(result.isbn, equals(testBookMetadata.isbn)); // Preserved
        expect(result.publisher, equals(testBookMetadata.publisher)); // Preserved
        expect(result.edition, equals(testBookMetadata.edition)); // Preserved
        expect(result.ageAppropriateness, equals(testBookMetadata.ageAppropriateness)); // Unchanged
        expect(result.pageCount, equals(testBookMetadata.pageCount)); // Unchanged
      });
    });

    group('Equality and Props', () {
      test('should be equal when all properties are the same', () {
        // Arrange
        const metadata1 = BookMetadata(
          isbn: '978-0-123456-78-9',
          publisher: 'Test Publisher',
          ageAppropriateness: AgeAppropriateness.adult,
          genres: ['Fiction', 'Mystery'],
          pageCount: 300,
          language: 'English',
          edition: '1st Edition',
        );

        const metadata2 = BookMetadata(
          isbn: '978-0-123456-78-9',
          publisher: 'Test Publisher',
          ageAppropriateness: AgeAppropriateness.adult,
          genres: ['Fiction', 'Mystery'],
          pageCount: 300,
          language: 'English',
          edition: '1st Edition',
        );

        // Assert
        expect(metadata1, equals(metadata2));
        expect(metadata1.hashCode, equals(metadata2.hashCode));
      });

      test('should not be equal when properties differ', () {
        // Arrange
        const metadata1 = BookMetadata(
          isbn: '978-0-123456-78-9',
          publisher: 'Test Publisher',
          ageAppropriateness: AgeAppropriateness.adult,
          genres: ['Fiction'],
          pageCount: 300,
          language: 'English',
        );

        const metadata2 = BookMetadata(
          isbn: '978-0-123456-78-9',
          publisher: 'Test Publisher',
          ageAppropriateness: AgeAppropriateness.youngAdult, // Different
          genres: ['Fiction'],
          pageCount: 300,
          language: 'English',
        );

        // Assert
        expect(metadata1, isNot(equals(metadata2)));
      });

      test('should not be equal when genres order differs', () {
        // Arrange
        const metadata1 = BookMetadata(
          ageAppropriateness: AgeAppropriateness.adult,
          genres: ['Fiction', 'Mystery'],
          pageCount: 300,
          language: 'English',
        );

        const metadata2 = BookMetadata(
          ageAppropriateness: AgeAppropriateness.adult,
          genres: ['Mystery', 'Fiction'], // Different order
          pageCount: 300,
          language: 'English',
        );

        // Assert
        expect(metadata1, isNot(equals(metadata2)));
      });

      test('should not be equal when null vs non-null values', () {
        // Arrange
        const metadata1 = BookMetadata(
          isbn: '978-0-123456-78-9',
          ageAppropriateness: AgeAppropriateness.adult,
          genres: ['Fiction'],
          pageCount: 300,
          language: 'English',
        );

        const metadata2 = BookMetadata(
          isbn: null, // Different
          ageAppropriateness: AgeAppropriateness.adult,
          genres: ['Fiction'],
          pageCount: 300,
          language: 'English',
        );

        // Assert
        expect(metadata1, isNot(equals(metadata2)));
      });
    });

    group('Edge Cases', () {
      test('should handle very long ISBN', () {
        // Arrange
        const metadata = BookMetadata(
          isbn: '978-0-123456789012345678901234567890-78-9',
          ageAppropriateness: AgeAppropriateness.adult,
          genres: ['Fiction'],
          pageCount: 300,
          language: 'English',
        );

        // Assert
        expect(metadata.isbn, equals('978-0-123456789012345678901234567890-78-9'));
      });

      test('should handle special characters in publisher name', () {
        // Arrange
        const metadata = BookMetadata(
          publisher: 'Publïshér & Cômpañy, Inc.™',
          ageAppropriateness: AgeAppropriateness.adult,
          genres: ['Fiction'],
          pageCount: 300,
          language: 'English',
        );

        // Assert
        expect(metadata.publisher, equals('Publïshér & Cômpañy, Inc.™'));
      });

      test('should handle zero page count', () {
        // Arrange
        const metadata = BookMetadata(
          ageAppropriateness: AgeAppropriateness.children,
          genres: ['Picture Book'],
          pageCount: 0,
          language: 'English',
        );

        // Assert
        expect(metadata.pageCount, equals(0));
      });

      test('should handle very large page count', () {
        // Arrange
        const metadata = BookMetadata(
          ageAppropriateness: AgeAppropriateness.adult,
          genres: ['Reference'],
          pageCount: 999999,
          language: 'English',
        );

        // Assert
        expect(metadata.pageCount, equals(999999));
      });

      test('should handle unicode characters in language', () {
        // Arrange
        const metadata = BookMetadata(
          ageAppropriateness: AgeAppropriateness.adult,
          genres: ['Fiction'],
          pageCount: 300,
          language: '中文', // Chinese
        );

        // Assert
        expect(metadata.language, equals('中文'));
      });

      test('should handle very long genre names', () {
        // Arrange
        const metadata = BookMetadata(
          ageAppropriateness: AgeAppropriateness.adult,
          genres: ['Very Long Genre Name That Exceeds Normal Length Expectations'],
          pageCount: 300,
          language: 'English',
        );

        // Assert
        expect(metadata.genres.first, equals('Very Long Genre Name That Exceeds Normal Length Expectations'));
        expect(metadata.primaryGenre, equals('Very Long Genre Name That Exceeds Normal Length Expectations'));
      });

      test('should handle many genres', () {
        // Arrange
        const metadata = BookMetadata(
          ageAppropriateness: AgeAppropriateness.adult,
          genres: [
            'Fiction', 'Mystery', 'Thriller', 'Crime', 'Detective',
            'Suspense', 'Action', 'Adventure', 'Drama', 'Contemporary'
          ],
          pageCount: 400,
          language: 'English',
        );

        // Assert
        expect(metadata.genres.length, equals(10));
        expect(metadata.hasMultipleGenres, isTrue);
        expect(metadata.primaryGenre, equals('Fiction'));
        expect(metadata.genreDisplay, contains('Fiction, Mystery, Thriller'));
      });
    });
  });
}
