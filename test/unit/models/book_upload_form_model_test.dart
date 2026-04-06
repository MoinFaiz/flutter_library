import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/book_upload/data/models/book_upload_form_model.dart';
import 'package:flutter_library/features/book_upload/domain/entities/book_upload_form.dart';
import 'package:flutter_library/features/book_upload/domain/entities/book_copy.dart';

void main() {
  group('BookUploadFormModel', () {
    const tId = 'form_123';
    const tTitle = 'The Great Gatsby';
    const tIsbn = '9780743273565';
    const tAuthor = 'F. Scott Fitzgerald';
    const tDescription = 'A classic American novel set in the Jazz Age.';
    const tGenres = ['Fiction', 'Classic', 'Literature'];
    const tPublishedYear = 1925;
    const tPublisher = 'Charles Scribner\'s Sons';
    const tLanguage = 'English';
    const tPageCount = 180;
    const tAgeAppropriateness = 16;
    const tIsSearchResult = false;
    final tCreatedAt = DateTime(2023, 5, 15, 10, 30);
    final tUpdatedAt = DateTime(2023, 5, 20, 14, 45);

    final tBookCopies = [
      const BookCopy(
        id: 'copy_1',
        imageUrls: ['https://example.com/image1.jpg'],
        condition: BookCondition.veryGood,
        isForSale: true,
        isForRent: false,
        isForDonate: false,
        expectedPrice: 15.99,
        notes: 'Excellent condition copy',
      ),
      const BookCopy(
        id: 'copy_2',
        imageUrls: ['https://example.com/image2.jpg'],
        condition: BookCondition.good,
        isForSale: false,
        isForRent: true,
        isForDonate: false,
        rentPrice: 3.99,
        notes: 'Available for rent',
      ),
    ];

    final tBookUploadFormModel = BookUploadFormModel(
      id: tId,
      title: tTitle,
      isbn: tIsbn,
      author: tAuthor,
      description: tDescription,
      genres: tGenres,
      publishedYear: tPublishedYear,
      publisher: tPublisher,
      language: tLanguage,
      pageCount: tPageCount,
      ageAppropriateness: tAgeAppropriateness,
      copies: tBookCopies,
      isSearchResult: tIsSearchResult,
      createdAt: tCreatedAt,
      updatedAt: tUpdatedAt,
    );

    group('fromJson', () {
      test('should return a valid BookUploadFormModel from JSON with all fields', () {
        // arrange
        final Map<String, dynamic> jsonMap = {
          'id': tId,
          'title': tTitle,
          'isbn': tIsbn,
          'author': tAuthor,
          'description': tDescription,
          'genres': tGenres,
          'publishedYear': tPublishedYear,
          'publisher': tPublisher,
          'language': tLanguage,
          'pageCount': tPageCount,
          'ageAppropriateness': tAgeAppropriateness,
          'copies': [
            {
              'id': 'copy_1',
              'images': ['https://example.com/image1.jpg'],
              'condition': 'very good',
              'isForSale': true,
              'isForRent': false,
              'isForDonate': false,
              'expectedPrice': 15.99,
              'notes': 'Excellent condition copy',
            },
            {
              'id': 'copy_2',
              'images': ['https://example.com/image2.jpg'],
              'condition': 'good',
              'isForSale': false,
              'isForRent': true,
              'isForDonate': false,
              'rentPrice': 3.99,
              'notes': 'Available for rent',
            },
          ],
          'isSearchResult': tIsSearchResult,
          'createdAt': tCreatedAt.toIso8601String(),
          'updatedAt': tUpdatedAt.toIso8601String(),
        };

        // act
        final result = BookUploadFormModel.fromJson(jsonMap);

        // assert
        expect(result.id, equals(tId));
        expect(result.title, equals(tTitle));
        expect(result.isbn, equals(tIsbn));
        expect(result.author, equals(tAuthor));
        expect(result.description, equals(tDescription));
        expect(result.genres, equals(tGenres));
        expect(result.publishedYear, equals(tPublishedYear));
        expect(result.publisher, equals(tPublisher));
        expect(result.language, equals(tLanguage));
        expect(result.pageCount, equals(tPageCount));
        expect(result.ageAppropriateness, equals(tAgeAppropriateness));
        expect(result.copies.length, equals(2));
        expect(result.isSearchResult, equals(tIsSearchResult));
        expect(result.createdAt, equals(tCreatedAt));
        expect(result.updatedAt, equals(tUpdatedAt));
      });

      test('should return BookUploadFormModel with required fields only', () {
        // arrange
        final Map<String, dynamic> jsonMap = {
          'title': tTitle,
          'isbn': tIsbn,
          'author': tAuthor,
          'description': tDescription,
          'genres': tGenres,
          'copies': [],
        };

        // act
        final result = BookUploadFormModel.fromJson(jsonMap);

        // assert
        expect(result.id, isNull);
        expect(result.title, equals(tTitle));
        expect(result.isbn, equals(tIsbn));
        expect(result.author, equals(tAuthor));
        expect(result.description, equals(tDescription));
        expect(result.genres, equals(tGenres));
        expect(result.publishedYear, isNull);
        expect(result.publisher, isNull);
        expect(result.language, isNull);
        expect(result.pageCount, isNull);
        expect(result.ageAppropriateness, isNull);
        expect(result.copies, isEmpty);
        expect(result.isSearchResult, isFalse);
        expect(result.createdAt, isNull);
        expect(result.updatedAt, isNull);
      });

      test('should handle null fields with default values', () {
        // arrange
        final Map<String, dynamic> jsonMap = {
          'title': null,
          'isbn': null,
          'author': null,
          'description': null,
          'genres': null,
          'copies': null,
          'isSearchResult': null,
        };

        // act
        final result = BookUploadFormModel.fromJson(jsonMap);

        // assert
        expect(result.title, equals(''));
        expect(result.isbn, equals(''));
        expect(result.author, equals(''));
        expect(result.description, equals(''));
        expect(result.genres, isEmpty);
        expect(result.copies, isEmpty);
        expect(result.isSearchResult, isFalse);
      });

      test('should handle empty lists correctly', () {
        // arrange
        final Map<String, dynamic> jsonMap = {
          'title': tTitle,
          'isbn': tIsbn,
          'author': tAuthor,
          'description': tDescription,
          'genres': <String>[],
          'copies': <Map<String, dynamic>>[],
        };

        // act
        final result = BookUploadFormModel.fromJson(jsonMap);

        // assert
        expect(result.genres, isEmpty);
        expect(result.copies, isEmpty);
      });

      test('should parse complex nested copies correctly', () {
        // arrange
        final Map<String, dynamic> jsonMap = {
          'title': tTitle,
          'isbn': tIsbn,
          'author': tAuthor,
          'description': tDescription,
          'genres': tGenres,
          'copies': [
            {
              'id': 'copy_complex',
              'images': ['https://example.com/complex.jpg'],
              'condition': 'like new',
              'isForSale': true,
              'isForRent': true,
              'isForDonate': true,
              'expectedPrice': 25.50,
              'rentPrice': 5.00,
              'notes': 'Complex copy with all options',
              'uploadDate': '2023-05-15T10:30:00.000Z',
              'updatedAt': '2023-05-20T14:45:00.000Z',
            },
          ],
        };

        // act
        final result = BookUploadFormModel.fromJson(jsonMap);

        // assert
        expect(result.copies.length, equals(1));
        final copy = result.copies.first;
        expect(copy.id, equals('copy_complex'));
        expect(copy.condition, equals(BookCondition.likeNew));
        expect(copy.isForSale, isTrue);
        expect(copy.isForRent, isTrue);
        expect(copy.isForDonate, isTrue);
        expect(copy.expectedPrice, equals(25.50));
        expect(copy.rentPrice, equals(5.00));
      });
    });

    group('toJson', () {
      test('should return a JSON map with all fields', () {
        // act
        final result = tBookUploadFormModel.toJson();

        // assert
        expect(result['id'], equals(tId));
        expect(result['title'], equals(tTitle));
        expect(result['isbn'], equals(tIsbn));
        expect(result['author'], equals(tAuthor));
        expect(result['description'], equals(tDescription));
        expect(result['genres'], equals(tGenres));
        expect(result['publishedYear'], equals(tPublishedYear));
        expect(result['publisher'], equals(tPublisher));
        expect(result['language'], equals(tLanguage));
        expect(result['pageCount'], equals(tPageCount));
        expect(result['ageAppropriateness'], equals(tAgeAppropriateness));
        expect(result['copies'], isA<List>());
        expect(result['copies'].length, equals(2));
        expect(result['isSearchResult'], equals(tIsSearchResult));
        expect(result['createdAt'], equals(tCreatedAt.toIso8601String()));
        expect(result['updatedAt'], equals(tUpdatedAt.toIso8601String()));
      });

      test('should handle null optional fields', () {
        // arrange
        const model = BookUploadFormModel(
          title: tTitle,
          isbn: tIsbn,
          author: tAuthor,
          description: tDescription,
          genres: tGenres,
          copies: [],
        );

        // act
        final result = model.toJson();

        // assert
        expect(result['id'], isNull);
        expect(result['publishedYear'], isNull);
        expect(result['publisher'], isNull);
        expect(result['language'], isNull);
        expect(result['pageCount'], isNull);
        expect(result['ageAppropriateness'], isNull);
        expect(result['createdAt'], isNull);
        expect(result['updatedAt'], isNull);
        expect(result['copies'], isEmpty);
        expect(result['isSearchResult'], isFalse);
      });

      test('should serialize copies correctly', () {
        // arrange
        final model = BookUploadFormModel(
          title: tTitle,
          isbn: tIsbn,
          author: tAuthor,
          description: tDescription,
          genres: tGenres,
          copies: [
            const BookCopy(
              id: 'test_copy',
              imageUrls: ['https://example.com/test.jpg'],
              condition: BookCondition.new_,
              isForSale: true,
              isForRent: false,
              isForDonate: false,
              expectedPrice: 20.00,
            ),
          ],
        );

        // act
        final result = model.toJson();

        // assert
        final copiesJson = result['copies'] as List;
        expect(copiesJson.length, equals(1));
        
        final copyJson = copiesJson.first as Map<String, dynamic>;
        expect(copyJson['id'], equals('test_copy'));
        expect(copyJson['condition'], equals('new_'));
        expect(copyJson['expectedPrice'], equals(20.00));
      });
    });

    group('fromEntity', () {
      test('should create model from BookUploadForm entity', () {
        // arrange
        final entity = BookUploadForm(
          id: tId,
          title: tTitle,
          isbn: tIsbn,
          author: tAuthor,
          description: tDescription,
          genres: tGenres,
          publishedYear: tPublishedYear,
          publisher: tPublisher,
          language: tLanguage,
          pageCount: tPageCount,
          ageAppropriateness: tAgeAppropriateness,
          copies: tBookCopies,
          isSearchResult: tIsSearchResult,
          createdAt: tCreatedAt,
          updatedAt: tUpdatedAt,
        );

        // act
        final result = BookUploadFormModel.fromEntity(entity);

        // assert
        expect(result.id, equals(tId));
        expect(result.title, equals(tTitle));
        expect(result.isbn, equals(tIsbn));
        expect(result.author, equals(tAuthor));
        expect(result.description, equals(tDescription));
        expect(result.genres, equals(tGenres));
        expect(result.publishedYear, equals(tPublishedYear));
        expect(result.publisher, equals(tPublisher));
        expect(result.language, equals(tLanguage));
        expect(result.pageCount, equals(tPageCount));
        expect(result.ageAppropriateness, equals(tAgeAppropriateness));
        expect(result.copies, equals(tBookCopies));
        expect(result.isSearchResult, equals(tIsSearchResult));
        expect(result.createdAt, equals(tCreatedAt));
        expect(result.updatedAt, equals(tUpdatedAt));
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        // arrange
        const newTitle = 'Updated Title';
        const newAuthor = 'Updated Author';
        const newIsSearchResult = true;
        final newCreatedAt = DateTime(2023, 6, 1);

        // act
        final result = tBookUploadFormModel.copyWith(
          title: newTitle,
          author: newAuthor,
          isSearchResult: newIsSearchResult,
          createdAt: newCreatedAt,
        );

        // assert
        expect(result.title, equals(newTitle));
        expect(result.author, equals(newAuthor));
        expect(result.isSearchResult, equals(newIsSearchResult));
        expect(result.createdAt, equals(newCreatedAt));
        // Check unchanged fields
        expect(result.id, equals(tId));
        expect(result.isbn, equals(tIsbn));
        expect(result.description, equals(tDescription));
        expect(result.genres, equals(tGenres));
        expect(result.publishedYear, equals(tPublishedYear));
        expect(result.publisher, equals(tPublisher));
        expect(result.language, equals(tLanguage));
        expect(result.pageCount, equals(tPageCount));
        expect(result.ageAppropriateness, equals(tAgeAppropriateness));
        expect(result.copies, equals(tBookCopies));
        expect(result.updatedAt, equals(tUpdatedAt));
      });

      test('should return same instance when no fields are updated', () {
        // act
        final result = tBookUploadFormModel.copyWith();

        // assert
        expect(result.id, equals(tBookUploadFormModel.id));
        expect(result.title, equals(tBookUploadFormModel.title));
        expect(result.isbn, equals(tBookUploadFormModel.isbn));
        expect(result.author, equals(tBookUploadFormModel.author));
        expect(result.description, equals(tBookUploadFormModel.description));
        expect(result.genres, equals(tBookUploadFormModel.genres));
        expect(result.publishedYear, equals(tBookUploadFormModel.publishedYear));
        expect(result.publisher, equals(tBookUploadFormModel.publisher));
        expect(result.language, equals(tBookUploadFormModel.language));
        expect(result.pageCount, equals(tBookUploadFormModel.pageCount));
        expect(result.ageAppropriateness, equals(tBookUploadFormModel.ageAppropriateness));
        expect(result.copies, equals(tBookUploadFormModel.copies));
        expect(result.isSearchResult, equals(tBookUploadFormModel.isSearchResult));
        expect(result.createdAt, equals(tBookUploadFormModel.createdAt));
        expect(result.updatedAt, equals(tBookUploadFormModel.updatedAt));
      });

      test('should preserve original values when null is passed to copyWith', () {
        // act
        final result = tBookUploadFormModel.copyWith(
          id: null,
          publishedYear: null,
          publisher: null,
        );

        // assert
        // copyWith with null should preserve original values due to null-coalescing operator
        expect(result.id, equals(tId));
        expect(result.publishedYear, equals(tPublishedYear));
        expect(result.publisher, equals(tPublisher));
      });

      test('should update copies list correctly', () {
        // arrange
        final newCopies = [
          const BookCopy(
            id: 'new_copy',
            imageUrls: ['https://example.com/new.jpg'],
            condition: BookCondition.new_,
            isForSale: true,
            isForRent: false,
            isForDonate: false,
          ),
        ];

        // act
        final result = tBookUploadFormModel.copyWith(copies: newCopies);

        // assert
        expect(result.copies, equals(newCopies));
        expect(result.copies.length, equals(1));
        expect(result.copies.first.id, equals('new_copy'));
      });
    });

    group('serialization roundtrip', () {
      test('should maintain data integrity through JSON serialization roundtrip', () {
        // act
        final json = tBookUploadFormModel.toJson();
        final reconstructed = BookUploadFormModel.fromJson(json);

        // assert
        expect(reconstructed.id, equals(tBookUploadFormModel.id));
        expect(reconstructed.title, equals(tBookUploadFormModel.title));
        expect(reconstructed.isbn, equals(tBookUploadFormModel.isbn));
        expect(reconstructed.author, equals(tBookUploadFormModel.author));
        expect(reconstructed.description, equals(tBookUploadFormModel.description));
        expect(reconstructed.genres, equals(tBookUploadFormModel.genres));
        expect(reconstructed.publishedYear, equals(tBookUploadFormModel.publishedYear));
        expect(reconstructed.publisher, equals(tBookUploadFormModel.publisher));
        expect(reconstructed.language, equals(tBookUploadFormModel.language));
        expect(reconstructed.pageCount, equals(tBookUploadFormModel.pageCount));
        expect(reconstructed.ageAppropriateness, equals(tBookUploadFormModel.ageAppropriateness));
        expect(reconstructed.copies.length, equals(tBookUploadFormModel.copies.length));
        expect(reconstructed.isSearchResult, equals(tBookUploadFormModel.isSearchResult));
        expect(reconstructed.createdAt, equals(tBookUploadFormModel.createdAt));
        expect(reconstructed.updatedAt, equals(tBookUploadFormModel.updatedAt));
      });

      test('should handle minimal form data in roundtrip', () {
        // arrange
        const model = BookUploadFormModel(
          title: 'Minimal Book',
          isbn: '1234567890123',
          author: 'Test Author',
          description: 'Test description',
          genres: ['Test'],
          copies: [],
        );

        // act
        final json = model.toJson();
        final reconstructed = BookUploadFormModel.fromJson(json);

        // assert
        expect(reconstructed.title, equals(model.title));
        expect(reconstructed.isbn, equals(model.isbn));
        expect(reconstructed.author, equals(model.author));
        expect(reconstructed.description, equals(model.description));
        expect(reconstructed.genres, equals(model.genres));
        expect(reconstructed.copies, isEmpty);
        expect(reconstructed.isSearchResult, isFalse);
      });

      test('should handle complex form with multiple copies in roundtrip', () {
        // arrange
        final complexCopies = [
          const BookCopy(
            id: 'copy_1',
            imageUrls: ['https://example.com/1.jpg', 'https://example.com/1a.jpg'],
            condition: BookCondition.likeNew,
            isForSale: true,
            isForRent: true,
            isForDonate: false,
            expectedPrice: 29.99,
            rentPrice: 7.99,
            notes: 'First copy with detailed notes',
          ),
          const BookCopy(
            id: 'copy_2',
            imageUrls: ['https://example.com/2.jpg'],
            condition: BookCondition.acceptable,
            isForSale: false,
            isForRent: false,
            isForDonate: true,
            notes: 'Second copy for donation',
          ),
        ];

        final model = BookUploadFormModel(
          id: 'complex_form',
          title: 'Complex Book',
          isbn: '9781234567890',
          author: 'Complex Author',
          description: 'A very detailed description of the book',
          genres: ['Fiction', 'Adventure', 'Classic'],
          publishedYear: 1950,
          publisher: 'Test Publisher Inc.',
          language: 'English',
          pageCount: 456,
          ageAppropriateness: 18,
          copies: complexCopies,
          isSearchResult: true,
          createdAt: DateTime(2023, 1, 1, 12, 0),
          updatedAt: DateTime(2023, 6, 1, 15, 30),
        );

        // act
        final json = model.toJson();
        final reconstructed = BookUploadFormModel.fromJson(json);

        // assert
        expect(reconstructed.copies.length, equals(2));
        expect(reconstructed.copies[0].condition, equals(BookCondition.likeNew));
        expect(reconstructed.copies[0].expectedPrice, equals(29.99));
        expect(reconstructed.copies[1].condition, equals(BookCondition.acceptable));
        expect(reconstructed.copies[1].isForDonate, isTrue);
      });
    });

    group('edge cases', () {
      test('should handle empty string fields', () {
        // arrange
        const model = BookUploadFormModel(
          title: '',
          isbn: '',
          author: '',
          description: '',
          genres: [],
          copies: [],
        );

        // act
        final json = model.toJson();
        final reconstructed = BookUploadFormModel.fromJson(json);

        // assert
        expect(reconstructed.title, equals(''));
        expect(reconstructed.isbn, equals(''));
        expect(reconstructed.author, equals(''));
        expect(reconstructed.description, equals(''));
        expect(reconstructed.genres, isEmpty);
        expect(reconstructed.copies, isEmpty);
      });

      test('should handle special characters in text fields', () {
        // arrange
        const model = BookUploadFormModel(
          title: 'Book with émojis 📚 and symbols !@#\$%^&*()',
          isbn: '978-0-123456-78-9',
          author: 'Authör with àccénts',
          description: 'Description with\nnewlines and\ttabs',
          genres: ['Scí-Fi & Fantasy', 'Non-Fiction/Educational'],
          copies: [],
        );

        // act
        final json = model.toJson();
        final reconstructed = BookUploadFormModel.fromJson(json);

        // assert
        expect(reconstructed.title, equals(model.title));
        expect(reconstructed.isbn, equals(model.isbn));
        expect(reconstructed.author, equals(model.author));
        expect(reconstructed.description, equals(model.description));
        expect(reconstructed.genres, equals(model.genres));
      });

      test('should handle large number of genres', () {
        // arrange
        final manyGenres = List.generate(20, (i) => 'Genre $i');
        final model = BookUploadFormModel(
          title: tTitle,
          isbn: tIsbn,
          author: tAuthor,
          description: tDescription,
          genres: manyGenres,
          copies: [],
        );

        // act
        final json = model.toJson();
        final reconstructed = BookUploadFormModel.fromJson(json);

        // assert
        expect(reconstructed.genres.length, equals(20));
        expect(reconstructed.genres, equals(manyGenres));
      });

      test('should handle extreme numeric values', () {
        // arrange
        const model = BookUploadFormModel(
          title: tTitle,
          isbn: tIsbn,
          author: tAuthor,
          description: tDescription,
          genres: tGenres,
          publishedYear: -100, // Very old book
          pageCount: 10000, // Very long book
          ageAppropriateness: 0, // All ages
          copies: [],
        );

        // act
        final json = model.toJson();
        final reconstructed = BookUploadFormModel.fromJson(json);

        // assert
        expect(reconstructed.publishedYear, equals(-100));
        expect(reconstructed.pageCount, equals(10000));
        expect(reconstructed.ageAppropriateness, equals(0));
      });

      test('should handle very long description', () {
        // arrange
        final longDescription = 'A' * 10000; // 10k characters
        final model = BookUploadFormModel(
          title: tTitle,
          isbn: tIsbn,
          author: tAuthor,
          description: longDescription,
          genres: tGenres,
          copies: [],
        );

        // act
        final json = model.toJson();
        final reconstructed = BookUploadFormModel.fromJson(json);

        // assert
        expect(reconstructed.description, equals(longDescription));
        expect(reconstructed.description.length, equals(10000));
      });
    });
  });
}
