import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/book_details/data/models/book_rating_model.dart';
import 'package:flutter_library/features/book_details/domain/entities/book_rating.dart';

void main() {
  group('BookRatingModel', () {
    final tDateTime = DateTime(2023, 5, 15, 10, 30);
    final tBookRatingModel = BookRatingModel(
      id: 'rating_123',
      bookId: 'book_456',
      userId: 'user_789',
      rating: 4.5,
      createdAt: tDateTime,
      updatedAt: tDateTime,
    );

    final tJson = {
      'id': 'rating_123',
      'bookId': 'book_456',
      'userId': 'user_789',
      'rating': 4.5,
      'createdAt': tDateTime.toIso8601String(),
      'updatedAt': tDateTime.toIso8601String(),
    };

    group('fromJson', () {
      test('should create model from valid JSON', () {
        // act
        final result = BookRatingModel.fromJson(tJson);

        // assert
        expect(result.id, equals('rating_123'));
        expect(result.bookId, equals('book_456'));
        expect(result.userId, equals('user_789'));
        expect(result.rating, equals(4.5));
        expect(result.createdAt, equals(tDateTime));
        expect(result.updatedAt, equals(tDateTime));
      });

      test('should handle integer rating as double', () {
        // arrange
        final jsonWithIntRating = {
          'id': 'rating_123',
          'bookId': 'book_456',
          'userId': 'user_789',
          'rating': 4, // integer
          'createdAt': tDateTime.toIso8601String(),
          'updatedAt': tDateTime.toIso8601String(),
        };

        // act
        final result = BookRatingModel.fromJson(jsonWithIntRating);

        // assert
        expect(result.rating, equals(4.0));
        expect(result.rating, isA<double>());
      });

      test('should parse ISO8601 date strings correctly', () {
        // arrange
        final dateTime = DateTime.parse('2023-12-25T15:30:45.000Z');
        final json = {
          'id': 'rating_1',
          'bookId': 'book_1',
          'userId': 'user_1',
          'rating': 5.0,
          'createdAt': '2023-12-25T15:30:45.000Z',
          'updatedAt': '2023-12-25T15:30:45.000Z',
        };

        // act
        final result = BookRatingModel.fromJson(json);

        // assert
        expect(result.createdAt, equals(dateTime));
        expect(result.updatedAt, equals(dateTime));
      });

      test('should handle minimum rating', () {
        // arrange
        final json = {
          'id': 'rating_1',
          'bookId': 'book_1',
          'userId': 'user_1',
          'rating': 0.0,
          'createdAt': tDateTime.toIso8601String(),
          'updatedAt': tDateTime.toIso8601String(),
        };

        // act
        final result = BookRatingModel.fromJson(json);

        // assert
        expect(result.rating, equals(0.0));
      });

      test('should handle maximum rating', () {
        // arrange
        final json = {
          'id': 'rating_1',
          'bookId': 'book_1',
          'userId': 'user_1',
          'rating': 5.0,
          'createdAt': tDateTime.toIso8601String(),
          'updatedAt': tDateTime.toIso8601String(),
        };

        // act
        final result = BookRatingModel.fromJson(json);

        // assert
        expect(result.rating, equals(5.0));
      });

      test('should handle decimal ratings', () {
        // arrange
        final json = {
          'id': 'rating_1',
          'bookId': 'book_1',
          'userId': 'user_1',
          'rating': 3.7,
          'createdAt': tDateTime.toIso8601String(),
          'updatedAt': tDateTime.toIso8601String(),
        };

        // act
        final result = BookRatingModel.fromJson(json);

        // assert
        expect(result.rating, equals(3.7));
      });
    });

    group('fromEntity', () {
      test('should create model from entity', () {
        // arrange
        final entity = BookRating(
          id: 'rating_123',
          bookId: 'book_456',
          userId: 'user_789',
          rating: 4.5,
          createdAt: tDateTime,
          updatedAt: tDateTime,
        );

        // act
        final result = BookRatingModel.fromEntity(entity);

        // assert
        expect(result.id, equals(entity.id));
        expect(result.bookId, equals(entity.bookId));
        expect(result.userId, equals(entity.userId));
        expect(result.rating, equals(entity.rating));
        expect(result.createdAt, equals(entity.createdAt));
        expect(result.updatedAt, equals(entity.updatedAt));
      });

      test('should preserve all entity properties', () {
        // arrange
        final now = DateTime.now();
        final entity = BookRating(
          id: 'test_id',
          bookId: 'test_book',
          userId: 'test_user',
          rating: 2.5,
          createdAt: now,
          updatedAt: now,
        );

        // act
        final result = BookRatingModel.fromEntity(entity);

        // assert
        expect(result, isA<BookRatingModel>());
        expect(result.props, equals(entity.props));
      });
    });

    group('toJson', () {
      test('should convert model to JSON', () {
        // act
        final result = tBookRatingModel.toJson();

        // assert
        expect(result, equals(tJson));
      });

      test('should produce valid ISO8601 date strings', () {
        // act
        final result = tBookRatingModel.toJson();

        // assert
        expect(result['createdAt'], isA<String>());
        expect(result['updatedAt'], isA<String>());
        expect(DateTime.parse(result['createdAt'] as String), isA<DateTime>());
        expect(DateTime.parse(result['updatedAt'] as String), isA<DateTime>());
      });

      test('should include all required fields', () {
        // act
        final result = tBookRatingModel.toJson();

        // assert
        expect(result.containsKey('id'), isTrue);
        expect(result.containsKey('bookId'), isTrue);
        expect(result.containsKey('userId'), isTrue);
        expect(result.containsKey('rating'), isTrue);
        expect(result.containsKey('createdAt'), isTrue);
        expect(result.containsKey('updatedAt'), isTrue);
      });

      test('should preserve rating precision', () {
        // arrange
        final rating = BookRatingModel(
          id: 'id',
          bookId: 'book',
          userId: 'user',
          rating: 3.75,
          createdAt: tDateTime,
          updatedAt: tDateTime,
        );

        // act
        final result = rating.toJson();

        // assert
        expect(result['rating'], equals(3.75));
      });
    });

    group('copyWith', () {
      test('should create copy with updated id', () {
        // act
        final result = tBookRatingModel.copyWith(id: 'new_id');

        // assert
        expect(result.id, equals('new_id'));
        expect(result.bookId, equals(tBookRatingModel.bookId));
        expect(result.userId, equals(tBookRatingModel.userId));
        expect(result.rating, equals(tBookRatingModel.rating));
      });

      test('should create copy with updated bookId', () {
        // act
        final result = tBookRatingModel.copyWith(bookId: 'new_book');

        // assert
        expect(result.bookId, equals('new_book'));
        expect(result.id, equals(tBookRatingModel.id));
      });

      test('should create copy with updated userId', () {
        // act
        final result = tBookRatingModel.copyWith(userId: 'new_user');

        // assert
        expect(result.userId, equals('new_user'));
        expect(result.id, equals(tBookRatingModel.id));
      });

      test('should create copy with updated rating', () {
        // act
        final result = tBookRatingModel.copyWith(rating: 3.0);

        // assert
        expect(result.rating, equals(3.0));
        expect(result.id, equals(tBookRatingModel.id));
      });

      test('should create copy with updated createdAt', () {
        // arrange
        final newDate = DateTime(2024, 1, 1);

        // act
        final result = tBookRatingModel.copyWith(createdAt: newDate);

        // assert
        expect(result.createdAt, equals(newDate));
        expect(result.updatedAt, equals(tBookRatingModel.updatedAt));
      });

      test('should create copy with updated updatedAt', () {
        // arrange
        final newDate = DateTime(2024, 1, 1);

        // act
        final result = tBookRatingModel.copyWith(updatedAt: newDate);

        // assert
        expect(result.updatedAt, equals(newDate));
        expect(result.createdAt, equals(tBookRatingModel.createdAt));
      });

      test('should create exact copy when no parameters provided', () {
        // act
        final result = tBookRatingModel.copyWith();

        // assert
        expect(result.id, equals(tBookRatingModel.id));
        expect(result.bookId, equals(tBookRatingModel.bookId));
        expect(result.userId, equals(tBookRatingModel.userId));
        expect(result.rating, equals(tBookRatingModel.rating));
        expect(result.createdAt, equals(tBookRatingModel.createdAt));
        expect(result.updatedAt, equals(tBookRatingModel.updatedAt));
      });

      test('should create copy with multiple updated fields', () {
        // arrange
        final newDate = DateTime(2024, 6, 1);

        // act
        final result = tBookRatingModel.copyWith(
          rating: 5.0,
          updatedAt: newDate,
        );

        // assert
        expect(result.rating, equals(5.0));
        expect(result.updatedAt, equals(newDate));
        expect(result.id, equals(tBookRatingModel.id));
        expect(result.bookId, equals(tBookRatingModel.bookId));
      });

      test('should return BookRatingModel instance', () {
        // act
        final result = tBookRatingModel.copyWith(rating: 4.0);

        // assert
        expect(result, isA<BookRatingModel>());
      });
    });

    group('inheritance and properties', () {
      test('should extend BookRating entity', () {
        // assert
        expect(tBookRatingModel, isA<BookRating>());
      });

      test('should have correct props for equality comparison', () {
        // arrange
        final rating1 = BookRatingModel(
          id: 'id',
          bookId: 'book',
          userId: 'user',
          rating: 4.0,
          createdAt: tDateTime,
          updatedAt: tDateTime,
        );
        final rating2 = BookRatingModel(
          id: 'id',
          bookId: 'book',
          userId: 'user',
          rating: 4.0,
          createdAt: tDateTime,
          updatedAt: tDateTime,
        );

        // assert
        expect(rating1, equals(rating2));
        expect(rating1.props, equals(rating2.props));
      });

      test('should not equal ratings with different values', () {
        // arrange
        final rating1 = tBookRatingModel;
        final rating2 = tBookRatingModel.copyWith(rating: 3.0);

        // assert
        expect(rating1, isNot(equals(rating2)));
      });
    });

    group('JSON round-trip', () {
      test('should maintain data integrity in fromJson -> toJson', () {
        // act
        final model = BookRatingModel.fromJson(tJson);
        final json = model.toJson();

        // assert
        expect(json, equals(tJson));
      });

      test('should maintain data integrity in toJson -> fromJson', () {
        // act
        final json = tBookRatingModel.toJson();
        final model = BookRatingModel.fromJson(json);

        // assert
        expect(model.id, equals(tBookRatingModel.id));
        expect(model.bookId, equals(tBookRatingModel.bookId));
        expect(model.userId, equals(tBookRatingModel.userId));
        expect(model.rating, equals(tBookRatingModel.rating));
        expect(model.createdAt, equals(tBookRatingModel.createdAt));
        expect(model.updatedAt, equals(tBookRatingModel.updatedAt));
      });
    });
  });
}
