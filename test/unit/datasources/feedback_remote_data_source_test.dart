import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_library/features/feedback/data/datasources/feedback_remote_data_source.dart';
import 'package:flutter_library/features/feedback/data/models/feedback_model.dart';
import 'package:flutter_library/features/feedback/domain/entities/feedback.dart';

class MockDio extends Mock implements Dio {}

void main() {
  group('FeedbackRemoteDataSourceImpl', () {
    late FeedbackRemoteDataSourceImpl dataSource;
    late MockDio mockDio;

    setUp(() {
      mockDio = MockDio();
      dataSource = FeedbackRemoteDataSourceImpl(dio: mockDio);
    });

    group('submitFeedback', () {
      test('should return FeedbackModel when submission is successful', () async {
        // Act
        final result = await dataSource.submitFeedback(
          type: FeedbackType.bugReport,
          message: 'Test feedback message',
        );

        // Assert
        expect(result, isA<FeedbackModel>());
        expect(result.type, equals(FeedbackType.bugReport));
        expect(result.message, equals('Test feedback message'));
        expect(result.status, equals(FeedbackStatus.pending));
        expect(result.id, isNotEmpty);
        expect(result.createdAt, isA<DateTime>());
      });

      test('should generate unique IDs for different submissions', () async {
        // Act
        final result1 = await dataSource.submitFeedback(
          type: FeedbackType.bugReport,
          message: 'First message',
        );
        
        // Add small delay to ensure different timestamps
        await Future.delayed(const Duration(milliseconds: 10));
        
        final result2 = await dataSource.submitFeedback(
          type: FeedbackType.featureRequest,
          message: 'Second message',
        );

        // Assert
        expect(result1.id, isNot(equals(result2.id)));
        expect(result1.message, equals('First message'));
        expect(result2.message, equals('Second message'));
        expect(result1.type, equals(FeedbackType.bugReport));
        expect(result2.type, equals(FeedbackType.featureRequest));
      });

      test('should handle different feedback types correctly', () async {
        // Test all feedback types
        for (final type in FeedbackType.values) {
          final result = await dataSource.submitFeedback(
            type: type,
            message: 'Test message for $type',
          );

          expect(result.type, equals(type));
          expect(result.message, equals('Test message for $type'));
          expect(result.status, equals(FeedbackStatus.pending));
        }
      });

      test('should handle empty message gracefully', () async {
        // Act
        final result = await dataSource.submitFeedback(
          type: FeedbackType.general,
          message: '',
        );

        // Assert
        expect(result, isA<FeedbackModel>());
        expect(result.message, equals(''));
        expect(result.type, equals(FeedbackType.general));
      });

      test('should handle very long message', () async {
        // Arrange
        final longMessage = 'a' * 10000;

        // Act
        final result = await dataSource.submitFeedback(
          type: FeedbackType.complaint,
          message: longMessage,
        );

        // Assert
        expect(result, isA<FeedbackModel>());
        expect(result.message, equals(longMessage));
        expect(result.type, equals(FeedbackType.complaint));
      });

      test('should have reasonable execution time', () async {
        // Act & Assert
        final stopwatch = Stopwatch()..start();
        
        await dataSource.submitFeedback(
          type: FeedbackType.bugReport,
          message: 'Test message',
        );
        
        stopwatch.stop();
        
        // Should complete within reasonable time (allowing for 2-second delay + overhead)
        expect(stopwatch.elapsedMilliseconds, lessThan(3000));
        expect(stopwatch.elapsedMilliseconds, greaterThan(1900)); // Should take at least 2 seconds due to delay
      });
    });

    group('getFeedbackHistory', () {
      test('should return list of FeedbackModel when request is successful', () async {
        // Act
        final result = await dataSource.getFeedbackHistory();

        // Assert
        expect(result, isA<List<FeedbackModel>>());
        expect(result.length, equals(3)); // Based on the mock implementation
        
        // Verify each item is a proper FeedbackModel
        for (final feedback in result) {
          expect(feedback, isA<FeedbackModel>());
          expect(feedback.id, isNotEmpty);
          expect(feedback.message, isNotEmpty);
          expect(feedback.type, isA<FeedbackType>());
          expect(feedback.status, isA<FeedbackStatus>());
          expect(feedback.createdAt, isA<DateTime>());
        }
      });

      test('should return feedback items with different types and statuses', () async {
        // Act
        final result = await dataSource.getFeedbackHistory();

        // Assert
        expect(result.length, greaterThan(0));
        
        // Check that we have different types and statuses
        final types = result.map((f) => f.type).toSet();
        final statuses = result.map((f) => f.status).toSet();
        
        expect(types.length, greaterThan(1)); // Should have multiple types
        expect(statuses.length, greaterThan(1)); // Should have multiple statuses
      });

      test('should return feedback items sorted by creation date (newest first)', () async {
        // Act
        final result = await dataSource.getFeedbackHistory();

        // Assert
        expect(result.length, greaterThan(1));
        
        // Check if sorted by creation date (newest first)
        for (int i = 0; i < result.length - 1; i++) {
          expect(
            result[i].createdAt.isAfter(result[i + 1].createdAt) || 
            result[i].createdAt.isAtSameMomentAs(result[i + 1].createdAt),
            isTrue,
            reason: 'Feedback history should be sorted by creation date (newest first)',
          );
        }
      });

      test('should have reasonable execution time', () async {
        // Act & Assert
        final stopwatch = Stopwatch()..start();
        
        await dataSource.getFeedbackHistory();
        
        stopwatch.stop();
        
        // Should complete within reasonable time (allowing for 1-second delay + overhead)
        expect(stopwatch.elapsedMilliseconds, lessThan(2000));
        expect(stopwatch.elapsedMilliseconds, greaterThan(900)); // Should take at least 1 second due to delay
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle special characters in feedback message', () async {
        // Arrange
        const specialMessage = 'Test with special chars: !@#\$%^&*()[]{}|;:,.<>?';

        // Act
        final result = await dataSource.submitFeedback(
          type: FeedbackType.general,
          message: specialMessage,
        );

        // Assert
        expect(result.message, equals(specialMessage));
      });

      test('should handle unicode characters in feedback message', () async {
        // Arrange
        const unicodeMessage = 'Test with unicode: 🚀 👍 🎉 中文 العربية';

        // Act
        final result = await dataSource.submitFeedback(
          type: FeedbackType.general,
          message: unicodeMessage,
        );

        // Assert
        expect(result.message, equals(unicodeMessage));
      });

      test('should handle newlines and tabs in feedback message', () async {
        // Arrange
        const multilineMessage = 'Line 1\nLine 2\tTabbed\rCarriage return';

        // Act
        final result = await dataSource.submitFeedback(
          type: FeedbackType.general,
          message: multilineMessage,
        );

        // Assert
        expect(result.message, equals(multilineMessage));
      });
    });
  });
}
