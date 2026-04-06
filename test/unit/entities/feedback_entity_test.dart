import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/feedback/domain/entities/feedback.dart';

void main() {
  group('Feedback Entity', () {
    const tId = 'feedback_123';
    const tType = FeedbackType.bugReport;
    const tMessage = 'This is a bug report about the app crashing on startup.';
    final tCreatedAt = DateTime(2023, 5, 15, 10, 30);
    const tStatus = FeedbackStatus.pending;

    final tFeedback = Feedback(
      id: tId,
      type: tType,
      message: tMessage,
      createdAt: tCreatedAt,
      status: tStatus,
    );

    group('constructor', () {
      test('should create Feedback with all required fields', () {
        // act & assert
        expect(tFeedback.id, equals(tId));
        expect(tFeedback.type, equals(tType));
        expect(tFeedback.message, equals(tMessage));
        expect(tFeedback.createdAt, equals(tCreatedAt));
        expect(tFeedback.status, equals(tStatus));
      });
    });

    group('equality', () {
      test('should be equal when all properties are the same', () {
        // arrange
        final feedback1 = tFeedback;
        final feedback2 = Feedback(
          id: tId,
          type: tType,
          message: tMessage,
          createdAt: tCreatedAt,
          status: tStatus,
        );

        // assert
        expect(feedback1, equals(feedback2));
        expect(feedback1.hashCode, equals(feedback2.hashCode));
      });

      test('should not be equal when properties differ', () {
        // arrange
        final feedback1 = tFeedback;
        final feedback2 = tFeedback.copyWith(id: 'different_id');

        // assert
        expect(feedback1, isNot(equals(feedback2)));
        expect(feedback1.hashCode, isNot(equals(feedback2.hashCode)));
      });

      test('should not be equal when type differs', () {
        // arrange
        final feedback1 = tFeedback;
        final feedback2 = tFeedback.copyWith(type: FeedbackType.featureRequest);

        // assert
        expect(feedback1, isNot(equals(feedback2)));
      });

      test('should not be equal when message differs', () {
        // arrange
        final feedback1 = tFeedback;
        final feedback2 = tFeedback.copyWith(message: 'Different message');

        // assert
        expect(feedback1, isNot(equals(feedback2)));
      });

      test('should not be equal when createdAt differs', () {
        // arrange
        final feedback1 = tFeedback;
        final feedback2 = tFeedback.copyWith(createdAt: DateTime(2023, 6, 15));

        // assert
        expect(feedback1, isNot(equals(feedback2)));
      });

      test('should not be equal when status differs', () {
        // arrange
        final feedback1 = tFeedback;
        final feedback2 = tFeedback.copyWith(status: FeedbackStatus.resolved);

        // assert
        expect(feedback1, isNot(equals(feedback2)));
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        // arrange
        const newId = 'new_feedback_123';
        const newType = FeedbackType.featureRequest;
        const newMessage = 'Updated message';
        final newCreatedAt = DateTime(2023, 6, 15, 12, 45);
        const newStatus = FeedbackStatus.inReview;

        // act
        final result = tFeedback.copyWith(
          id: newId,
          type: newType,
          message: newMessage,
          createdAt: newCreatedAt,
          status: newStatus,
        );

        // assert
        expect(result.id, equals(newId));
        expect(result.type, equals(newType));
        expect(result.message, equals(newMessage));
        expect(result.createdAt, equals(newCreatedAt));
        expect(result.status, equals(newStatus));
      });

      test('should return same instance when no fields are updated', () {
        // act
        final result = tFeedback.copyWith();

        // assert
        expect(result, equals(tFeedback));
      });

      test('should preserve original values when null is passed', () {
        // act
        final result = tFeedback.copyWith(
          id: null,
          type: null,
          message: null,
          createdAt: null,
          status: null,
        );

        // assert
        expect(result.id, equals(tFeedback.id));
        expect(result.type, equals(tFeedback.type));
        expect(result.message, equals(tFeedback.message));
        expect(result.createdAt, equals(tFeedback.createdAt));
        expect(result.status, equals(tFeedback.status));
      });
    });

    group('props', () {
      test('should return correct list of properties', () {
        // act
        final props = tFeedback.props;

        // assert
        expect(props, equals([tId, tType, tMessage, tCreatedAt, tStatus]));
      });
    });

    group('edge cases', () {
      test('should handle empty message', () {
        // arrange
        final feedback = Feedback(
          id: tId,
          type: tType,
          message: '',
          createdAt: tCreatedAt,
          status: tStatus,
        );

        // assert
        expect(feedback.message, isEmpty);
        expect(feedback.id, equals(tId));
      });

      test('should handle very long message', () {
        // arrange
        final longMessage = 'A' * 10000; // 10k characters
        final feedback = Feedback(
          id: tId,
          type: tType,
          message: longMessage,
          createdAt: tCreatedAt,
          status: tStatus,
        );

        // assert
        expect(feedback.message, equals(longMessage));
        expect(feedback.message.length, equals(10000));
      });

      test('should handle special characters in message', () {
        // arrange
        const specialMessage = 'Message with special chars: àáâãäåæçèéêë & symbols !@#\$%^&*() 😀🎉';
        final feedback = Feedback(
          id: tId,
          type: tType,
          message: specialMessage,
          createdAt: tCreatedAt,
          status: tStatus,
        );

        // assert
        expect(feedback.message, equals(specialMessage));
      });

      test('should handle all feedback types', () {
        final types = FeedbackType.values;

        for (final type in types) {
          final feedback = Feedback(
            id: tId,
            type: type,
            message: tMessage,
            createdAt: tCreatedAt,
            status: tStatus,
          );

          expect(feedback.type, equals(type));
        }
      });

      test('should handle all feedback statuses', () {
        final statuses = FeedbackStatus.values;

        for (final status in statuses) {
          final feedback = Feedback(
            id: tId,
            type: tType,
            message: tMessage,
            createdAt: tCreatedAt,
            status: status,
          );

          expect(feedback.status, equals(status));
        }
      });
    });
  });

  group('FeedbackType Extension', () {
    group('displayName', () {
      test('should return correct display names for all types', () {
        final expectedDisplayNames = {
          FeedbackType.general: 'General Feedback',
          FeedbackType.bugReport: 'Bug Report',
          FeedbackType.featureRequest: 'Feature Request',
          FeedbackType.complaint: 'Complaint',
        };

        expectedDisplayNames.forEach((type, expectedName) {
          expect(type.displayName, equals(expectedName));
        });
      });
    });

    group('description', () {
      test('should return correct descriptions for all types', () {
        final expectedDescriptions = {
          FeedbackType.general: 'General comments and suggestions',
          FeedbackType.bugReport: 'Report technical issues or problems',
          FeedbackType.featureRequest: 'Suggest new features or improvements',
          FeedbackType.complaint: 'Report service or quality issues',
        };

        expectedDescriptions.forEach((type, expectedDescription) {
          expect(type.description, equals(expectedDescription));
        });
      });
    });

    group('completeness', () {
      test('should have display name and description for all enum values', () {
        // This test ensures no new enum values are added without proper extensions
        for (final type in FeedbackType.values) {
          expect(type.displayName, isNotEmpty);
          expect(type.description, isNotEmpty);
          expect(type.displayName, isNot(contains('Exception')));
          expect(type.description, isNot(contains('Exception')));
        }
      });
    });
  });
}
