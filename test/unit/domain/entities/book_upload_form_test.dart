import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/book_upload/domain/entities/book_upload_form.dart';
import 'package:flutter_library/features/book_upload/domain/entities/book_copy.dart';

void main() {
  group('BookUploadForm Tests', () {
    final mockBookCopy = BookCopy(
      id: 'copy_1',
      imageUrls: ['image1.jpg'],
      condition: BookCondition.new_,
      isForSale: true,
      isForRent: false,
      isForDonate: false,
      expectedPrice: 25.0,
      notes: 'Test notes',
    );

    final mockInvalidBookCopy = BookCopy(
      id: 'copy_2',
      imageUrls: [],
      condition: BookCondition.new_,
      isForSale: false,
      isForRent: false,
      isForDonate: false,
      expectedPrice: null,
      notes: '',
    );

    final completeForm = BookUploadForm(
      id: 'book_1',
      title: 'Test Book',
      isbn: '1234567890',
      author: 'Test Author',
      description: 'Test description',
      genres: ['Fiction', 'Drama'],
      publishedYear: 2023,
      publisher: 'Test Publisher',
      language: 'English',
      pageCount: 300,
      ageAppropriateness: 18,
      copies: [mockBookCopy],
      isSearchResult: false,
      createdAt: DateTime(2023, 1, 1),
      updatedAt: DateTime(2023, 1, 2),
    );

    final minimalForm = BookUploadForm(
      title: 'Test Book',
      isbn: '1234567890',
      author: 'Test Author',
      description: '',
      genres: [],
      copies: [],
    );

    group('Factory Constructors', () {
      test('empty() should create form with empty values', () {
        final form = BookUploadForm.empty();

        expect(form.id, isNull);
        expect(form.title, equals(''));
        expect(form.isbn, equals(''));
        expect(form.author, equals(''));
        expect(form.description, equals(''));
        expect(form.genres, isEmpty);
        expect(form.publishedYear, isNull);
        expect(form.publisher, isNull);
        expect(form.language, isNull);
        expect(form.pageCount, isNull);
        expect(form.ageAppropriateness, isNull);
        expect(form.copies, isEmpty);
        expect(form.isSearchResult, false);
        expect(form.createdAt, isNull);
        expect(form.updatedAt, isNull);
      });
    });

    group('Validation Properties', () {
      test('isMinimallyValid should return true when title, isbn, and author are not empty', () {
        expect(minimalForm.isMinimallyValid, true);
      });

      test('isMinimallyValid should return false when title is empty', () {
        final form = minimalForm.copyWith(title: '');
        expect(form.isMinimallyValid, false);
      });

      test('isMinimallyValid should return false when title is only whitespace', () {
        final form = minimalForm.copyWith(title: '   ');
        expect(form.isMinimallyValid, false);
      });

      test('isMinimallyValid should return false when isbn is empty', () {
        final form = minimalForm.copyWith(isbn: '');
        expect(form.isMinimallyValid, false);
      });

      test('isMinimallyValid should return false when isbn is only whitespace', () {
        final form = minimalForm.copyWith(isbn: '   ');
        expect(form.isMinimallyValid, false);
      });

      test('isMinimallyValid should return false when author is empty', () {
        final form = minimalForm.copyWith(author: '');
        expect(form.isMinimallyValid, false);
      });

      test('isMinimallyValid should return false when author is only whitespace', () {
        final form = minimalForm.copyWith(author: '   ');
        expect(form.isMinimallyValid, false);
      });

      test('isValid should return true when all required fields are present', () {
        expect(completeForm.isValid, true);
      });

      test('isValid should return false when not minimally valid', () {
        final form = completeForm.copyWith(title: '');
        expect(form.isValid, false);
      });

      test('isValid should return false when description is empty', () {
        final form = completeForm.copyWith(description: '');
        expect(form.isValid, false);
      });

      test('isValid should return false when description is only whitespace', () {
        final form = completeForm.copyWith(description: '   ');
        expect(form.isValid, false);
      });

      test('isValid should return false when genres is empty', () {
        final form = completeForm.copyWith(genres: []);
        expect(form.isValid, false);
      });

      test('isValid should return false when publishedYear is null', () {
        final form = BookUploadForm(
          title: 'Test Book',
          isbn: '1234567890',
          author: 'Test Author',
          description: 'Test description',
          genres: ['Fiction'],
          copies: [mockBookCopy],
          publishedYear: null, // explicitly null
        );
        expect(form.isValid, false);
      });

      test('isValid should return false when copies is empty', () {
        final form = completeForm.copyWith(copies: []);
        expect(form.isValid, false);
      });

      test('isValid should return false when copies contain invalid copy', () {
        final form = completeForm.copyWith(copies: [mockInvalidBookCopy]);
        expect(form.isValid, false);
      });
    });

    group('Data Properties', () {
      test('hasData should return true when title is not empty', () {
        final form = BookUploadForm.empty().copyWith(title: 'Test');
        expect(form.hasData, true);
      });

      test('hasData should return true when isbn is not empty', () {
        final form = BookUploadForm.empty().copyWith(isbn: '123');
        expect(form.hasData, true);
      });

      test('hasData should return true when author is not empty', () {
        final form = BookUploadForm.empty().copyWith(author: 'Author');
        expect(form.hasData, true);
      });

      test('hasData should return true when description is not empty', () {
        final form = BookUploadForm.empty().copyWith(description: 'Desc');
        expect(form.hasData, true);
      });

      test('hasData should return true when genres is not empty', () {
        final form = BookUploadForm.empty().copyWith(genres: ['Fiction']);
        expect(form.hasData, true);
      });

      test('hasData should return true when publishedYear is not null', () {
        final form = BookUploadForm.empty().copyWith(publishedYear: 2023);
        expect(form.hasData, true);
      });

      test('hasData should return true when publisher is not null', () {
        final form = BookUploadForm.empty().copyWith(publisher: 'Publisher');
        expect(form.hasData, true);
      });

      test('hasData should return true when language is not null', () {
        final form = BookUploadForm.empty().copyWith(language: 'English');
        expect(form.hasData, true);
      });

      test('hasData should return true when pageCount is not null', () {
        final form = BookUploadForm.empty().copyWith(pageCount: 300);
        expect(form.hasData, true);
      });

      test('hasData should return true when ageAppropriateness is not null', () {
        final form = BookUploadForm.empty().copyWith(ageAppropriateness: 18);
        expect(form.hasData, true);
      });

      test('hasData should return true when copies is not empty', () {
        final form = BookUploadForm.empty().copyWith(copies: [mockBookCopy]);
        expect(form.hasData, true);
      });

      test('hasData should return false when all fields are empty', () {
        final form = BookUploadForm.empty();
        expect(form.hasData, false);
      });

      test('isLocked should return true when isSearchResult is true', () {
        final form = completeForm.copyWith(isSearchResult: true);
        expect(form.isLocked, true);
      });

      test('isLocked should return false when isSearchResult is false', () {
        final form = completeForm.copyWith(isSearchResult: false);
        expect(form.isLocked, false);
      });
    });

    group('Copy Count Properties', () {
      test('validCopiesCount should return count of valid copies', () {
        final form = completeForm.copyWith(
          copies: [mockBookCopy, mockInvalidBookCopy],
        );
        expect(form.validCopiesCount, 1);
      });

      test('validCopiesCount should return 0 when no valid copies', () {
        final form = completeForm.copyWith(copies: [mockInvalidBookCopy]);
        expect(form.validCopiesCount, 0);
      });

      test('totalCopiesCount should return total number of copies', () {
        final form = completeForm.copyWith(
          copies: [mockBookCopy, mockInvalidBookCopy],
        );
        expect(form.totalCopiesCount, 2);
      });

      test('totalCopiesCount should return 0 when no copies', () {
        final form = completeForm.copyWith(copies: []);
        expect(form.totalCopiesCount, 0);
      });

      test('hasIncompleteCopies should return true when there are invalid copies', () {
        final form = completeForm.copyWith(
          copies: [mockBookCopy, mockInvalidBookCopy],
        );
        expect(form.hasIncompleteCopies, true);
      });

      test('hasIncompleteCopies should return false when all copies are valid', () {
        final form = completeForm.copyWith(copies: [mockBookCopy]);
        expect(form.hasIncompleteCopies, false);
      });

      test('hasIncompleteCopies should return false when no copies', () {
        final form = completeForm.copyWith(copies: []);
        expect(form.hasIncompleteCopies, false);
      });
    });

    group('copyWith', () {
      test('should create new instance with updated id', () {
        final updated = completeForm.copyWith(id: 'new_id');
        expect(updated.id, equals('new_id'));
        expect(updated.title, equals(completeForm.title));
      });

      test('should create new instance with updated title', () {
        final updated = completeForm.copyWith(title: 'New Title');
        expect(updated.title, equals('New Title'));
        expect(updated.id, equals(completeForm.id));
      });

      test('should create new instance with updated isbn', () {
        final updated = completeForm.copyWith(isbn: '9876543210');
        expect(updated.isbn, equals('9876543210'));
        expect(updated.title, equals(completeForm.title));
      });

      test('should create new instance with updated author', () {
        final updated = completeForm.copyWith(author: 'New Author');
        expect(updated.author, equals('New Author'));
        expect(updated.title, equals(completeForm.title));
      });

      test('should create new instance with updated description', () {
        final updated = completeForm.copyWith(description: 'New Description');
        expect(updated.description, equals('New Description'));
        expect(updated.title, equals(completeForm.title));
      });

      test('should create new instance with updated genres', () {
        final newGenres = ['Mystery', 'Thriller'];
        final updated = completeForm.copyWith(genres: newGenres);
        expect(updated.genres, equals(newGenres));
        expect(updated.title, equals(completeForm.title));
      });

      test('should create new instance with updated publishedYear', () {
        final updated = completeForm.copyWith(publishedYear: 2024);
        expect(updated.publishedYear, equals(2024));
        expect(updated.title, equals(completeForm.title));
      });

      test('should create new instance with updated publisher', () {
        final updated = completeForm.copyWith(publisher: 'New Publisher');
        expect(updated.publisher, equals('New Publisher'));
        expect(updated.title, equals(completeForm.title));
      });

      test('should create new instance with updated language', () {
        final updated = completeForm.copyWith(language: 'Spanish');
        expect(updated.language, equals('Spanish'));
        expect(updated.title, equals(completeForm.title));
      });

      test('should create new instance with updated pageCount', () {
        final updated = completeForm.copyWith(pageCount: 400);
        expect(updated.pageCount, equals(400));
        expect(updated.title, equals(completeForm.title));
      });

      test('should create new instance with updated ageAppropriateness', () {
        final updated = completeForm.copyWith(ageAppropriateness: 16);
        expect(updated.ageAppropriateness, equals(16));
        expect(updated.title, equals(completeForm.title));
      });

      test('should create new instance with updated copies', () {
        final newCopies = [mockInvalidBookCopy];
        final updated = completeForm.copyWith(copies: newCopies);
        expect(updated.copies, equals(newCopies));
        expect(updated.title, equals(completeForm.title));
      });

      test('should create new instance with updated isSearchResult', () {
        final updated = completeForm.copyWith(isSearchResult: true);
        expect(updated.isSearchResult, true);
        expect(updated.title, equals(completeForm.title));
      });

      test('should create new instance with updated createdAt', () {
        final newDate = DateTime(2024, 1, 1);
        final updated = completeForm.copyWith(createdAt: newDate);
        expect(updated.createdAt, equals(newDate));
        expect(updated.title, equals(completeForm.title));
      });

      test('should create new instance with updated updatedAt', () {
        final newDate = DateTime(2024, 1, 2);
        final updated = completeForm.copyWith(updatedAt: newDate);
        expect(updated.updatedAt, equals(newDate));
        expect(updated.title, equals(completeForm.title));
      });

      test('should preserve original values when no parameters provided', () {
        final updated = completeForm.copyWith();
        expect(updated.id, equals(completeForm.id));
        expect(updated.title, equals(completeForm.title));
        expect(updated.isbn, equals(completeForm.isbn));
        expect(updated.author, equals(completeForm.author));
        expect(updated.description, equals(completeForm.description));
        expect(updated.genres, equals(completeForm.genres));
        expect(updated.publishedYear, equals(completeForm.publishedYear));
        expect(updated.publisher, equals(completeForm.publisher));
        expect(updated.language, equals(completeForm.language));
        expect(updated.pageCount, equals(completeForm.pageCount));
        expect(updated.ageAppropriateness, equals(completeForm.ageAppropriateness));
        expect(updated.copies, equals(completeForm.copies));
        expect(updated.isSearchResult, equals(completeForm.isSearchResult));
        expect(updated.createdAt, equals(completeForm.createdAt));
        expect(updated.updatedAt, equals(completeForm.updatedAt));
      });
    });

    group('Equality and Props', () {
      test('should support value equality', () {
        final form1 = BookUploadForm(
          id: 'book_1',
          title: 'Test Book',
          isbn: '1234567890',
          author: 'Test Author',
          description: 'Test description',
          genres: ['Fiction'],
          copies: [mockBookCopy],
        );

        final form2 = BookUploadForm(
          id: 'book_1',
          title: 'Test Book',
          isbn: '1234567890',
          author: 'Test Author',
          description: 'Test description',
          genres: ['Fiction'],
          copies: [mockBookCopy],
        );

        expect(form1, equals(form2));
      });

      test('should not be equal when properties differ', () {
        final form1 = completeForm;
        final form2 = completeForm.copyWith(title: 'Different Title');

        expect(form1, isNot(equals(form2)));
      });

      test('should have correct props', () {
        expect(completeForm.props, equals([
          completeForm.id,
          completeForm.title,
          completeForm.isbn,
          completeForm.author,
          completeForm.description,
          completeForm.genres,
          completeForm.publishedYear,
          completeForm.publisher,
          completeForm.language,
          completeForm.pageCount,
          completeForm.ageAppropriateness,
          completeForm.copies,
          completeForm.isSearchResult,
          completeForm.createdAt,
          completeForm.updatedAt,
        ]));
      });

      test('should handle null values in props', () {
        final form = BookUploadForm.empty();
        expect(form.props, contains(null));
      });
    });

    group('Edge Cases', () {
      test('should handle form with all null optional fields', () {
        final form = BookUploadForm(
          title: 'Test',
          isbn: '123',
          author: 'Author',
          description: 'Desc',
          genres: ['Fiction'],
          copies: [mockBookCopy],
        );

        expect(form.id, isNull);
        expect(form.publishedYear, isNull);
        expect(form.publisher, isNull);
        expect(form.language, isNull);
        expect(form.pageCount, isNull);
        expect(form.ageAppropriateness, isNull);
        expect(form.createdAt, isNull);
        expect(form.updatedAt, isNull);
        expect(form.isSearchResult, false);
      });

      test('should handle very long text fields', () {
        final longString = 'a' * 1000;
        final form = completeForm.copyWith(
          title: longString,
          description: longString,
        );

        expect(form.title, equals(longString));
        expect(form.description, equals(longString));
        expect(form.isMinimallyValid, true);
      });

      test('should handle empty and whitespace combinations', () {
        final form = BookUploadForm(
          title: '  Valid Title  ',
          isbn: '  123456  ',
          author: '  Valid Author  ',
          description: '   ',  // Only whitespace
          genres: [],
          copies: [],
        );

        expect(form.isMinimallyValid, true);
        expect(form.isValid, false); // description is only whitespace
      });
    });
  });
}
