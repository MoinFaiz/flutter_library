import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/book_upload/presentation/bloc/book_upload_event.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/book_upload/domain/entities/book_copy.dart';
import 'package:flutter_library/features/book_upload/domain/entities/book_upload_form.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';

void main() {
  group('BookUploadEvent Tests', () {
    final mockBook = Book(
      id: 'book_1',
      title: 'Test Book',
      author: 'Test Author',
      imageUrls: ['https://example.com/book1.jpg'],
      rating: 4.5,
      metadata: BookMetadata(
        isbn: '1234567890',
        publisher: 'Test Publisher',
        ageAppropriateness: AgeAppropriateness.adult,
        genres: ['Fiction', 'Drama'],
        pageCount: 300,
        language: 'English',
        edition: 'First Edition',
      ),
      pricing: BookPricing(
        salePrice: 25.0,
        rentPrice: 5.0,
      ),
      availability: BookAvailability(
        availableForSaleCount: 1,
        availableForRentCount: 1,
        totalCopies: 2,
      ),
      isFromFriend: false,
      isFavorite: false,
      description: 'Test description',
      publishedYear: 2023,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

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

    final mockForm = BookUploadForm(
      title: 'Test Title',
      author: 'Test Author',
      isbn: '1234567890',
      description: 'Test description',
      genres: ['Fiction'],
      copies: [mockBookCopy],
    );

    group('InitializeForm', () {
      test('should support value equality', () {
        const event1 = InitializeForm();
        const event2 = InitializeForm();

        expect(event1, equals(event2));
      });

      test('should support value equality with initialForm', () {
        final event1 = InitializeForm(initialForm: mockForm);
        final event2 = InitializeForm(initialForm: mockForm);

        expect(event1, equals(event2));
      });

      test('should have correct props', () {
        final event = InitializeForm(initialForm: mockForm);

        expect(event.props, equals([mockForm]));
      });

      test('should handle null initialForm', () {
        const event = InitializeForm();

        expect(event.props, equals([null]));
        expect(event.initialForm, isNull);
      });
    });

    group('UpdateStringField', () {
      test('should support value equality', () {
        const event1 = UpdateStringField(field: 'title', value: 'Test');
        const event2 = UpdateStringField(field: 'title', value: 'Test');

        expect(event1, equals(event2));
      });

      test('should not be equal with different values', () {
        const event1 = UpdateStringField(field: 'title', value: 'Test1');
        const event2 = UpdateStringField(field: 'title', value: 'Test2');

        expect(event1, isNot(equals(event2)));
      });

      test('should have correct props', () {
        const event = UpdateStringField(field: 'title', value: 'Test');

        expect(event.props, equals(['title', 'Test']));
      });
    });

    group('UpdateNullableStringField', () {
      test('should support value equality', () {
        const event1 = UpdateNullableStringField(field: 'description', value: 'Test');
        const event2 = UpdateNullableStringField(field: 'description', value: 'Test');

        expect(event1, equals(event2));
      });

      test('should support null values', () {
        const event1 = UpdateNullableStringField(field: 'description', value: null);
        const event2 = UpdateNullableStringField(field: 'description', value: null);

        expect(event1, equals(event2));
      });

      test('should have correct props', () {
        const event = UpdateNullableStringField(field: 'description', value: 'Test');

        expect(event.props, equals(['description', 'Test']));
      });

      test('should handle null value in props', () {
        const event = UpdateNullableStringField(field: 'description', value: null);

        expect(event.props, equals(['description', null]));
      });
    });

    group('UpdateIntField', () {
      test('should support value equality', () {
        const event1 = UpdateIntField(field: 'pages', value: 300);
        const event2 = UpdateIntField(field: 'pages', value: 300);

        expect(event1, equals(event2));
      });

      test('should support null values', () {
        const event1 = UpdateIntField(field: 'pages', value: null);
        const event2 = UpdateIntField(field: 'pages', value: null);

        expect(event1, equals(event2));
      });

      test('should have correct props', () {
        const event = UpdateIntField(field: 'pages', value: 300);

        expect(event.props, equals(['pages', 300]));
      });
    });

    group('UpdateStringListField', () {
      test('should support value equality', () {
        const event1 = UpdateStringListField(field: 'genres', value: ['Fiction', 'Drama']);
        const event2 = UpdateStringListField(field: 'genres', value: ['Fiction', 'Drama']);

        expect(event1, equals(event2));
      });

      test('should have correct props', () {
        const event = UpdateStringListField(field: 'genres', value: ['Fiction', 'Drama']);

        expect(event.props, equals(['genres', ['Fiction', 'Drama']]));
      });

      test('should handle empty list', () {
        const event = UpdateStringListField(field: 'genres', value: []);

        expect(event.props, equals(['genres', <String>[]]));
      });
    });

    group('SearchBooks', () {
      test('should support value equality', () {
        const event1 = SearchBooks('test query');
        const event2 = SearchBooks('test query');

        expect(event1, equals(event2));
      });

      test('should have correct props', () {
        const event = SearchBooks('test query');

        expect(event.props, equals(['test query']));
      });

      test('should handle empty query', () {
        const event = SearchBooks('');

        expect(event.props, equals(['']));
      });
    });

    group('ClearSearchResults', () {
      test('should support value equality', () {
        const event1 = ClearSearchResults();
        const event2 = ClearSearchResults();

        expect(event1, equals(event2));
      });

      test('should have empty props', () {
        const event = ClearSearchResults();

        expect(event.props, equals([]));
      });
    });

    group('SelectBookFromSearch', () {
      test('should support value equality', () {
        final event1 = SelectBookFromSearch(mockBook);
        final event2 = SelectBookFromSearch(mockBook);

        expect(event1, equals(event2));
      });

      test('should have correct props', () {
        final event = SelectBookFromSearch(mockBook);

        expect(event.props, equals([mockBook]));
      });
    });

    group('GetBookByIsbn', () {
      test('should support value equality', () {
        const event1 = GetBookByIsbn('1234567890');
        const event2 = GetBookByIsbn('1234567890');

        expect(event1, equals(event2));
      });

      test('should have correct props', () {
        const event = GetBookByIsbn('1234567890');

        expect(event.props, equals(['1234567890']));
      });
    });

    group('AddNewCopy', () {
      test('should support value equality', () {
        const event1 = AddNewCopy();
        const event2 = AddNewCopy();

        expect(event1, equals(event2));
      });

      test('should have empty props', () {
        const event = AddNewCopy();

        expect(event.props, equals([]));
      });
    });

    group('UpdateCopy', () {
      test('should support value equality', () {
        final event1 = UpdateCopy(copyIndex: 0, copy: mockBookCopy);
        final event2 = UpdateCopy(copyIndex: 0, copy: mockBookCopy);

        expect(event1, equals(event2));
      });

      test('should have correct props', () {
        final event = UpdateCopy(copyIndex: 0, copy: mockBookCopy);

        expect(event.props, equals([0, mockBookCopy]));
      });

      test('should not be equal with different index', () {
        final event1 = UpdateCopy(copyIndex: 0, copy: mockBookCopy);
        final event2 = UpdateCopy(copyIndex: 1, copy: mockBookCopy);

        expect(event1, isNot(equals(event2)));
      });
    });

    group('RemoveCopy', () {
      test('should support value equality', () {
        const event1 = RemoveCopy(0);
        const event2 = RemoveCopy(0);

        expect(event1, equals(event2));
      });

      test('should have correct props', () {
        const event = RemoveCopy(0);

        expect(event.props, equals([0]));
      });

      test('should not be equal with different index', () {
        const event1 = RemoveCopy(0);
        const event2 = RemoveCopy(1);

        expect(event1, isNot(equals(event2)));
      });
    });

    group('UploadImage', () {
      test('should support value equality', () {
        const event1 = UploadImage('/path/to/image.jpg');
        const event2 = UploadImage('/path/to/image.jpg');

        expect(event1, equals(event2));
      });

      test('should have correct props', () {
        const event = UploadImage('/path/to/image.jpg');

        expect(event.props, equals(['/path/to/image.jpg']));
      });
    });

    group('UploadImageForCopy', () {
      test('should support value equality', () {
        const event1 = UploadImageForCopy(copyIndex: 0, imageUrl: 'https://example.com/image.jpg');
        const event2 = UploadImageForCopy(copyIndex: 0, imageUrl: 'https://example.com/image.jpg');

        expect(event1, equals(event2));
      });

      test('should have correct props', () {
        const event = UploadImageForCopy(copyIndex: 0, imageUrl: 'https://example.com/image.jpg');

        expect(event.props, equals([0, 'https://example.com/image.jpg']));
      });
    });

    group('RemoveImageFromCopy', () {
      test('should support value equality', () {
        const event1 = RemoveImageFromCopy(copyIndex: 0, imageIndex: 1);
        const event2 = RemoveImageFromCopy(copyIndex: 0, imageIndex: 1);

        expect(event1, equals(event2));
      });

      test('should have correct props', () {
        const event = RemoveImageFromCopy(copyIndex: 0, imageIndex: 1);

        expect(event.props, equals([0, 1]));
      });
    });

    group('LoadGenres', () {
      test('should support value equality', () {
        const event1 = LoadGenres();
        const event2 = LoadGenres();

        expect(event1, equals(event2));
      });

      test('should have empty props', () {
        const event = LoadGenres();

        expect(event.props, equals([]));
      });
    });

    group('LoadLanguages', () {
      test('should support value equality', () {
        const event1 = LoadLanguages();
        const event2 = LoadLanguages();

        expect(event1, equals(event2));
      });

      test('should have empty props', () {
        const event = LoadLanguages();

        expect(event.props, equals([]));
      });
    });

    group('SubmitForm', () {
      test('should support value equality', () {
        const event1 = SubmitForm();
        const event2 = SubmitForm();

        expect(event1, equals(event2));
      });

      test('should have empty props', () {
        const event = SubmitForm();

        expect(event.props, equals([]));
      });
    });

    group('ResetForm', () {
      test('should support value equality', () {
        const event1 = ResetForm();
        const event2 = ResetForm();

        expect(event1, equals(event2));
      });

      test('should have empty props', () {
        const event = ResetForm();

        expect(event.props, equals([]));
      });
    });

    group('Event Inheritance', () {
      test('all events should extend BookUploadEvent', () {
        const events = [
          InitializeForm(),
          UpdateStringField(field: 'test', value: 'test'),
          UpdateNullableStringField(field: 'test', value: 'test'),
          UpdateIntField(field: 'test', value: 1),
          UpdateStringListField(field: 'test', value: ['test']),
          SearchBooks('test'),
          ClearSearchResults(),
          GetBookByIsbn('test'),
          AddNewCopy(),
          RemoveCopy(0),
          UploadImage('test'),
          UploadImageForCopy(copyIndex: 0, imageUrl: 'test'),
          RemoveImageFromCopy(copyIndex: 0, imageIndex: 0),
          LoadGenres(),
          LoadLanguages(),
          SubmitForm(),
          ResetForm(),
        ];

        for (final event in events) {
          expect(event, isA<BookUploadEvent>());
        }
      });

      test('should create events with different Book objects', () {
        // Create two different events with the same book
        final event1 = SelectBookFromSearch(mockBook);
        final event2 = SelectBookFromSearch(mockBook);

        expect(event1, equals(event2));
        expect(event1.book, equals(mockBook));
        expect(event2.book, equals(mockBook));
      });
    });
  });
}
