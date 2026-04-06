import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/feedback/data/models/feedback_model.dart';
import 'package:flutter_library/features/feedback/domain/entities/feedback.dart';

void main() {
  group('FeedbackModel', () {
    final testDateTime = DateTime(2024, 1, 15, 10, 30, 0);
    
    final testFeedbackModel = FeedbackModel(
      id: '1',
      type: FeedbackType.bugReport,
      message: 'Test feedback message',
      createdAt: testDateTime,
      status: FeedbackStatus.pending,
    );

    final testJson = {
      'id': '1',
      'type': 'bugReport',
      'message': 'Test feedback message',
      'createdAt': '2024-01-15T10:30:00.000',
      'status': 'pending',
    };

    group('Entity Extension', () {
      test('should be a subclass of Feedback entity', () {
        expect(testFeedbackModel, isA<Feedback>());
      });

      test('should have correct properties from parent entity', () {
        expect(testFeedbackModel.id, equals('1'));
        expect(testFeedbackModel.type, equals(FeedbackType.bugReport));
        expect(testFeedbackModel.message, equals('Test feedback message'));
        expect(testFeedbackModel.createdAt, equals(testDateTime));
        expect(testFeedbackModel.status, equals(FeedbackStatus.pending));
      });
    });

    group('fromJson', () {
      test('should return a valid FeedbackModel from JSON', () {
        // Act
        final result = FeedbackModel.fromJson(testJson);

        // Assert
        expect(result, isA<FeedbackModel>());
        expect(result.id, equals('1'));
        expect(result.type, equals(FeedbackType.bugReport));
        expect(result.message, equals('Test feedback message'));
        expect(result.createdAt, equals(testDateTime));
        expect(result.status, equals(FeedbackStatus.pending));
      });

      test('should handle all FeedbackType values correctly', () {
        for (final type in FeedbackType.values) {
          final json = {
            'id': '1',
            'type': type.toString().split('.').last,
            'message': 'Test message',
            'createdAt': '2024-01-15T10:30:00.000',
            'status': 'pending',
          };

          final result = FeedbackModel.fromJson(json);

          expect(result.type, equals(type));
        }
      });

      test('should handle all FeedbackStatus values correctly', () {
        for (final status in FeedbackStatus.values) {
          final json = {
            'id': '1',
            'type': 'general',
            'message': 'Test message',
            'createdAt': '2024-01-15T10:30:00.000',
            'status': status.toString().split('.').last,
          };

          final result = FeedbackModel.fromJson(json);

          expect(result.status, equals(status));
        }
      });

      test('should default to general type for unknown feedback type', () {
        // Arrange
        final jsonWithUnknownType = {
          'id': '1',
          'type': 'unknownType',
          'message': 'Test message',
          'createdAt': '2024-01-15T10:30:00.000',
          'status': 'pending',
        };

        // Act
        final result = FeedbackModel.fromJson(jsonWithUnknownType);

        // Assert
        expect(result.type, equals(FeedbackType.general));
      });

      test('should default to pending status for unknown status', () {
        // Arrange
        final jsonWithUnknownStatus = {
          'id': '1',
          'type': 'general',
          'message': 'Test message',
          'createdAt': '2024-01-15T10:30:00.000',
          'status': 'unknownStatus',
        };

        // Act
        final result = FeedbackModel.fromJson(jsonWithUnknownStatus);

        // Assert
        expect(result.status, equals(FeedbackStatus.pending));
      });

      test('should handle different datetime formats', () {
        // Arrange
        final jsonWithDifferentDate = {
          'id': '1',
          'type': 'general',
          'message': 'Test message',
          'createdAt': '2024-01-15T10:30:00.123Z',
          'status': 'pending',
        };

        // Act
        final result = FeedbackModel.fromJson(jsonWithDifferentDate);

        // Assert
        expect(result.createdAt, isA<DateTime>());
        expect(result.createdAt.year, equals(2024));
        expect(result.createdAt.month, equals(1));
        expect(result.createdAt.day, equals(15));
      });

      test('should handle empty and special characters in message', () {
        // Test empty message
        final jsonEmpty = {
          'id': '1',
          'type': 'general',
          'message': '',
          'createdAt': '2024-01-15T10:30:00.000',
          'status': 'pending',
        };

        final resultEmpty = FeedbackModel.fromJson(jsonEmpty);
        expect(resultEmpty.message, equals(''));

        // Test special characters
        final jsonSpecial = {
          'id': '1',
          'type': 'general',
          'message': 'Test with special chars: !@#\$%^&*()[]{}|;:,.<>?',
          'createdAt': '2024-01-15T10:30:00.000',
          'status': 'pending',
        };

        final resultSpecial = FeedbackModel.fromJson(jsonSpecial);
        expect(resultSpecial.message, equals('Test with special chars: !@#\$%^&*()[]{}|;:,.<>?'));
      });

      test('should handle unicode characters in message', () {
        // Arrange
        final jsonWithUnicode = {
          'id': '1',
          'type': 'general',
          'message': 'Test with unicode: 🚀 👍 🎉 中文 العربية',
          'createdAt': '2024-01-15T10:30:00.000',
          'status': 'pending',
        };

        // Act
        final result = FeedbackModel.fromJson(jsonWithUnicode);

        // Assert
        expect(result.message, equals('Test with unicode: 🚀 👍 🎉 中文 العربية'));
      });
    });

    group('toJson', () {
      test('should return a valid JSON map', () {
        // Act
        final result = testFeedbackModel.toJson();

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['id'], equals('1'));
        expect(result['type'], equals('bugReport'));
        expect(result['message'], equals('Test feedback message'));
        expect(result['createdAt'], equals('2024-01-15T10:30:00.000'));
        expect(result['status'], equals('pending'));
      });

      test('should convert all FeedbackType values correctly', () {
        for (final type in FeedbackType.values) {
          final model = testFeedbackModel.copyWith(type: type);
          final json = model.toJson();

          expect(json['type'], equals(type.toString().split('.').last));
        }
      });

      test('should convert all FeedbackStatus values correctly', () {
        for (final status in FeedbackStatus.values) {
          final model = testFeedbackModel.copyWith(status: status);
          final json = model.toJson();

          expect(json['status'], equals(status.toString().split('.').last));
        }
      });

      test('should handle special characters and unicode in message', () {
        // Special characters
        final modelWithSpecial = testFeedbackModel.copyWith(
          message: 'Special chars: !@#\$%^&*()[]{}|;:,.<>?',
        );
        final jsonSpecial = modelWithSpecial.toJson();
        expect(jsonSpecial['message'], equals('Special chars: !@#\$%^&*()[]{}|;:,.<>?'));

        // Unicode characters
        final modelWithUnicode = testFeedbackModel.copyWith(
          message: 'Unicode: 🚀 👍 🎉 中文 العربية',
        );
        final jsonUnicode = modelWithUnicode.toJson();
        expect(jsonUnicode['message'], equals('Unicode: 🚀 👍 🎉 中文 العربية'));
      });

      test('should handle empty message', () {
        // Arrange
        final modelWithEmptyMessage = testFeedbackModel.copyWith(message: '');

        // Act
        final result = modelWithEmptyMessage.toJson();

        // Assert
        expect(result['message'], equals(''));
      });

      test('should format datetime to ISO8601 string', () {
        // Arrange
        final specificDateTime = DateTime(2024, 12, 25, 15, 45, 30, 123);
        final model = testFeedbackModel.copyWith(createdAt: specificDateTime);

        // Act
        final result = model.toJson();

        // Assert
        expect(result['createdAt'], equals('2024-12-25T15:45:30.123'));
      });
    });

    group('copyWith', () {
      test('should return FeedbackModel with updated values', () {
        // Act
        final result = testFeedbackModel.copyWith(
          id: '2',
          type: FeedbackType.featureRequest,
          message: 'Updated message',
          status: FeedbackStatus.resolved,
        );

        // Assert
        expect(result, isA<FeedbackModel>());
        expect(result.id, equals('2'));
        expect(result.type, equals(FeedbackType.featureRequest));
        expect(result.message, equals('Updated message'));
        expect(result.status, equals(FeedbackStatus.resolved));
        expect(result.createdAt, equals(testDateTime)); // Should remain unchanged
      });

      test('should return FeedbackModel with original values when no parameters provided', () {
        // Act
        final result = testFeedbackModel.copyWith();

        // Assert
        expect(result, isA<FeedbackModel>());
        expect(result.id, equals(testFeedbackModel.id));
        expect(result.type, equals(testFeedbackModel.type));
        expect(result.message, equals(testFeedbackModel.message));
        expect(result.createdAt, equals(testFeedbackModel.createdAt));
        expect(result.status, equals(testFeedbackModel.status));
      });

      test('should update only specified values', () {
        // Act
        final result = testFeedbackModel.copyWith(message: 'Only message updated');

        // Assert
        expect(result.message, equals('Only message updated'));
        expect(result.id, equals(testFeedbackModel.id));
        expect(result.type, equals(testFeedbackModel.type));
        expect(result.createdAt, equals(testFeedbackModel.createdAt));
        expect(result.status, equals(testFeedbackModel.status));
      });
    });

    group('JSON Serialization Round Trip', () {
      test('should maintain data integrity through fromJson -> toJson cycle', () {
        // Act
        final json = testFeedbackModel.toJson();
        final fromJson = FeedbackModel.fromJson(json);
        final backToJson = fromJson.toJson();

        // Assert
        expect(fromJson.id, equals(testFeedbackModel.id));
        expect(fromJson.type, equals(testFeedbackModel.type));
        expect(fromJson.message, equals(testFeedbackModel.message));
        expect(fromJson.createdAt, equals(testFeedbackModel.createdAt));
        expect(fromJson.status, equals(testFeedbackModel.status));
        expect(backToJson, equals(json));
      });

      test('should handle all enum values in round trip', () {
        for (final type in FeedbackType.values) {
          for (final status in FeedbackStatus.values) {
            final model = FeedbackModel(
              id: 'test',
              type: type,
              message: 'Test message',
              createdAt: testDateTime,
              status: status,
            );

            final json = model.toJson();
            final fromJson = FeedbackModel.fromJson(json);

            expect(fromJson.type, equals(type));
            expect(fromJson.status, equals(status));
          }
        }
      });
    });

    group('Equality and Props', () {
      test('should be equal when all properties are the same', () {
        // Arrange
        final anotherModel = FeedbackModel(
          id: '1',
          type: FeedbackType.bugReport,
          message: 'Test feedback message',
          createdAt: testDateTime,
          status: FeedbackStatus.pending,
        );

        // Assert
        expect(testFeedbackModel, equals(anotherModel));
        expect(testFeedbackModel.hashCode, equals(anotherModel.hashCode));
      });

      test('should not be equal when properties differ', () {
        // Arrange
        final differentModel = testFeedbackModel.copyWith(id: '2');

        // Assert
        expect(testFeedbackModel, isNot(equals(differentModel)));
        expect(testFeedbackModel.hashCode, isNot(equals(differentModel.hashCode)));
      });
    });
  });
}
