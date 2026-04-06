import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_library/features/feedback/domain/usecases/submit_feedback_usecase.dart';
import 'package:flutter_library/features/feedback/domain/usecases/get_feedback_history_usecase.dart';
import 'package:flutter_library/features/feedback/domain/repositories/feedback_repository.dart';
import 'package:flutter_library/features/feedback/domain/entities/feedback.dart';
import 'package:flutter_library/core/error/failures.dart';

class MockFeedbackRepository extends Mock implements FeedbackRepository {}

void main() {
  group('Feedback Use Cases Tests', () {
    late MockFeedbackRepository mockRepository;
    late SubmitFeedbackUseCase submitFeedbackUseCase;
    late GetFeedbackHistoryUseCase getFeedbackHistoryUseCase;

    setUpAll(() {
      registerFallbackValue(FeedbackType.featureRequest);
    });

    setUp(() {
      mockRepository = MockFeedbackRepository();
      submitFeedbackUseCase = SubmitFeedbackUseCase(repository: mockRepository);
      getFeedbackHistoryUseCase = GetFeedbackHistoryUseCase(repository: mockRepository);
    });

    final mockFeedback = Feedback(
      id: '1',
      type: FeedbackType.featureRequest,
      message: 'This is a test feedback message',
      status: FeedbackStatus.pending,
      createdAt: DateTime.now(),
    );

    final mockFeedbackList = [
      mockFeedback,
      Feedback(
        id: '2',
        type: FeedbackType.bugReport,
        message: 'Found a bug in the app',
        status: FeedbackStatus.inReview,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Feedback(
        id: '3',
        type: FeedbackType.complaint,
        message: 'App is running slowly',
        status: FeedbackStatus.resolved,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];

    group('SubmitFeedbackUseCase', () {
      test('should return Feedback when submission is successful', () async {
        // arrange
        when(() => mockRepository.submitFeedback(
              type: FeedbackType.featureRequest,
              message: 'This is a test feedback message',
            )).thenAnswer((_) async => Right(mockFeedback));

        // act
        final result = await submitFeedbackUseCase(
          type: FeedbackType.featureRequest,
          message: 'This is a test feedback message',
        );

        // assert
        expect(result, equals(Right(mockFeedback)));
        verify(() => mockRepository.submitFeedback(
              type: FeedbackType.featureRequest,
              message: 'This is a test feedback message',
            )).called(1);
      });

      test('should return ValidationFailure when message is empty', () async {
        // act
        final result = await submitFeedbackUseCase(
          type: FeedbackType.featureRequest,
          message: '',
        );

        // assert
        expect(result, equals(const Left(ValidationFailure('Feedback message cannot be empty'))));
        verifyNever(() => mockRepository.submitFeedback(
              type: any(named: 'type'),
              message: any(named: 'message'),
            ));
      });

      test('should return ValidationFailure when message is only whitespace', () async {
        // act
        final result = await submitFeedbackUseCase(
          type: FeedbackType.featureRequest,
          message: '   ',
        );

        // assert
        expect(result, equals(const Left(ValidationFailure('Feedback message cannot be empty'))));
        verifyNever(() => mockRepository.submitFeedback(
              type: any(named: 'type'),
              message: any(named: 'message'),
            ));
      });

      test('should return ValidationFailure when message is too short', () async {
        // act
        final result = await submitFeedbackUseCase(
          type: FeedbackType.featureRequest,
          message: 'Too short',
        );

        // assert
        expect(result, equals(const Left(ValidationFailure('Please provide more detailed feedback (at least 10 characters)'))));
        verifyNever(() => mockRepository.submitFeedback(
              type: any(named: 'type'),
              message: any(named: 'message'),
            ));
      });

      test('should trim whitespace from message before submission', () async {
        // arrange
        const messageWithWhitespace = '  This is a test feedback message  ';
        const trimmedMessage = 'This is a test feedback message';
        
        when(() => mockRepository.submitFeedback(
              type: FeedbackType.featureRequest,
              message: trimmedMessage,
            )).thenAnswer((_) async => Right(mockFeedback));

        // act
        final result = await submitFeedbackUseCase(
          type: FeedbackType.featureRequest,
          message: messageWithWhitespace,
        );

        // assert
        expect(result, equals(Right(mockFeedback)));
        verify(() => mockRepository.submitFeedback(
              type: FeedbackType.featureRequest,
              message: trimmedMessage,
            )).called(1);
      });

      test('should accept minimum valid message length', () async {
        // arrange
        const minValidMessage = '1234567890'; // exactly 10 characters
        
        when(() => mockRepository.submitFeedback(
              type: FeedbackType.featureRequest,
              message: minValidMessage,
            )).thenAnswer((_) async => Right(mockFeedback));

        // act
        final result = await submitFeedbackUseCase(
          type: FeedbackType.featureRequest,
          message: minValidMessage,
        );

        // assert
        expect(result, equals(Right(mockFeedback)));
        verify(() => mockRepository.submitFeedback(
              type: FeedbackType.featureRequest,
              message: minValidMessage,
            )).called(1);
      });

      test('should handle different feedback types correctly', () async {
        final feedbackTypes = [
          FeedbackType.general,
          FeedbackType.bugReport,
          FeedbackType.featureRequest,
          FeedbackType.complaint,
        ];

        for (final feedbackType in feedbackTypes) {
          final feedback = Feedback(
            id: '${feedbackType.index}',
            type: feedbackType,
            message: 'Test message for ${feedbackType.name}',
            status: FeedbackStatus.pending,
            createdAt: DateTime.now(),
          );

          when(() => mockRepository.submitFeedback(
                type: feedbackType,
                message: 'Test message for ${feedbackType.name}',
              )).thenAnswer((_) async => Right(feedback));

          // act
          final result = await submitFeedbackUseCase(
            type: feedbackType,
            message: 'Test message for ${feedbackType.name}',
          );

          // assert
          expect(result, equals(Right(feedback)));
        }
      });

      test('should return ServerFailure when repository submission fails', () async {
        // arrange
        when(() => mockRepository.submitFeedback(
              type: any(named: 'type'),
              message: any(named: 'message'),
            )).thenAnswer((_) async => const Left(ServerFailure()));

        // act
        final result = await submitFeedbackUseCase(
          type: FeedbackType.featureRequest,
          message: 'This is a test feedback message',
        );

        // assert
        expect(result, equals(const Left(ServerFailure())));
        verify(() => mockRepository.submitFeedback(
              type: FeedbackType.featureRequest,
              message: 'This is a test feedback message',
            )).called(1);
      });

      test('should return NetworkFailure when network error occurs', () async {
        // arrange
        when(() => mockRepository.submitFeedback(
              type: any(named: 'type'),
              message: any(named: 'message'),
            )).thenAnswer((_) async => const Left(NetworkFailure()));

        // act
        final result = await submitFeedbackUseCase(
          type: FeedbackType.featureRequest,
          message: 'This is a test feedback message',
        );

        // assert
        expect(result, equals(const Left(NetworkFailure())));
        verify(() => mockRepository.submitFeedback(
              type: FeedbackType.featureRequest,
              message: 'This is a test feedback message',
            )).called(1);
      });

      test('should handle long messages correctly', () async {
        // arrange
        final longMessage = 'A' * 1000; // Very long message
        final longFeedback = Feedback(
          id: '1',
          type: FeedbackType.featureRequest,
          message: longMessage,
          status: FeedbackStatus.pending,
          createdAt: DateTime.now(),
        );
        
        when(() => mockRepository.submitFeedback(
              type: FeedbackType.featureRequest,
              message: longMessage,
            )).thenAnswer((_) async => Right(longFeedback));

        // act
        final result = await submitFeedbackUseCase(
          type: FeedbackType.featureRequest,
          message: longMessage,
        );

        // assert
        expect(result, equals(Right(longFeedback)));
        verify(() => mockRepository.submitFeedback(
              type: FeedbackType.featureRequest,
              message: longMessage,
            )).called(1);
      });

      test('should handle special characters in message', () async {
        // arrange
        const specialMessage = 'Test with special chars: éñáíóú, 中文, العربية, русский! @#\$%^&*()';
        final specialFeedback = Feedback(
          id: '1',
          type: FeedbackType.featureRequest,
          message: specialMessage,
          status: FeedbackStatus.pending,
          createdAt: DateTime.now(),
        );
        
        when(() => mockRepository.submitFeedback(
              type: FeedbackType.featureRequest,
              message: specialMessage,
            )).thenAnswer((_) async => Right(specialFeedback));

        // act
        final result = await submitFeedbackUseCase(
          type: FeedbackType.featureRequest,
          message: specialMessage,
        );

        // assert
        expect(result, equals(Right(specialFeedback)));
        verify(() => mockRepository.submitFeedback(
              type: FeedbackType.featureRequest,
              message: specialMessage,
            )).called(1);
      });
    });

    group('GetFeedbackHistoryUseCase', () {
      test('should return list of Feedback when repository call is successful', () async {
        // arrange
        when(() => mockRepository.getFeedbackHistory())
            .thenAnswer((_) async => Right(mockFeedbackList));

        // act
        final result = await getFeedbackHistoryUseCase();

        // assert
        expect(result, equals(Right(mockFeedbackList)));
        verify(() => mockRepository.getFeedbackHistory()).called(1);
      });

      test('should return empty list when no feedback history exists', () async {
        // arrange
        when(() => mockRepository.getFeedbackHistory())
            .thenAnswer((_) async => const Right([]));

        // act
        final result = await getFeedbackHistoryUseCase();

        // assert
        expect(result, equals(const Right(<Feedback>[])));
        verify(() => mockRepository.getFeedbackHistory()).called(1);
      });

      test('should return ServerFailure when repository call fails', () async {
        // arrange
        when(() => mockRepository.getFeedbackHistory())
            .thenAnswer((_) async => const Left(ServerFailure()));

        // act
        final result = await getFeedbackHistoryUseCase();

        // assert
        expect(result, equals(const Left(ServerFailure())));
        verify(() => mockRepository.getFeedbackHistory()).called(1);
      });

      test('should return NetworkFailure when network error occurs', () async {
        // arrange
        when(() => mockRepository.getFeedbackHistory())
            .thenAnswer((_) async => const Left(NetworkFailure()));

        // act
        final result = await getFeedbackHistoryUseCase();

        // assert
        expect(result, equals(const Left(NetworkFailure())));
        verify(() => mockRepository.getFeedbackHistory()).called(1);
      });

      test('should return CacheFailure when cache error occurs', () async {
        // arrange
        when(() => mockRepository.getFeedbackHistory())
            .thenAnswer((_) async => const Left(CacheFailure('Cache error')));

        // act
        final result = await getFeedbackHistoryUseCase();

        // assert
        expect(result, isA<Left<Failure, List<Feedback>>>());
        final failure = (result as Left).value;
        expect(failure, isA<CacheFailure>());
        verify(() => mockRepository.getFeedbackHistory()).called(1);
      });

      test('should handle large feedback history correctly', () async {
        // arrange
        final largeFeedbackList = List.generate(100, (index) => Feedback(
          id: index.toString(),
          type: FeedbackType.values[index % FeedbackType.values.length],
          message: 'Feedback message number $index',
          status: FeedbackStatus.values[index % FeedbackStatus.values.length],
          createdAt: DateTime.now().subtract(Duration(days: index)),
        ));
        
        when(() => mockRepository.getFeedbackHistory())
            .thenAnswer((_) async => Right(largeFeedbackList));

        // act
        final result = await getFeedbackHistoryUseCase();

        // assert
        expect(result, equals(Right(largeFeedbackList)));
        expect((result as Right).value.length, equals(100));
        verify(() => mockRepository.getFeedbackHistory()).called(1);
      });

      test('should handle feedback with different statuses correctly', () async {
        // arrange
        final feedbackWithDifferentStatuses = [
          Feedback(
            id: '1',
            type: FeedbackType.bugReport,
            message: 'Bug report',
            status: FeedbackStatus.pending,
            createdAt: DateTime.now(),
          ),
          Feedback(
            id: '2',
            type: FeedbackType.featureRequest,
            message: 'Feature suggestion',
            status: FeedbackStatus.inReview,
            createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          Feedback(
            id: '3',
            type: FeedbackType.complaint,
            message: 'Performance issue',
            status: FeedbackStatus.resolved,
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ];
        
        when(() => mockRepository.getFeedbackHistory())
            .thenAnswer((_) async => Right(feedbackWithDifferentStatuses));

        // act
        final result = await getFeedbackHistoryUseCase();

        // assert
        expect(result, equals(Right(feedbackWithDifferentStatuses)));
        
        if (result.isRight()) {
          final feedbacks = result.getOrElse(() => []);
          expect(feedbacks[0].status, equals(FeedbackStatus.pending));
          expect(feedbacks[1].status, equals(FeedbackStatus.inReview));
          expect(feedbacks[2].status, equals(FeedbackStatus.resolved));
        }
        
        verify(() => mockRepository.getFeedbackHistory()).called(1);
      });
    });

    group('Integration scenarios', () {
      test('should handle submit followed by get history workflow', () async {
        // arrange
        when(() => mockRepository.submitFeedback(
              type: FeedbackType.featureRequest,
              message: 'New feedback message',
            )).thenAnswer((_) async => Right(mockFeedback));
        
        final updatedFeedbackList = [...mockFeedbackList, mockFeedback];
        when(() => mockRepository.getFeedbackHistory())
            .thenAnswer((_) async => Right(updatedFeedbackList));

        // act
        final submitResult = await submitFeedbackUseCase(
          type: FeedbackType.featureRequest,
          message: 'New feedback message',
        );
        final historyResult = await getFeedbackHistoryUseCase();

        // assert
        expect(submitResult, equals(Right(mockFeedback)));
        expect(historyResult, equals(Right(updatedFeedbackList)));
        verify(() => mockRepository.submitFeedback(
              type: FeedbackType.featureRequest,
              message: 'New feedback message',
            )).called(1);
        verify(() => mockRepository.getFeedbackHistory()).called(1);
      });

      test('should handle multiple concurrent feedback submissions', () async {
        // arrange
        final feedback1 = Feedback(
          id: '1',
          type: FeedbackType.bugReport,
          message: 'Bug report 1',
          status: FeedbackStatus.pending,
          createdAt: DateTime.now(),
        );
        final feedback2 = Feedback(
          id: '2',
          type: FeedbackType.featureRequest,
          message: 'Feature request 1',
          status: FeedbackStatus.pending,
          createdAt: DateTime.now(),
        );

        when(() => mockRepository.submitFeedback(
              type: FeedbackType.bugReport,
              message: 'Bug report 1',
            )).thenAnswer((_) async => Right(feedback1));
        
        when(() => mockRepository.submitFeedback(
              type: FeedbackType.featureRequest,
              message: 'Feature request 1',
            )).thenAnswer((_) async => Right(feedback2));

        // act
        final futures = await Future.wait([
          submitFeedbackUseCase(
            type: FeedbackType.bugReport,
            message: 'Bug report 1',
          ),
          submitFeedbackUseCase(
            type: FeedbackType.featureRequest,
            message: 'Feature request 1',
          ),
        ]);

        // assert
        expect(futures.length, equals(2));
        expect(futures[0], equals(Right(feedback1)));
        expect(futures[1], equals(Right(feedback2)));
      });
    });
  });
}
