import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/book_details/data/models/review_model.dart';
import 'package:flutter_library/features/book_details/domain/entities/review.dart';

void main() {
  group('ReviewModel', () {
    final testCreatedAt = DateTime(2023, 1, 15, 10, 30, 0);
    final testUpdatedAt = DateTime(2023, 1, 16, 12, 0, 0);
    
    final testReviewModel = ReviewModel(
      id: 'review_1',
      bookId: 'book_1',
      userId: 'user_1',
      userName: 'John Doe',
      userAvatarUrl: null,
      reviewText: 'This is an excellent book! Highly recommended.',
      rating: 4.5,
      helpfulCount: 0,
      unhelpfulCount: 0,
      isReported: false,
      isEdited: false,
      createdAt: testCreatedAt,
      updatedAt: testUpdatedAt,
      currentUserVote: null,
    );

    final testJson = {
      'id': 'review_1',
      'bookId': 'book_1',
      'userId': 'user_1',
      'userName': 'John Doe',
      'userAvatarUrl': null,
      'reviewText': 'This is an excellent book! Highly recommended.',
      'rating': 4.5,
      'helpfulCount': 0,
      'unhelpfulCount': 0,
      'isReported': false,
      'isEdited': false,
      'createdAt': '2023-01-15T10:30:00.000',
      'updatedAt': '2023-01-16T12:00:00.000',
      'currentUserVote': null,
    };

    group('Entity Extension', () {
      test('should be a subclass of Review entity', () {
        expect(testReviewModel, isA<Review>());
      });

      test('should have correct properties from parent entity', () {
        expect(testReviewModel.id, equals('review_1'));
        expect(testReviewModel.bookId, equals('book_1'));
        expect(testReviewModel.userId, equals('user_1'));
        expect(testReviewModel.userName, equals('John Doe'));
        expect(testReviewModel.reviewText, equals('This is an excellent book! Highly recommended.'));
        expect(testReviewModel.rating, equals(4.5));
        expect(testReviewModel.createdAt, equals(testCreatedAt));
        expect(testReviewModel.updatedAt, equals(testUpdatedAt));
      });
    });

    group('fromJson', () {
      test('should return a valid ReviewModel from JSON', () {
        // act
        final result = ReviewModel.fromJson(testJson);

        // assert
        expect(result, isA<ReviewModel>());
        expect(result.id, equals('review_1'));
        expect(result.bookId, equals('book_1'));
        expect(result.userId, equals('user_1'));
        expect(result.userName, equals('John Doe'));
        expect(result.reviewText, equals('This is an excellent book! Highly recommended.'));
        expect(result.rating, equals(4.5));
        expect(result.createdAt, equals(testCreatedAt));
        expect(result.updatedAt, equals(testUpdatedAt));
      });

      test('should handle integer rating from JSON', () {
        // arrange
        final jsonWithIntRating = Map<String, dynamic>.from(testJson);
        jsonWithIntRating['rating'] = 4;

        // act
        final result = ReviewModel.fromJson(jsonWithIntRating);

        // assert
        expect(result.rating, equals(4.0));
      });

      test('should throw when required fields are missing', () {
        // arrange
        final incompleteJson = <String, dynamic>{
          'id': 'review_1',
          'bookId': 'book_1',
          // missing other required fields
        };

        // act & assert
        expect(() => ReviewModel.fromJson(incompleteJson), throwsA(isA<TypeError>()));
      });

      test('should throw when date strings are invalid', () {
        // arrange
        final jsonWithInvalidDate = Map<String, dynamic>.from(testJson);
        jsonWithInvalidDate['createdAt'] = 'invalid-date';

        // act & assert
        expect(() => ReviewModel.fromJson(jsonWithInvalidDate), throwsA(isA<FormatException>()));
      });
    });

    group('toJson', () {
      test('should return a valid JSON map', () {
        // act
        final result = testReviewModel.toJson();

        // assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['id'], equals('review_1'));
        expect(result['bookId'], equals('book_1'));
        expect(result['userId'], equals('user_1'));
        expect(result['userName'], equals('John Doe'));
        expect(result['reviewText'], equals('This is an excellent book! Highly recommended.'));
        expect(result['rating'], equals(4.5));
        expect(result['createdAt'], equals('2023-01-15T10:30:00.000'));
        expect(result['updatedAt'], equals('2023-01-16T12:00:00.000'));
      });

      test('should maintain data integrity in round-trip conversion', () {
        // act
        final json = testReviewModel.toJson();
        final reconstructed = ReviewModel.fromJson(json);

        // assert
        expect(reconstructed.id, equals(testReviewModel.id));
        expect(reconstructed.bookId, equals(testReviewModel.bookId));
        expect(reconstructed.userId, equals(testReviewModel.userId));
        expect(reconstructed.userName, equals(testReviewModel.userName));
        expect(reconstructed.reviewText, equals(testReviewModel.reviewText));
        expect(reconstructed.rating, equals(testReviewModel.rating));
        expect(reconstructed.createdAt, equals(testReviewModel.createdAt));
        expect(reconstructed.updatedAt, equals(testReviewModel.updatedAt));
      });
    });

    group('fromEntity', () {
      test('should create ReviewModel from Review entity with all fields', () {
        // arrange
        final review = Review(
          id: 'review_123',
          bookId: 'book_456',
          userId: 'user_789',
          userName: 'Jane Smith',
          userAvatarUrl: 'https://example.com/avatar.jpg',
          reviewText: 'Excellent read! Highly recommend.',
          rating: 4.8,
          helpfulCount: 15,
          unhelpfulCount: 2,
          isReported: false,
          isEdited: true,
          createdAt: DateTime(2024, 3, 15, 14, 30),
          updatedAt: DateTime(2024, 3, 16, 10, 0),
          currentUserVote: 'upvote',
        );

        // act
        final result = ReviewModel.fromEntity(review);

        // assert
        expect(result, isA<ReviewModel>());
        expect(result.id, equals('review_123'));
        expect(result.bookId, equals('book_456'));
        expect(result.userId, equals('user_789'));
        expect(result.userName, equals('Jane Smith'));
        expect(result.userAvatarUrl, equals('https://example.com/avatar.jpg'));
        expect(result.reviewText, equals('Excellent read! Highly recommend.'));
        expect(result.rating, equals(4.8));
        expect(result.helpfulCount, equals(15));
        expect(result.unhelpfulCount, equals(2));
        expect(result.isReported, isFalse);
        expect(result.isEdited, isTrue);
        expect(result.createdAt, equals(DateTime(2024, 3, 15, 14, 30)));
        expect(result.updatedAt, equals(DateTime(2024, 3, 16, 10, 0)));
        expect(result.currentUserVote, equals('upvote'));
      });

      test('should create ReviewModel from Review entity with null optional fields', () {
        // arrange
        final review = Review(
          id: 'review_abc',
          bookId: 'book_def',
          userId: 'user_ghi',
          userName: 'Bob Johnson',
          userAvatarUrl: null,
          reviewText: 'Good book',
          rating: 3.5,
          helpfulCount: 0,
          unhelpfulCount: 0,
          isReported: false,
          isEdited: false,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 2),
          currentUserVote: null,
        );

        // act
        final result = ReviewModel.fromEntity(review);

        // assert
        expect(result, isA<ReviewModel>());
        expect(result.id, equals('review_abc'));
        expect(result.userAvatarUrl, isNull);
        expect(result.helpfulCount, equals(0));
        expect(result.unhelpfulCount, equals(0));
        expect(result.currentUserVote, isNull);
      });

      test('should create ReviewModel from Review entity with downvote', () {
        // arrange
        final review = Review(
          id: 'review_xyz',
          bookId: 'book_123',
          userId: 'user_456',
          userName: 'Alice Brown',
          reviewText: 'Not impressed',
          rating: 2.0,
          helpfulCount: 1,
          unhelpfulCount: 10,
          isReported: true,
          isEdited: false,
          createdAt: DateTime(2023, 12, 25),
          updatedAt: DateTime(2023, 12, 26),
          currentUserVote: 'downvote',
        );

        // act
        final result = ReviewModel.fromEntity(review);

        // assert
        expect(result.currentUserVote, equals('downvote'));
        expect(result.isReported, isTrue);
        expect(result.helpfulCount, equals(1));
        expect(result.unhelpfulCount, equals(10));
      });

      test('should preserve all data from entity in round-trip conversion', () {
        // arrange
        final originalReview = Review(
          id: 'review_round',
          bookId: 'book_trip',
          userId: 'user_test',
          userName: 'Test User',
          userAvatarUrl: 'https://test.com/pic.png',
          reviewText: 'Test review text with special chars: © ® ™ € £ ¥',
          rating: 4.25,
          helpfulCount: 42,
          unhelpfulCount: 7,
          isReported: false,
          isEdited: true,
          createdAt: DateTime(2024, 6, 15, 9, 30, 45),
          updatedAt: DateTime(2024, 6, 15, 10, 15, 20),
          currentUserVote: 'upvote',
        );

        // act
        final model = ReviewModel.fromEntity(originalReview);
        final backToEntity = Review(
          id: model.id,
          bookId: model.bookId,
          userId: model.userId,
          userName: model.userName,
          userAvatarUrl: model.userAvatarUrl,
          reviewText: model.reviewText,
          rating: model.rating,
          helpfulCount: model.helpfulCount,
          unhelpfulCount: model.unhelpfulCount,
          isReported: model.isReported,
          isEdited: model.isEdited,
          createdAt: model.createdAt,
          updatedAt: model.updatedAt,
          currentUserVote: model.currentUserVote,
        );

        // assert
        expect(backToEntity.id, equals(originalReview.id));
        expect(backToEntity.bookId, equals(originalReview.bookId));
        expect(backToEntity.userId, equals(originalReview.userId));
        expect(backToEntity.userName, equals(originalReview.userName));
        expect(backToEntity.userAvatarUrl, equals(originalReview.userAvatarUrl));
        expect(backToEntity.reviewText, equals(originalReview.reviewText));
        expect(backToEntity.rating, equals(originalReview.rating));
        expect(backToEntity.helpfulCount, equals(originalReview.helpfulCount));
        expect(backToEntity.unhelpfulCount, equals(originalReview.unhelpfulCount));
        expect(backToEntity.isReported, equals(originalReview.isReported));
        expect(backToEntity.isEdited, equals(originalReview.isEdited));
        expect(backToEntity.createdAt, equals(originalReview.createdAt));
        expect(backToEntity.updatedAt, equals(originalReview.updatedAt));
        expect(backToEntity.currentUserVote, equals(originalReview.currentUserVote));
      });
    });

    group('Equality', () {
      test('should be equal to another ReviewModel with same values', () {
        // arrange
        final otherReviewModel = ReviewModel(
          id: 'review_1',
          bookId: 'book_1',
          userId: 'user_1',
          userName: 'John Doe',
          reviewText: 'This is an excellent book! Highly recommended.',
          rating: 4.5,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // act & assert
        expect(testReviewModel, equals(otherReviewModel));
        expect(testReviewModel.hashCode, equals(otherReviewModel.hashCode));
      });

      test('should not be equal to ReviewModel with different values', () {
        // arrange
        final differentReviewModel = ReviewModel(
          id: 'review_2', // different id
          bookId: 'book_1',
          userId: 'user_1',
          userName: 'John Doe',
          reviewText: 'This is an excellent book! Highly recommended.',
          rating: 4.5,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        // act & assert
        expect(testReviewModel, isNot(equals(differentReviewModel)));
      });
    });

    group('Edge Cases', () {
      test('should handle empty review text', () {
        // arrange
        final jsonWithEmptyText = Map<String, dynamic>.from(testJson);
        jsonWithEmptyText['reviewText'] = '';

        // act
        final result = ReviewModel.fromJson(jsonWithEmptyText);

        // assert
        expect(result.reviewText, equals(''));
      });

      test('should handle minimum rating', () {
        // arrange
        final jsonWithMinRating = Map<String, dynamic>.from(testJson);
        jsonWithMinRating['rating'] = 0.0;

        // act
        final result = ReviewModel.fromJson(jsonWithMinRating);

        // assert
        expect(result.rating, equals(0.0));
      });

      test('should handle maximum rating', () {
        // arrange
        final jsonWithMaxRating = Map<String, dynamic>.from(testJson);
        jsonWithMaxRating['rating'] = 5.0;

        // act
        final result = ReviewModel.fromJson(jsonWithMaxRating);

        // assert
        expect(result.rating, equals(5.0));
      });

      test('should handle very long review text', () {
        // arrange
        final longText = 'A' * 10000;
        final jsonWithLongText = Map<String, dynamic>.from(testJson);
        jsonWithLongText['reviewText'] = longText;

        // act
        final result = ReviewModel.fromJson(jsonWithLongText);

        // assert
        expect(result.reviewText, equals(longText));
        expect(result.reviewText.length, equals(10000));
      });

      test('should handle special characters in review text', () {
        // arrange
        const specialText = 'This book is 💯! It\'s "amazing" & <cool> — 5/5 ⭐⭐⭐⭐⭐';
        final jsonWithSpecialChars = Map<String, dynamic>.from(testJson);
        jsonWithSpecialChars['reviewText'] = specialText;

        // act
        final result = ReviewModel.fromJson(jsonWithSpecialChars);

        // assert
        expect(result.reviewText, equals(specialText));
      });

      test('should handle special characters in userName', () {
        // arrange
        const specialName = "O'Brien-Smith (Author's Friend) 👤";
        final jsonWithSpecialName = Map<String, dynamic>.from(testJson);
        jsonWithSpecialName['userName'] = specialName;

        // act
        final result = ReviewModel.fromJson(jsonWithSpecialName);

        // assert
        expect(result.userName, equals(specialName));
      });
    });

    group('copyWith', () {
      test('should create copy with updated id', () {
        // act
        final result = testReviewModel.copyWith(id: 'review_2');

        // assert
        expect(result.id, equals('review_2'));
        expect(result.bookId, equals(testReviewModel.bookId));
        expect(result.userId, equals(testReviewModel.userId));
        expect(result.userName, equals(testReviewModel.userName));
        expect(result.reviewText, equals(testReviewModel.reviewText));
        expect(result.rating, equals(testReviewModel.rating));
        expect(result.createdAt, equals(testReviewModel.createdAt));
        expect(result.updatedAt, equals(testReviewModel.updatedAt));
      });

      test('should create copy with updated bookId', () {
        // act
        final result = testReviewModel.copyWith(bookId: 'book_2');

        // assert
        expect(result.bookId, equals('book_2'));
        expect(result.id, equals(testReviewModel.id));
        expect(result.userId, equals(testReviewModel.userId));
      });

      test('should create copy with updated userId', () {
        // act
        final result = testReviewModel.copyWith(userId: 'user_2');

        // assert
        expect(result.userId, equals('user_2'));
        expect(result.id, equals(testReviewModel.id));
      });

      test('should create copy with updated userName', () {
        // act
        final result = testReviewModel.copyWith(userName: 'Jane Smith');

        // assert
        expect(result.userName, equals('Jane Smith'));
        expect(result.id, equals(testReviewModel.id));
      });

      test('should create copy with updated reviewText', () {
        // act
        final result = testReviewModel.copyWith(reviewText: 'Updated review text');

        // assert
        expect(result.reviewText, equals('Updated review text'));
        expect(result.id, equals(testReviewModel.id));
      });

      test('should create copy with updated rating', () {
        // act
        final result = testReviewModel.copyWith(rating: 3.5);

        // assert
        expect(result.rating, equals(3.5));
        expect(result.id, equals(testReviewModel.id));
      });

      test('should create copy with updated createdAt', () {
        // arrange
        final newDate = DateTime(2024, 1, 1);

        // act
        final result = testReviewModel.copyWith(createdAt: newDate);

        // assert
        expect(result.createdAt, equals(newDate));
        expect(result.id, equals(testReviewModel.id));
      });

      test('should create copy with updated updatedAt', () {
        // arrange
        final newDate = DateTime(2024, 2, 1);

        // act
        final result = testReviewModel.copyWith(updatedAt: newDate);

        // assert
        expect(result.updatedAt, equals(newDate));
        expect(result.id, equals(testReviewModel.id));
      });

      test('should create copy with multiple updated fields', () {
        // arrange
        final newUpdatedAt = DateTime(2024, 2, 1);

        // act
        final result = testReviewModel.copyWith(
          id: 'review_updated',
          reviewText: 'Updated review',
          rating: 3.0,
          updatedAt: newUpdatedAt,
        );

        // assert
        expect(result.id, equals('review_updated'));
        expect(result.reviewText, equals('Updated review'));
        expect(result.rating, equals(3.0));
        expect(result.updatedAt, equals(newUpdatedAt));
        
        // Unchanged fields
        expect(result.bookId, equals(testReviewModel.bookId));
        expect(result.userId, equals(testReviewModel.userId));
        expect(result.userName, equals(testReviewModel.userName));
        expect(result.createdAt, equals(testReviewModel.createdAt));
      });

      test('should create identical copy when no parameters provided', () {
        // act
        final result = testReviewModel.copyWith();

        // assert
        expect(result.id, equals(testReviewModel.id));
        expect(result.bookId, equals(testReviewModel.bookId));
        expect(result.userId, equals(testReviewModel.userId));
        expect(result.userName, equals(testReviewModel.userName));
        expect(result.reviewText, equals(testReviewModel.reviewText));
        expect(result.rating, equals(testReviewModel.rating));
        expect(result.createdAt, equals(testReviewModel.createdAt));
        expect(result.updatedAt, equals(testReviewModel.updatedAt));
      });

      test('should create copy with clearCurrentUserVote set to true', () {
        // arrange
        final reviewWithVote = testReviewModel.copyWith(currentUserVote: 'upvote');
        
        // act
        final result = reviewWithVote.copyWith(clearCurrentUserVote: true);

        // assert
        expect(result.currentUserVote, isNull);
        expect(result.id, equals(testReviewModel.id));
        expect(result.bookId, equals(testReviewModel.bookId));
        expect(result.userId, equals(testReviewModel.userId));
      });

      test('should create copy with clearCurrentUserVote set to false (retain vote)', () {
        // arrange
        final reviewWithVote = testReviewModel.copyWith(currentUserVote: 'downvote');
        
        // act
        final result = reviewWithVote.copyWith(clearCurrentUserVote: false);

        // assert
        expect(result.currentUserVote, equals('downvote'));
        expect(result.id, equals(testReviewModel.id));
      });

      test('should update currentUserVote when provided without clearCurrentUserVote', () {
        // act
        final result = testReviewModel.copyWith(currentUserVote: 'upvote');

        // assert
        expect(result.currentUserVote, equals('upvote'));
        expect(result.id, equals(testReviewModel.id));
      });
    });

    group('Additional JSON Edge Cases', () {
      test('should handle fractional ratings from JSON', () {
        // arrange
        final jsonWithFractionalRating = Map<String, dynamic>.from(testJson);
        jsonWithFractionalRating['rating'] = 4.75;

        // act
        final result = ReviewModel.fromJson(jsonWithFractionalRating);

        // assert
        expect(result.rating, equals(4.75));
      });

      test('should handle different date formats', () {
        // arrange
        final jsonWithDifferentDate = Map<String, dynamic>.from(testJson);
        jsonWithDifferentDate['createdAt'] = '2023-12-31T23:59:59.999Z';
        jsonWithDifferentDate['updatedAt'] = '2024-01-01T00:00:00.000Z';

        // act
        final result = ReviewModel.fromJson(jsonWithDifferentDate);

        // assert
        expect(result.createdAt.year, equals(2023));
        expect(result.createdAt.month, equals(12));
        expect(result.createdAt.day, equals(31));
        expect(result.updatedAt.year, equals(2024));
        expect(result.updatedAt.month, equals(1));
        expect(result.updatedAt.day, equals(1));
      });

      test('should handle negative ratings (if allowed)', () {
        // arrange
        final jsonWithNegativeRating = Map<String, dynamic>.from(testJson);
        jsonWithNegativeRating['rating'] = -1.0;

        // act
        final result = ReviewModel.fromJson(jsonWithNegativeRating);

        // assert
        expect(result.rating, equals(-1.0));
      });

      test('should handle very high ratings (if allowed)', () {
        // arrange
        final jsonWithHighRating = Map<String, dynamic>.from(testJson);
        jsonWithHighRating['rating'] = 100.0;

        // act
        final result = ReviewModel.fromJson(jsonWithHighRating);

        // assert
        expect(result.rating, equals(100.0));
      });

      test('should maintain precision in toJson for fractional ratings', () {
        // arrange
        final reviewWithFractionalRating = testReviewModel.copyWith(rating: 4.75);

        // act
        final json = reviewWithFractionalRating.toJson();

        // assert
        expect(json['rating'], equals(4.75));
      });

      test('should handle empty string fields', () {
        // arrange
        final jsonWithEmptyFields = Map<String, dynamic>.from(testJson);
        jsonWithEmptyFields['userName'] = '';
        jsonWithEmptyFields['reviewText'] = '';

        // act
        final result = ReviewModel.fromJson(jsonWithEmptyFields);

        // assert
        expect(result.userName, equals(''));
        expect(result.reviewText, equals(''));
      });

      test('should preserve whitespace in review text', () {
        // arrange
        const textWithWhitespace = '  This book is great!  \n\n  Highly recommended.  ';
        final jsonWithWhitespace = Map<String, dynamic>.from(testJson);
        jsonWithWhitespace['reviewText'] = textWithWhitespace;

        // act
        final result = ReviewModel.fromJson(jsonWithWhitespace);

        // assert
        expect(result.reviewText, equals(textWithWhitespace));
      });
    });

    group('Edge Cases', () {
      test('should handle empty review text', () {
        // arrange
        final jsonWithEmptyText = Map<String, dynamic>.from(testJson);
        jsonWithEmptyText['reviewText'] = '';

        // act
        final result = ReviewModel.fromJson(jsonWithEmptyText);

        // assert
        expect(result.reviewText, equals(''));
      });

      test('should handle minimum rating', () {
        // arrange
        final jsonWithMinRating = Map<String, dynamic>.from(testJson);
        jsonWithMinRating['rating'] = 0.0;

        // act
        final result = ReviewModel.fromJson(jsonWithMinRating);

        // assert
        expect(result.rating, equals(0.0));
      });

      test('should handle maximum rating', () {
        // arrange
        final jsonWithMaxRating = Map<String, dynamic>.from(testJson);
        jsonWithMaxRating['rating'] = 5.0;

        // act
        final result = ReviewModel.fromJson(jsonWithMaxRating);

        // assert
        expect(result.rating, equals(5.0));
      });
    });

    group('Enhanced Fields', () {
      test('should handle userAvatarUrl when provided', () {
        // arrange
        final jsonWithAvatar = Map<String, dynamic>.from(testJson);
        jsonWithAvatar['userAvatarUrl'] = 'https://example.com/avatar.jpg';

        // act
        final result = ReviewModel.fromJson(jsonWithAvatar);

        // assert
        expect(result.userAvatarUrl, equals('https://example.com/avatar.jpg'));
      });

      test('should handle userAvatarUrl when null', () {
        // arrange
        final jsonWithNullAvatar = Map<String, dynamic>.from(testJson);
        jsonWithNullAvatar['userAvatarUrl'] = null;

        // act
        final result = ReviewModel.fromJson(jsonWithNullAvatar);

        // assert
        expect(result.userAvatarUrl, isNull);
      });

      test('should handle helpfulCount', () {
        // arrange
        final jsonWithHelpful = Map<String, dynamic>.from(testJson);
        jsonWithHelpful['helpfulCount'] = 42;

        // act
        final result = ReviewModel.fromJson(jsonWithHelpful);

        // assert
        expect(result.helpfulCount, equals(42));
      });

      test('should handle unhelpfulCount', () {
        // arrange
        final jsonWithUnhelpful = Map<String, dynamic>.from(testJson);
        jsonWithUnhelpful['unhelpfulCount'] = 7;

        // act
        final result = ReviewModel.fromJson(jsonWithUnhelpful);

        // assert
        expect(result.unhelpfulCount, equals(7));
      });

      test('should handle isReported when true', () {
        // arrange
        final jsonReported = Map<String, dynamic>.from(testJson);
        jsonReported['isReported'] = true;

        // act
        final result = ReviewModel.fromJson(jsonReported);

        // assert
        expect(result.isReported, isTrue);
      });

      test('should handle isReported when false', () {
        // arrange
        final jsonNotReported = Map<String, dynamic>.from(testJson);
        jsonNotReported['isReported'] = false;

        // act
        final result = ReviewModel.fromJson(jsonNotReported);

        // assert
        expect(result.isReported, isFalse);
      });

      test('should handle isEdited when true', () {
        // arrange
        final jsonEdited = Map<String, dynamic>.from(testJson);
        jsonEdited['isEdited'] = true;

        // act
        final result = ReviewModel.fromJson(jsonEdited);

        // assert
        expect(result.isEdited, isTrue);
      });

      test('should handle isEdited when false', () {
        // arrange
        final jsonNotEdited = Map<String, dynamic>.from(testJson);
        jsonNotEdited['isEdited'] = false;

        // act
        final result = ReviewModel.fromJson(jsonNotEdited);

        // assert
        expect(result.isEdited, isFalse);
      });

      test('should handle currentUserVote when upvote', () {
        // arrange
        final jsonWithUpvote = Map<String, dynamic>.from(testJson);
        jsonWithUpvote['currentUserVote'] = 'upvote';

        // act
        final result = ReviewModel.fromJson(jsonWithUpvote);

        // assert
        expect(result.currentUserVote, equals('upvote'));
      });

      test('should handle currentUserVote when downvote', () {
        // arrange
        final jsonWithDownvote = Map<String, dynamic>.from(testJson);
        jsonWithDownvote['currentUserVote'] = 'downvote';

        // act
        final result = ReviewModel.fromJson(jsonWithDownvote);

        // assert
        expect(result.currentUserVote, equals('downvote'));
      });

      test('should handle currentUserVote when null', () {
        // arrange
        final jsonWithNoVote = Map<String, dynamic>.from(testJson);
        jsonWithNoVote['currentUserVote'] = null;

        // act
        final result = ReviewModel.fromJson(jsonWithNoVote);

        // assert
        expect(result.currentUserVote, isNull);
      });
    });

    group('Review Entity Helper Methods', () {
      group('isAuthor', () {
        test('should return true when currentUserId matches userId', () {
          // arrange
          final review = ReviewModel(
            id: 'review_1',
            bookId: 'book_1',
            userId: 'user_123',
            userName: 'John Doe',
            userAvatarUrl: null,
            reviewText: 'Great book!',
            rating: 4.5,
            helpfulCount: 0,
            unhelpfulCount: 0,
            isReported: false,
            isEdited: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            currentUserVote: null,
          );

          // act & assert
          expect(review.isAuthor('user_123'), isTrue);
        });

        test('should return false when currentUserId does not match userId', () {
          // arrange
          final review = ReviewModel(
            id: 'review_1',
            bookId: 'book_1',
            userId: 'user_123',
            userName: 'John Doe',
            userAvatarUrl: null,
            reviewText: 'Great book!',
            rating: 4.5,
            helpfulCount: 0,
            unhelpfulCount: 0,
            isReported: false,
            isEdited: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            currentUserVote: null,
          );

          // act & assert
          expect(review.isAuthor('user_456'), isFalse);
        });

        test('should return false when currentUserId is null', () {
          // arrange
          final review = ReviewModel(
            id: 'review_1',
            bookId: 'book_1',
            userId: 'user_123',
            userName: 'John Doe',
            userAvatarUrl: null,
            reviewText: 'Great book!',
            rating: 4.5,
            helpfulCount: 0,
            unhelpfulCount: 0,
            isReported: false,
            isEdited: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            currentUserVote: null,
          );

          // act & assert
          expect(review.isAuthor(null), isFalse);
        });
      });

      group('netHelpfulness', () {
        test('should return positive value when more helpful votes', () {
          // arrange
          final review = ReviewModel(
            id: 'review_1',
            bookId: 'book_1',
            userId: 'user_1',
            userName: 'John Doe',
            userAvatarUrl: null,
            reviewText: 'Great book!',
            rating: 4.5,
            helpfulCount: 10,
            unhelpfulCount: 3,
            isReported: false,
            isEdited: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            currentUserVote: null,
          );

          // act & assert
          expect(review.netHelpfulness, equals(7));
        });

        test('should return negative value when more unhelpful votes', () {
          // arrange
          final review = ReviewModel(
            id: 'review_1',
            bookId: 'book_1',
            userId: 'user_1',
            userName: 'John Doe',
            userAvatarUrl: null,
            reviewText: 'Great book!',
            rating: 4.5,
            helpfulCount: 5,
            unhelpfulCount: 12,
            isReported: false,
            isEdited: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            currentUserVote: null,
          );

          // act & assert
          expect(review.netHelpfulness, equals(-7));
        });

        test('should return zero when equal votes', () {
          // arrange
          final review = ReviewModel(
            id: 'review_1',
            bookId: 'book_1',
            userId: 'user_1',
            userName: 'John Doe',
            userAvatarUrl: null,
            reviewText: 'Great book!',
            rating: 4.5,
            helpfulCount: 8,
            unhelpfulCount: 8,
            isReported: false,
            isEdited: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            currentUserVote: null,
          );

          // act & assert
          expect(review.netHelpfulness, equals(0));
        });

        test('should return zero when no votes', () {
          // arrange
          final review = ReviewModel(
            id: 'review_1',
            bookId: 'book_1',
            userId: 'user_1',
            userName: 'John Doe',
            userAvatarUrl: null,
            reviewText: 'Great book!',
            rating: 4.5,
            helpfulCount: 0,
            unhelpfulCount: 0,
            isReported: false,
            isEdited: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            currentUserVote: null,
          );

          // act & assert
          expect(review.netHelpfulness, equals(0));
        });
      });

      group('hasVotes', () {
        test('should return true when has helpful votes only', () {
          // arrange
          final review = ReviewModel(
            id: 'review_1',
            bookId: 'book_1',
            userId: 'user_1',
            userName: 'John Doe',
            userAvatarUrl: null,
            reviewText: 'Great book!',
            rating: 4.5,
            helpfulCount: 5,
            unhelpfulCount: 0,
            isReported: false,
            isEdited: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            currentUserVote: null,
          );

          // act & assert
          expect(review.hasVotes, isTrue);
        });

        test('should return true when has unhelpful votes only', () {
          // arrange
          final review = ReviewModel(
            id: 'review_1',
            bookId: 'book_1',
            userId: 'user_1',
            userName: 'John Doe',
            userAvatarUrl: null,
            reviewText: 'Great book!',
            rating: 4.5,
            helpfulCount: 0,
            unhelpfulCount: 3,
            isReported: false,
            isEdited: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            currentUserVote: null,
          );

          // act & assert
          expect(review.hasVotes, isTrue);
        });

        test('should return true when has both vote types', () {
          // arrange
          final review = ReviewModel(
            id: 'review_1',
            bookId: 'book_1',
            userId: 'user_1',
            userName: 'John Doe',
            userAvatarUrl: null,
            reviewText: 'Great book!',
            rating: 4.5,
            helpfulCount: 7,
            unhelpfulCount: 2,
            isReported: false,
            isEdited: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            currentUserVote: null,
          );

          // act & assert
          expect(review.hasVotes, isTrue);
        });

        test('should return false when has no votes', () {
          // arrange
          final review = ReviewModel(
            id: 'review_1',
            bookId: 'book_1',
            userId: 'user_1',
            userName: 'John Doe',
            userAvatarUrl: null,
            reviewText: 'Great book!',
            rating: 4.5,
            helpfulCount: 0,
            unhelpfulCount: 0,
            isReported: false,
            isEdited: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            currentUserVote: null,
          );

          // act & assert
          expect(review.hasVotes, isFalse);
        });
      });

      group('hasUserVoted', () {
        test('should return true when currentUserVote is upvote', () {
          // arrange
          final review = ReviewModel(
            id: 'review_1',
            bookId: 'book_1',
            userId: 'user_1',
            userName: 'John Doe',
            userAvatarUrl: null,
            reviewText: 'Great book!',
            rating: 4.5,
            helpfulCount: 5,
            unhelpfulCount: 0,
            isReported: false,
            isEdited: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            currentUserVote: 'upvote',
          );

          // act & assert
          expect(review.hasUserVoted, isTrue);
        });

        test('should return true when currentUserVote is downvote', () {
          // arrange
          final review = ReviewModel(
            id: 'review_1',
            bookId: 'book_1',
            userId: 'user_1',
            userName: 'John Doe',
            userAvatarUrl: null,
            reviewText: 'Great book!',
            rating: 4.5,
            helpfulCount: 0,
            unhelpfulCount: 3,
            isReported: false,
            isEdited: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            currentUserVote: 'downvote',
          );

          // act & assert
          expect(review.hasUserVoted, isTrue);
        });

        test('should return false when currentUserVote is null', () {
          // arrange
          final review = ReviewModel(
            id: 'review_1',
            bookId: 'book_1',
            userId: 'user_1',
            userName: 'John Doe',
            userAvatarUrl: null,
            reviewText: 'Great book!',
            rating: 4.5,
            helpfulCount: 0,
            unhelpfulCount: 0,
            isReported: false,
            isEdited: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            currentUserVote: null,
          );

          // act & assert
          expect(review.hasUserVoted, isFalse);
        });
      });

      group('timeAgo', () {
        test('should return "Just now" for very recent review (< 1 minute)', () {
          // arrange
          final now = DateTime.now();
          final review = ReviewModel(
            id: 'review_1',
            bookId: 'book_1',
            userId: 'user_1',
            userName: 'John Doe',
            userAvatarUrl: null,
            reviewText: 'Great book!',
            rating: 4.5,
            helpfulCount: 0,
            unhelpfulCount: 0,
            isReported: false,
            isEdited: false,
            createdAt: now.subtract(const Duration(seconds: 30)),
            updatedAt: now,
            currentUserVote: null,
          );

          // act & assert
          expect(review.timeAgo, equals('Just now'));
        });

        test('should return minutes for recent review (< 1 hour)', () {
          // arrange
          final now = DateTime.now();
          final review = ReviewModel(
            id: 'review_1',
            bookId: 'book_1',
            userId: 'user_1',
            userName: 'John Doe',
            userAvatarUrl: null,
            reviewText: 'Great book!',
            rating: 4.5,
            helpfulCount: 0,
            unhelpfulCount: 0,
            isReported: false,
            isEdited: false,
            createdAt: now.subtract(const Duration(minutes: 15)),
            updatedAt: now,
            currentUserVote: null,
          );

          // act & assert
          expect(review.timeAgo, equals('15 minutes ago'));
        });

        test('should return 1 minute for singular', () {
          // arrange
          final now = DateTime.now();
          final review = ReviewModel(
            id: 'review_1',
            bookId: 'book_1',
            userId: 'user_1',
            userName: 'John Doe',
            userAvatarUrl: null,
            reviewText: 'Great book!',
            rating: 4.5,
            helpfulCount: 0,
            unhelpfulCount: 0,
            isReported: false,
            isEdited: false,
            createdAt: now.subtract(const Duration(minutes: 1)),
            updatedAt: now,
            currentUserVote: null,
          );

          // act & assert
          expect(review.timeAgo, equals('1 minute ago'));
        });

        test('should return hours for review within day (< 24 hours)', () {
          // arrange
          final now = DateTime.now();
          final review = ReviewModel(
            id: 'review_1',
            bookId: 'book_1',
            userId: 'user_1',
            userName: 'John Doe',
            userAvatarUrl: null,
            reviewText: 'Great book!',
            rating: 4.5,
            helpfulCount: 0,
            unhelpfulCount: 0,
            isReported: false,
            isEdited: false,
            createdAt: now.subtract(const Duration(hours: 5)),
            updatedAt: now,
            currentUserVote: null,
          );

          // act & assert
          expect(review.timeAgo, equals('5 hours ago'));
        });

        test('should return 1 hour for singular', () {
          // arrange
          final now = DateTime.now();
          final review = ReviewModel(
            id: 'review_1',
            bookId: 'book_1',
            userId: 'user_1',
            userName: 'John Doe',
            userAvatarUrl: null,
            reviewText: 'Great book!',
            rating: 4.5,
            helpfulCount: 0,
            unhelpfulCount: 0,
            isReported: false,
            isEdited: false,
            createdAt: now.subtract(const Duration(hours: 1)),
            updatedAt: now,
            currentUserVote: null,
          );

          // act & assert
          expect(review.timeAgo, equals('1 hour ago'));
        });

        test('should return days for review within month (< 30 days)', () {
          // arrange
          final now = DateTime.now();
          final review = ReviewModel(
            id: 'review_1',
            bookId: 'book_1',
            userId: 'user_1',
            userName: 'John Doe',
            userAvatarUrl: null,
            reviewText: 'Great book!',
            rating: 4.5,
            helpfulCount: 0,
            unhelpfulCount: 0,
            isReported: false,
            isEdited: false,
            createdAt: now.subtract(const Duration(days: 7)),
            updatedAt: now,
            currentUserVote: null,
          );

          // act & assert
          expect(review.timeAgo, equals('7 days ago'));
        });

        test('should return 1 day for singular', () {
          // arrange
          final now = DateTime.now();
          final review = ReviewModel(
            id: 'review_1',
            bookId: 'book_1',
            userId: 'user_1',
            userName: 'John Doe',
            userAvatarUrl: null,
            reviewText: 'Great book!',
            rating: 4.5,
            helpfulCount: 0,
            unhelpfulCount: 0,
            isReported: false,
            isEdited: false,
            createdAt: now.subtract(const Duration(days: 1)),
            updatedAt: now,
            currentUserVote: null,
          );

          // act & assert
          expect(review.timeAgo, equals('1 day ago'));
        });

        test('should return months for review within year (< 365 days)', () {
          // arrange
          final now = DateTime.now();
          final review = ReviewModel(
            id: 'review_1',
            bookId: 'book_1',
            userId: 'user_1',
            userName: 'John Doe',
            userAvatarUrl: null,
            reviewText: 'Great book!',
            rating: 4.5,
            helpfulCount: 0,
            unhelpfulCount: 0,
            isReported: false,
            isEdited: false,
            createdAt: now.subtract(const Duration(days: 90)),
            updatedAt: now,
            currentUserVote: null,
          );

          // act & assert
          expect(review.timeAgo, equals('3 months ago'));
        });

        test('should return 1 month for singular', () {
          // arrange
          final now = DateTime.now();
          final review = ReviewModel(
            id: 'review_1',
            bookId: 'book_1',
            userId: 'user_1',
            userName: 'John Doe',
            userAvatarUrl: null,
            reviewText: 'Great book!',
            rating: 4.5,
            helpfulCount: 0,
            unhelpfulCount: 0,
            isReported: false,
            isEdited: false,
            createdAt: now.subtract(const Duration(days: 35)),
            updatedAt: now,
            currentUserVote: null,
          );

          // act & assert
          expect(review.timeAgo, equals('1 month ago'));
        });

        test('should return years for old review (>= 365 days)', () {
          // arrange
          final now = DateTime.now();
          final review = ReviewModel(
            id: 'review_1',
            bookId: 'book_1',
            userId: 'user_1',
            userName: 'John Doe',
            userAvatarUrl: null,
            reviewText: 'Great book!',
            rating: 4.5,
            helpfulCount: 0,
            unhelpfulCount: 0,
            isReported: false,
            isEdited: false,
            createdAt: now.subtract(const Duration(days: 730)),
            updatedAt: now,
            currentUserVote: null,
          );

          // act & assert
          expect(review.timeAgo, equals('2 years ago'));
        });

        test('should return 1 year for singular', () {
          // arrange
          final now = DateTime.now();
          final review = ReviewModel(
            id: 'review_1',
            bookId: 'book_1',
            userId: 'user_1',
            userName: 'John Doe',
            userAvatarUrl: null,
            reviewText: 'Great book!',
            rating: 4.5,
            helpfulCount: 0,
            unhelpfulCount: 0,
            isReported: false,
            isEdited: false,
            createdAt: now.subtract(const Duration(days: 400)),
            updatedAt: now,
            currentUserVote: null,
          );

          // act & assert
          expect(review.timeAgo, equals('1 year ago'));
        });
      });
    });
  });
}
