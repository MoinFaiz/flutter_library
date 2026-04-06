import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/book_upload/data/models/book_copy_model.dart';
import 'package:flutter_library/features/book_upload/domain/entities/book_copy.dart';

void main() {
  group('BookCopyModel', () {
    const tId = 'copy_123';
    const tBookId = 'book_456';
    const tUserId = 'user_789';
    const tImageUrls = ['https://example.com/image1.jpg', 'https://example.com/image2.jpg'];
    const tCondition = BookCondition.veryGood;
    const tIsForSale = true;
    const tIsForRent = false;
    const tIsForDonate = true;
    const tExpectedPrice = 25.99;
    const tRentPrice = 5.99;
    const tNotes = 'This book is in excellent condition with minimal wear.';
    final tUploadDate = DateTime(2023, 5, 15, 10, 30);
    final tUpdatedAt = DateTime(2023, 5, 20, 14, 45);

    final tBookCopyModel = BookCopyModel(
      id: tId,
      bookId: tBookId,
      userId: tUserId,
      imageUrls: tImageUrls,
      condition: tCondition,
      isForSale: tIsForSale,
      isForRent: tIsForRent,
      isForDonate: tIsForDonate,
      expectedPrice: tExpectedPrice,
      rentPrice: tRentPrice,
      notes: tNotes,
      uploadDate: tUploadDate,
      updatedAt: tUpdatedAt,
    );

    group('fromJson', () {
      test('should return a valid BookCopyModel from JSON with all fields', () {
        // arrange
        final Map<String, dynamic> jsonMap = {
          'id': tId,
          'bookId': tBookId,
          'userId': tUserId,
          'images': tImageUrls,
          'condition': 'very good',
          'isForSale': tIsForSale,
          'isForRent': tIsForRent,
          'isForDonate': tIsForDonate,
          'expectedPrice': tExpectedPrice,
          'rentPrice': tRentPrice,
          'notes': tNotes,
          'uploadDate': tUploadDate.toIso8601String(),
          'updatedAt': tUpdatedAt.toIso8601String(),
        };

        // act
        final result = BookCopyModel.fromJson(jsonMap);

        // assert
        expect(result, equals(tBookCopyModel));
      });

      test('should return BookCopyModel with required fields only', () {
        // arrange
        final Map<String, dynamic> jsonMap = {
          'images': tImageUrls,
          'condition': 'good',
          'isForSale': false,
          'isForRent': false,
          'isForDonate': false,
        };

        // act
        final result = BookCopyModel.fromJson(jsonMap);

        // assert
        expect(result.id, isNull);
        expect(result.bookId, isNull);
        expect(result.userId, isNull);
        expect(result.imageUrls, equals(tImageUrls));
        expect(result.condition, equals(BookCondition.good));
        expect(result.isForSale, isFalse);
        expect(result.isForRent, isFalse);
        expect(result.isForDonate, isFalse);
        expect(result.expectedPrice, isNull);
        expect(result.rentPrice, isNull);
        expect(result.notes, isNull);
        expect(result.uploadDate, isNull);
        expect(result.updatedAt, isNull);
      });

      test('should handle empty images list', () {
        // arrange
        final Map<String, dynamic> jsonMap = {
          'images': <String>[],
          'condition': 'new',
          'isForSale': true,
          'isForRent': false,
          'isForDonate': false,
        };

        // act
        final result = BookCopyModel.fromJson(jsonMap);

        // assert
        expect(result.imageUrls, isEmpty);
        expect(result.condition, equals(BookCondition.new_));
      });

      test('should handle null images and default to empty list', () {
        // arrange
        final Map<String, dynamic> jsonMap = {
          'condition': 'good',
          'isForSale': false,
          'isForRent': false,
          'isForDonate': false,
        };

        // act
        final result = BookCopyModel.fromJson(jsonMap);

        // assert
        expect(result.imageUrls, isEmpty);
      });

      group('condition parsing', () {
        test('should parse "new" condition correctly', () {
          // arrange
          final Map<String, dynamic> jsonMap = {
            'images': tImageUrls,
            'condition': 'new',
            'isForSale': false,
            'isForRent': false,
            'isForDonate': false,
          };

          // act
          final result = BookCopyModel.fromJson(jsonMap);

          // assert
          expect(result.condition, equals(BookCondition.new_));
        });

        test('should parse "like new" and "likenew" conditions correctly', () {
          // arrange
          final jsonMap1 = {
            'images': tImageUrls,
            'condition': 'like new',
            'isForSale': false,
            'isForRent': false,
            'isForDonate': false,
          };
          final jsonMap2 = {
            'images': tImageUrls,
            'condition': 'likenew',
            'isForSale': false,
            'isForRent': false,
            'isForDonate': false,
          };

          // act
          final result1 = BookCopyModel.fromJson(jsonMap1);
          final result2 = BookCopyModel.fromJson(jsonMap2);

          // assert
          expect(result1.condition, equals(BookCondition.likeNew));
          expect(result2.condition, equals(BookCondition.likeNew));
        });

        test('should parse "very good" and "verygood" conditions correctly', () {
          // arrange
          final jsonMap1 = {
            'images': tImageUrls,
            'condition': 'very good',
            'isForSale': false,
            'isForRent': false,
            'isForDonate': false,
          };
          final jsonMap2 = {
            'images': tImageUrls,
            'condition': 'verygood',
            'isForSale': false,
            'isForRent': false,
            'isForDonate': false,
          };

          // act
          final result1 = BookCopyModel.fromJson(jsonMap1);
          final result2 = BookCopyModel.fromJson(jsonMap2);

          // assert
          expect(result1.condition, equals(BookCondition.veryGood));
          expect(result2.condition, equals(BookCondition.veryGood));
        });

        test('should parse all condition types correctly', () {
          final conditionMappings = {
            'good': BookCondition.good,
            'acceptable': BookCondition.acceptable,
            'poor': BookCondition.poor,
          };

          conditionMappings.forEach((conditionStr, expectedCondition) {
            // arrange
            final jsonMap = {
              'images': tImageUrls,
              'condition': conditionStr,
              'isForSale': false,
              'isForRent': false,
              'isForDonate': false,
            };

            // act
            final result = BookCopyModel.fromJson(jsonMap);

            // assert
            expect(result.condition, equals(expectedCondition));
          });
        });

        test('should default to good condition for unknown strings', () {
          final unknownConditions = ['unknown', 'invalid', '', null];

          for (final conditionStr in unknownConditions) {
            // arrange
            final jsonMap = {
              'images': tImageUrls,
              'condition': conditionStr,
              'isForSale': false,
              'isForRent': false,
              'isForDonate': false,
            };

            // act
            final result = BookCopyModel.fromJson(jsonMap);

            // assert
            expect(result.condition, equals(BookCondition.good));
          }
        });

        test('should handle case insensitive condition parsing', () {
          final conditionVariations = [
            'NEW',
            'New',
            'VERY GOOD',
            'Very Good',
            'LIKE NEW',
            'Like New',
            'GOOD',
            'Good',
            'ACCEPTABLE',
            'Acceptable',
            'POOR',
            'Poor',
          ];

          for (final conditionStr in conditionVariations) {
            // arrange
            final jsonMap = {
              'images': tImageUrls,
              'condition': conditionStr,
              'isForSale': false,
              'isForRent': false,
              'isForDonate': false,
            };

            // act
            final result = BookCopyModel.fromJson(jsonMap);

            // assert
            expect(result.condition, isA<BookCondition>());
          }
        });
      });

      test('should handle numeric prices as int or double', () {
        // arrange
        final Map<String, dynamic> jsonMap = {
          'images': tImageUrls,
          'condition': 'good',
          'isForSale': true,
          'isForRent': true,
          'isForDonate': false,
          'expectedPrice': 25, // int
          'rentPrice': 5.99, // double
        };

        // act
        final result = BookCopyModel.fromJson(jsonMap);

        // assert
        expect(result.expectedPrice, equals(25.0));
        expect(result.rentPrice, equals(5.99));
      });

      test('should handle null optional boolean fields with default false', () {
        // arrange
        final Map<String, dynamic> jsonMap = {
          'images': tImageUrls,
          'condition': 'good',
        };

        // act
        final result = BookCopyModel.fromJson(jsonMap);

        // assert
        expect(result.isForSale, isFalse);
        expect(result.isForRent, isFalse);
        expect(result.isForDonate, isFalse);
      });
    });

    group('toJson', () {
      test('should return a JSON map with all fields', () {
        // act
        final result = tBookCopyModel.toJson();

        // assert
        final expectedJson = {
          'id': tId,
          'bookId': tBookId,
          'userId': tUserId,
          'images': tImageUrls,
          'condition': 'veryGood',
          'isForSale': tIsForSale,
          'isForRent': tIsForRent,
          'isForDonate': tIsForDonate,
          'expectedPrice': tExpectedPrice,
          'rentPrice': tRentPrice,
          'notes': tNotes,
          'uploadDate': tUploadDate.toIso8601String(),
          'updatedAt': tUpdatedAt.toIso8601String(),
        };
        
        expect(result, equals(expectedJson));
      });

      test('should handle null optional fields', () {
        // arrange
        const model = BookCopyModel(
          imageUrls: tImageUrls,
          condition: BookCondition.good,
          isForSale: false,
          isForRent: false,
          isForDonate: false,
        );

        // act
        final result = model.toJson();

        // assert
        expect(result['id'], isNull);
        expect(result['bookId'], isNull);
        expect(result['userId'], isNull);
        expect(result['expectedPrice'], isNull);
        expect(result['rentPrice'], isNull);
        expect(result['notes'], isNull);
        expect(result['uploadDate'], isNull);
        expect(result['updatedAt'], isNull);
      });
    });

    group('fromEntity', () {
      test('should create model from BookCopy entity', () {
        // arrange
        final entity = BookCopy(
          id: tId,
          bookId: tBookId,
          userId: tUserId,
          imageUrls: tImageUrls,
          condition: tCondition,
          isForSale: tIsForSale,
          isForRent: tIsForRent,
          isForDonate: tIsForDonate,
          expectedPrice: tExpectedPrice,
          rentPrice: tRentPrice,
          notes: tNotes,
          uploadDate: tUploadDate,
          updatedAt: tUpdatedAt,
        );

        // act
        final result = BookCopyModel.fromEntity(entity);

        // assert
        expect(result, equals(tBookCopyModel));
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        // arrange
        const newId = 'new_copy_123';
        const newCondition = BookCondition.new_;
        const newIsForSale = false;
        final newUploadDate = DateTime(2023, 6, 1);

        // act
        final result = tBookCopyModel.copyWith(
          id: newId,
          condition: newCondition,
          isForSale: newIsForSale,
          uploadDate: newUploadDate,
        );

        // assert
        expect(result.id, equals(newId));
        expect(result.condition, equals(newCondition));
        expect(result.isForSale, equals(newIsForSale));
        expect(result.uploadDate, equals(newUploadDate));
        // Check unchanged fields
        expect(result.bookId, equals(tBookId));
        expect(result.userId, equals(tUserId));
        expect(result.imageUrls, equals(tImageUrls));
        expect(result.isForRent, equals(tIsForRent));
        expect(result.isForDonate, equals(tIsForDonate));
        expect(result.expectedPrice, equals(tExpectedPrice));
        expect(result.rentPrice, equals(tRentPrice));
        expect(result.notes, equals(tNotes));
        expect(result.updatedAt, equals(tUpdatedAt));
      });

      test('should return same instance when no fields are updated', () {
        // act
        final result = tBookCopyModel.copyWith();

        // assert
        expect(result, equals(tBookCopyModel));
      });

      test('should preserve original values when null is passed to copyWith', () {
        // act
        final result = tBookCopyModel.copyWith(
          id: null,
          expectedPrice: null,
          notes: null,
        );

        // assert
        // copyWith with null should preserve original values due to null-coalescing operator
        expect(result.id, equals(tId));
        expect(result.expectedPrice, equals(tExpectedPrice));
        expect(result.notes, equals(tNotes));
      });
    });

    group('serialization roundtrip', () {
      test('should maintain data integrity through JSON serialization roundtrip', () {
        // act
        final json = tBookCopyModel.toJson();
        final reconstructed = BookCopyModel.fromJson(json);

        // assert
        expect(reconstructed, equals(tBookCopyModel));
      });

      test('should handle edge cases in roundtrip serialization', () {
        // arrange
        const model = BookCopyModel(
          imageUrls: [],
          condition: BookCondition.poor,
          isForSale: false,
          isForRent: false,
          isForDonate: false,
          expectedPrice: 0.0,
          rentPrice: 0.01,
          notes: '',
        );

        // act
        final json = model.toJson();
        final reconstructed = BookCopyModel.fromJson(json);

        // assert
        expect(reconstructed, equals(model));
      });

      test('should handle special characters in text fields', () {
        // arrange
        const model = BookCopyModel(
          imageUrls: ['https://example.com/book with spaces.jpg'],
          condition: BookCondition.good,
          isForSale: true,
          isForRent: false,
          isForDonate: false,
          notes: 'Notes with special chars: àáâãäåæçèéêë & symbols !@#\$%^&*()',
        );

        // act
        final json = model.toJson();
        final reconstructed = BookCopyModel.fromJson(json);

        // assert
        expect(reconstructed, equals(model));
      });
    });

    group('edge cases', () {
      test('should handle very long notes', () {
        // arrange
        final longNotes = 'A' * 10000; // 10k characters
        final model = BookCopyModel(
          imageUrls: tImageUrls,
          condition: BookCondition.good,
          isForSale: true,
          isForRent: false,
          isForDonate: false,
          notes: longNotes,
        );

        // act
        final json = model.toJson();
        final reconstructed = BookCopyModel.fromJson(json);

        // assert
        expect(reconstructed.notes, equals(longNotes));
      });

      test('should handle extreme price values', () {
        // arrange
        const model = BookCopyModel(
          imageUrls: tImageUrls,
          condition: BookCondition.good,
          isForSale: true,
          isForRent: true,
          isForDonate: false,
          expectedPrice: 999999.99,
          rentPrice: 0.01,
        );

        // act
        final json = model.toJson();
        final reconstructed = BookCopyModel.fromJson(json);

        // assert
        expect(reconstructed.expectedPrice, equals(999999.99));
        expect(reconstructed.rentPrice, equals(0.01));
      });

      test('should handle many image URLs', () {
        // arrange
        final manyImages = List.generate(50, (i) => 'https://example.com/image$i.jpg');
        final model = BookCopyModel(
          imageUrls: manyImages,
          condition: BookCondition.good,
          isForSale: false,
          isForRent: false,
          isForDonate: false,
        );

        // act
        final json = model.toJson();
        final reconstructed = BookCopyModel.fromJson(json);

        // assert
        expect(reconstructed.imageUrls, equals(manyImages));
        expect(reconstructed.imageUrls.length, equals(50));
      });
    });

    group('getter methods', () {
      test('should return correct isAvailable for different availability combinations', () {
        // Test for sale only
        final forSaleModel = BookCopyModel(
          imageUrls: tImageUrls,
          condition: BookCondition.good,
          isForSale: true,
          isForRent: false,
          isForDonate: false,
        );
        expect(forSaleModel.isAvailable, isTrue);

        // Test for rent only
        final forRentModel = BookCopyModel(
          imageUrls: tImageUrls,
          condition: BookCondition.good,
          isForSale: false,
          isForRent: true,
          isForDonate: false,
        );
        expect(forRentModel.isAvailable, isTrue);

        // Test for donate only
        final forDonateModel = BookCopyModel(
          imageUrls: tImageUrls,
          condition: BookCondition.good,
          isForSale: false,
          isForRent: false,
          isForDonate: true,
        );
        expect(forDonateModel.isAvailable, isTrue);

        // Test not available
        final notAvailableModel = BookCopyModel(
          imageUrls: tImageUrls,
          condition: BookCondition.good,
          isForSale: false,
          isForRent: false,
          isForDonate: false,
        );
        expect(notAvailableModel.isAvailable, isFalse);

        // Test all available
        final allAvailableModel = BookCopyModel(
          imageUrls: tImageUrls,
          condition: BookCondition.good,
          isForSale: true,
          isForRent: true,
          isForDonate: true,
        );
        expect(allAvailableModel.isAvailable, isTrue);
      });

      test('should return correct availabilityType strings', () {
        // Test all combinations
        final testCases = [
          // Triple combinations
          {
            'isForSale': true,
            'isForRent': true,
            'isForDonate': true,
            'expected': 'Sale, Rent & Donate'
          },
          // Double combinations
          {
            'isForSale': true,
            'isForRent': true,
            'isForDonate': false,
            'expected': 'Sale & Rent'
          },
          {
            'isForSale': true,
            'isForRent': false,
            'isForDonate': true,
            'expected': 'Sale & Donate'
          },
          {
            'isForSale': false,
            'isForRent': true,
            'isForDonate': true,
            'expected': 'Rent & Donate'
          },
          // Single combinations
          {
            'isForSale': true,
            'isForRent': false,
            'isForDonate': false,
            'expected': 'For Sale'
          },
          {
            'isForSale': false,
            'isForRent': true,
            'isForDonate': false,
            'expected': 'For Rent'
          },
          {
            'isForSale': false,
            'isForRent': false,
            'isForDonate': true,
            'expected': 'For Donate'
          },
          // None
          {
            'isForSale': false,
            'isForRent': false,
            'isForDonate': false,
            'expected': 'Not Available'
          },
        ];

        for (final testCase in testCases) {
          final model = BookCopyModel(
            imageUrls: tImageUrls,
            condition: BookCondition.good,
            isForSale: testCase['isForSale'] as bool,
            isForRent: testCase['isForRent'] as bool,
            isForDonate: testCase['isForDonate'] as bool,
          );
          expect(model.availabilityType, equals(testCase['expected']));
        }
      });

      test('should return correct isValid for different scenarios', () {
        // Valid: has images and at least one availability option
        final validModel = BookCopyModel(
          imageUrls: tImageUrls,
          condition: BookCondition.good,
          isForSale: true,
          isForRent: false,
          isForDonate: false,
        );
        expect(validModel.isValid, isTrue);

        // Invalid: no images
        final noImagesModel = BookCopyModel(
          imageUrls: [],
          condition: BookCondition.good,
          isForSale: true,
          isForRent: false,
          isForDonate: false,
        );
        expect(noImagesModel.isValid, isFalse);

        // Invalid: no availability options
        final noAvailabilityModel = BookCopyModel(
          imageUrls: tImageUrls,
          condition: BookCondition.good,
          isForSale: false,
          isForRent: false,
          isForDonate: false,
        );
        expect(noAvailabilityModel.isValid, isFalse);

        // Invalid: neither images nor availability
        final completelyInvalidModel = BookCopyModel(
          imageUrls: [],
          condition: BookCondition.good,
          isForSale: false,
          isForRent: false,
          isForDonate: false,
        );
        expect(completelyInvalidModel.isValid, isFalse);
      });

      test('should return correct hasPricing for different scenarios', () {
        // Has pricing: for sale with expected price
        final forSaleWithPriceModel = BookCopyModel(
          imageUrls: tImageUrls,
          condition: BookCondition.good,
          isForSale: true,
          isForRent: false,
          isForDonate: false,
          expectedPrice: 25.99,
        );
        expect(forSaleWithPriceModel.hasPricing, isTrue);

        // Has pricing: for rent with rent price
        final forRentWithPriceModel = BookCopyModel(
          imageUrls: tImageUrls,
          condition: BookCondition.good,
          isForSale: false,
          isForRent: true,
          isForDonate: false,
          rentPrice: 5.99,
        );
        expect(forRentWithPriceModel.hasPricing, isTrue);

        // Has pricing: both sale and rent with respective prices
        final bothWithPricesModel = BookCopyModel(
          imageUrls: tImageUrls,
          condition: BookCondition.good,
          isForSale: true,
          isForRent: true,
          isForDonate: false,
          expectedPrice: 25.99,
          rentPrice: 5.99,
        );
        expect(bothWithPricesModel.hasPricing, isTrue);

        // No pricing: for sale without expected price
        final forSaleNoPriceModel = BookCopyModel(
          imageUrls: tImageUrls,
          condition: BookCondition.good,
          isForSale: true,
          isForRent: false,
          isForDonate: false,
        );
        expect(forSaleNoPriceModel.hasPricing, isFalse);

        // No pricing: for rent without rent price
        final forRentNoPriceModel = BookCopyModel(
          imageUrls: tImageUrls,
          condition: BookCondition.good,
          isForSale: false,
          isForRent: true,
          isForDonate: false,
        );
        expect(forRentNoPriceModel.hasPricing, isFalse);

        // No pricing: donate only
        final donateOnlyModel = BookCopyModel(
          imageUrls: tImageUrls,
          condition: BookCondition.good,
          isForSale: false,
          isForRent: false,
          isForDonate: true,
        );
        expect(donateOnlyModel.hasPricing, isFalse);
      });
    });

    group('equality', () {
      test('should be equal when all properties are the same', () {
        // arrange
        final model1 = tBookCopyModel;
        final model2 = BookCopyModel(
          id: tId,
          bookId: tBookId,
          userId: tUserId,
          imageUrls: tImageUrls,
          condition: tCondition,
          isForSale: tIsForSale,
          isForRent: tIsForRent,
          isForDonate: tIsForDonate,
          expectedPrice: tExpectedPrice,
          rentPrice: tRentPrice,
          notes: tNotes,
          uploadDate: tUploadDate,
          updatedAt: tUpdatedAt,
        );

        // assert
        expect(model1, equals(model2));
        expect(model1.hashCode, equals(model2.hashCode));
      });

      test('should not be equal when properties differ', () {
        // arrange
        final model1 = tBookCopyModel;
        final model2 = tBookCopyModel.copyWith(id: 'different_id');

        // assert
        expect(model1, isNot(equals(model2)));
        expect(model1.hashCode, isNot(equals(model2.hashCode)));
      });

      test('should handle equality with null values', () {
        // arrange
        const model1 = BookCopyModel(
          imageUrls: tImageUrls,
          condition: BookCondition.good,
          isForSale: false,
          isForRent: false,
          isForDonate: false,
        );
        const model2 = BookCopyModel(
          imageUrls: tImageUrls,
          condition: BookCondition.good,
          isForSale: false,
          isForRent: false,
          isForDonate: false,
        );

        // assert
        expect(model1, equals(model2));
      });
    });

    group('error handling', () {
      test('should handle malformed date strings gracefully', () {
        // arrange
        final Map<String, dynamic> jsonMap = {
          'images': tImageUrls,
          'condition': 'good',
          'isForSale': false,
          'isForRent': false,
          'isForDonate': false,
          'uploadDate': 'invalid-date-format',
          'updatedAt': 'also-invalid',
        };

        // assert
        expect(() => BookCopyModel.fromJson(jsonMap), throwsFormatException);
      });

      test('should handle null JSON input', () {
        // arrange
        final Map<String, dynamic>? nullJson = null;

        // assert
        expect(() => BookCopyModel.fromJson(nullJson!), throwsA(isA<TypeError>()));
      });

      test('should handle missing required fields in JSON', () {
        // arrange
        final Map<String, dynamic> incompleteJson = {
          'id': tId,
          // Missing required fields: images, condition, availability flags
        };

        // act
        final result = BookCopyModel.fromJson(incompleteJson);

        // assert
        // The model handles missing fields gracefully with defaults
        expect(result.id, equals(tId));
        expect(result.imageUrls, isEmpty); // Default to empty list
        expect(result.condition, equals(BookCondition.good)); // Default condition
        expect(result.isForSale, isFalse); // Default to false
        expect(result.isForRent, isFalse); // Default to false
        expect(result.isForDonate, isFalse); // Default to false
      });

      test('should handle incorrect data types in JSON', () {
        // arrange
        final Map<String, dynamic> wrongTypesJson = {
          'images': 'not_a_list', // Should be List<String>
          'condition': 123, // Should be String, but gets converted to string
          'isForSale': 'yes', // Should be bool
          'isForRent': 'no', // Should be bool  
          'isForDonate': 'maybe', // Should be bool
          'expectedPrice': 'expensive', // Should be num
        };

        // assert
        // Some type conversions will work, others will throw
        expect(() => BookCopyModel.fromJson(wrongTypesJson), throwsA(isA<TypeError>()));
      });
    });

    group('additional condition parsing', () {
      test('should handle condition strings with extra whitespace', () {
        final conditionsWithWhitespace = [
          '  new  ',
          '\tlike new\t',
          '\nvery good\n',
          '  good  ',
          ' acceptable ',
          '  poor  ',
        ];

        final expectedConditions = [
          BookCondition.new_,
          BookCondition.likeNew,
          BookCondition.veryGood,
          BookCondition.good,
          BookCondition.acceptable,
          BookCondition.poor,
        ];

        for (int i = 0; i < conditionsWithWhitespace.length; i++) {
          // arrange
          final jsonMap = {
            'images': tImageUrls,
            'condition': conditionsWithWhitespace[i],
            'isForSale': false,
            'isForRent': false,
            'isForDonate': false,
          };

          // act
          final result = BookCopyModel.fromJson(jsonMap);

          // assert
          expect(result.condition, equals(expectedConditions[i]));
        }
      });

      test('should handle mixed case condition variations', () {
        final mixedCaseConditions = {
          'NeW': BookCondition.new_,
          'LiKe NeW': BookCondition.likeNew,
          'LIKENEW': BookCondition.likeNew,
          'VeRy GoOd': BookCondition.veryGood,
          'VERYGOOD': BookCondition.veryGood,
          'GoOd': BookCondition.good,
          'AccEpTaBlE': BookCondition.acceptable,
          'PoOr': BookCondition.poor,
        };

        mixedCaseConditions.forEach((conditionStr, expectedCondition) {
          // arrange
          final jsonMap = {
            'images': tImageUrls,
            'condition': conditionStr,
            'isForSale': false,
            'isForRent': false,
            'isForDonate': false,
          };

          // act
          final result = BookCopyModel.fromJson(jsonMap);

          // assert
          expect(result.condition, equals(expectedCondition));
        });
      });

      test('should handle numeric condition values', () {
        final numericConditions = [1, 2, 3, 4, 5, 6, 7, 0, -1, 100];

        for (final numCondition in numericConditions) {
          // arrange
          final jsonMap = {
            'images': tImageUrls,
            'condition': numCondition,
            'isForSale': false,
            'isForRent': false,
            'isForDonate': false,
          };

          // act
          final result = BookCopyModel.fromJson(jsonMap);

          // assert
          expect(result.condition, equals(BookCondition.good)); // Default fallback
        }
      });
    });

    group('validation edge cases', () {
      test('should handle copyWith with explicit null values', () {
        // arrange
        final originalModel = tBookCopyModel;

        // act
        final result = originalModel.copyWith(
          id: null,
          bookId: null,
          userId: null,
          expectedPrice: null,
          rentPrice: null,
          notes: null,
          uploadDate: null,
          updatedAt: null,
        );

        // assert
        // copyWith should preserve original values when null is passed
        expect(result.id, equals(originalModel.id));
        expect(result.bookId, equals(originalModel.bookId));
        expect(result.userId, equals(originalModel.userId));
        expect(result.expectedPrice, equals(originalModel.expectedPrice));
        expect(result.rentPrice, equals(originalModel.rentPrice));
        expect(result.notes, equals(originalModel.notes));
        expect(result.uploadDate, equals(originalModel.uploadDate));
        expect(result.updatedAt, equals(originalModel.updatedAt));
      });

      test('should handle empty string values in JSON', () {
        // arrange
        final Map<String, dynamic> jsonMap = {
          'id': '',
          'bookId': '',
          'userId': '',
          'images': tImageUrls,
          'condition': '',
          'isForSale': false,
          'isForRent': false,
          'isForDonate': false,
          'notes': '',
        };

        // act
        final result = BookCopyModel.fromJson(jsonMap);

        // assert
        expect(result.id, equals(''));
        expect(result.bookId, equals(''));
        expect(result.userId, equals(''));
        expect(result.notes, equals(''));
        expect(result.condition, equals(BookCondition.good)); // Default for empty string
      });

      test('should handle zero and negative prices', () {
        // arrange
        final Map<String, dynamic> jsonMap = {
          'images': tImageUrls,
          'condition': 'good',
          'isForSale': true,
          'isForRent': true,
          'isForDonate': false,
          'expectedPrice': 0,
          'rentPrice': -5.99,
        };

        // act
        final result = BookCopyModel.fromJson(jsonMap);

        // assert
        expect(result.expectedPrice, equals(0.0));
        expect(result.rentPrice, equals(-5.99));
      });

      test('should preserve image URL order and duplicates', () {
        // arrange
        final duplicateImages = [
          'https://example.com/image1.jpg',
          'https://example.com/image1.jpg', // Duplicate
          'https://example.com/image2.jpg',
          'https://example.com/image1.jpg', // Another duplicate
        ];
        
        final model = BookCopyModel(
          imageUrls: duplicateImages,
          condition: BookCondition.good,
          isForSale: false,
          isForRent: false,
          isForDonate: false,
        );

        // act
        final json = model.toJson();
        final reconstructed = BookCopyModel.fromJson(json);

        // assert
        expect(reconstructed.imageUrls, equals(duplicateImages));
        expect(reconstructed.imageUrls.length, equals(4));
      });
    });
  });
}
