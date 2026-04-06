import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_library/features/feedback/presentation/bloc/feedback_bloc.dart';
import 'package:flutter_library/features/feedback/presentation/bloc/feedback_event.dart';
import 'package:flutter_library/features/feedback/presentation/bloc/feedback_state.dart';
import 'package:flutter_library/features/feedback/domain/usecases/submit_feedback_usecase.dart';
import 'package:flutter_library/features/feedback/domain/usecases/get_feedback_history_usecase.dart';
import 'package:flutter_library/features/feedback/domain/entities/feedback.dart';
import 'package:flutter_library/core/error/failures.dart';

class MockSubmitFeedbackUseCase extends Mock implements SubmitFeedbackUseCase {}
class MockGetFeedbackHistoryUseCase extends Mock implements GetFeedbackHistoryUseCase {}

void main() {
  group('FeedbackBloc Tests', () {
    late FeedbackBloc feedbackBloc;
    late MockSubmitFeedbackUseCase mockSubmitFeedbackUseCase;
    late MockGetFeedbackHistoryUseCase mockGetFeedbackHistoryUseCase;

    setUp(() {
      mockSubmitFeedbackUseCase = MockSubmitFeedbackUseCase();
      mockGetFeedbackHistoryUseCase = MockGetFeedbackHistoryUseCase();
      
      feedbackBloc = FeedbackBloc(
        submitFeedbackUseCase: mockSubmitFeedbackUseCase,
        getFeedbackHistoryUseCase: mockGetFeedbackHistoryUseCase,
      );
    });

    tearDown(() {
      feedbackBloc.close();
    });

    final mockFeedback = Feedback(
      id: '1',
      type: FeedbackType.featureRequest,
      message: 'Great app! Could use more features.',
      createdAt: DateTime.now(),
      status: FeedbackStatus.pending,
    );

    final mockFeedbackList = [
      mockFeedback,
      Feedback(
        id: '2',
        type: FeedbackType.bugReport,
        message: 'App crashes on startup',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        status: FeedbackStatus.inReview,
      ),
    ];

    test('initial state should be FeedbackInitial', () {
      expect(feedbackBloc.state, const FeedbackInitial());
    });

    group('SubmitFeedback', () {
      blocTest<FeedbackBloc, FeedbackState>(
        'emits [FeedbackLoading, FeedbackSubmitted] when feedback is submitted successfully',
        build: () {
          when(() => mockSubmitFeedbackUseCase(
                type: FeedbackType.featureRequest,
                message: 'Great app! Could use more features.',
              )).thenAnswer((_) async => Right(mockFeedback));
          return feedbackBloc;
        },
        act: (bloc) => bloc.add(const SubmitFeedback(
          type: FeedbackType.featureRequest,
          message: 'Great app! Could use more features.',
        )),
        expect: () => [
          const FeedbackLoading(),
          FeedbackSubmitted(feedback: mockFeedback),
        ],
      );

      blocTest<FeedbackBloc, FeedbackState>(
        'emits [FeedbackLoading, FeedbackError] when submitting feedback fails',
        build: () {
          when(() => mockSubmitFeedbackUseCase(
                type: FeedbackType.bugReport,
                message: 'App crashes',
              )).thenAnswer((_) async => const Left(ServerFailure()));
          return feedbackBloc;
        },
        act: (bloc) => bloc.add(const SubmitFeedback(
          type: FeedbackType.bugReport,
          message: 'App crashes',
        )),
        expect: () => [
          const FeedbackLoading(),
          const FeedbackError(message: 'Server error occurred'),
        ],
      );

      blocTest<FeedbackBloc, FeedbackState>(
        'emits [FeedbackLoading, FeedbackError] when submitting with validation error',
        build: () {
          when(() => mockSubmitFeedbackUseCase(
                type: FeedbackType.general,
                message: '',
              )).thenAnswer((_) async => const Left(ValidationFailure('Message cannot be empty')));
          return feedbackBloc;
        },
        act: (bloc) => bloc.add(const SubmitFeedback(
          type: FeedbackType.general,
          message: '',
        )),
        expect: () => [
          const FeedbackLoading(),
          const FeedbackError(message: 'Message cannot be empty'),
        ],
      );
    });

    group('GetFeedbackHistory', () {
      blocTest<FeedbackBloc, FeedbackState>(
        'emits [FeedbackLoading, FeedbackHistoryLoaded] when history is loaded successfully',
        build: () {
          when(() => mockGetFeedbackHistoryUseCase())
              .thenAnswer((_) async => Right(mockFeedbackList));
          return feedbackBloc;
        },
        act: (bloc) => bloc.add(const GetFeedbackHistory()),
        expect: () => [
          const FeedbackLoading(),
          FeedbackHistoryLoaded(feedbackList: mockFeedbackList),
        ],
      );

      blocTest<FeedbackBloc, FeedbackState>(
        'emits [FeedbackLoading, FeedbackError] when loading history fails',
        build: () {
          when(() => mockGetFeedbackHistoryUseCase())
              .thenAnswer((_) async => const Left(NetworkFailure()));
          return feedbackBloc;
        },
        act: (bloc) => bloc.add(const GetFeedbackHistory()),
        expect: () => [
          const FeedbackLoading(),
          const FeedbackError(message: 'No internet connection'),
        ],
      );

      blocTest<FeedbackBloc, FeedbackState>(
        'emits [FeedbackLoading, FeedbackHistoryLoaded] with empty list when no history exists',
        build: () {
          when(() => mockGetFeedbackHistoryUseCase())
              .thenAnswer((_) async => const Right([]));
          return feedbackBloc;
        },
        act: (bloc) => bloc.add(const GetFeedbackHistory()),
        expect: () => [
          const FeedbackLoading(),
          const FeedbackHistoryLoaded(feedbackList: []),
        ],
      );
    });

    group('ResetFeedbackState', () {
      blocTest<FeedbackBloc, FeedbackState>(
        'emits [FeedbackInitial] when state is reset',
        build: () => feedbackBloc,
        seed: () => FeedbackSubmitted(feedback: mockFeedback),
        act: (bloc) => bloc.add(const ResetFeedbackState()),
        expect: () => [
          const FeedbackInitial(),
        ],
      );

      blocTest<FeedbackBloc, FeedbackState>(
        'emits [FeedbackInitial] when resetting from error state',
        build: () => feedbackBloc,
        seed: () => const FeedbackError(message: 'Some error'),
        act: (bloc) => bloc.add(const ResetFeedbackState()),
        expect: () => [
          const FeedbackInitial(),
        ],
      );
    });

    group('Error handling edge cases', () {
      blocTest<FeedbackBloc, FeedbackState>(
        'handles cache failure gracefully',
        build: () {
          when(() => mockGetFeedbackHistoryUseCase())
              .thenAnswer((_) async => const Left(CacheFailure('Cache error')));
          return feedbackBloc;
        },
        act: (bloc) => bloc.add(const GetFeedbackHistory()),
        expect: () => [
          const FeedbackLoading(),
          const FeedbackError(message: 'Cache error'),
        ],
      );

      blocTest<FeedbackBloc, FeedbackState>(
        'handles server failure when submitting',
        build: () {
          when(() => mockSubmitFeedbackUseCase(
                type: FeedbackType.bugReport,
                message: 'Bug report',
              )).thenAnswer((_) async => const Left(ServerFailure()));
          return feedbackBloc;
        },
        act: (bloc) => bloc.add(const SubmitFeedback(
          type: FeedbackType.bugReport,
          message: 'Bug report',
        )),
        expect: () => [
          const FeedbackLoading(),
          const FeedbackError(message: 'Server error occurred'),
        ],
      );
    });

    group('Feedback types handling', () {
      blocTest<FeedbackBloc, FeedbackState>(
        'handles different feedback types correctly',
        build: () {
          when(() => mockSubmitFeedbackUseCase(
                type: FeedbackType.complaint,
                message: 'Service is slow',
              )).thenAnswer((_) async => Right(
                Feedback(
                  id: '3',
                  type: FeedbackType.complaint,
                  message: 'Service is slow',
                  createdAt: DateTime.now(),
                  status: FeedbackStatus.pending,
                )
              ));
          return feedbackBloc;
        },
        act: (bloc) => bloc.add(const SubmitFeedback(
          type: FeedbackType.complaint,
          message: 'Service is slow',
        )),
        verify: (bloc) {
          final state = bloc.state;
          if (state is FeedbackSubmitted) {
            expect(state.feedback.type, FeedbackType.complaint);
            expect(state.feedback.message, 'Service is slow');
            expect(state.feedback.status, FeedbackStatus.pending);
          }
        },
      );
    });

    group('State persistence', () {
      blocTest<FeedbackBloc, FeedbackState>(
        'maintains feedback data correctly through state transitions',
        build: () {
          when(() => mockSubmitFeedbackUseCase(
                type: FeedbackType.featureRequest,
                message: 'Feature request',
              )).thenAnswer((_) async => Right(mockFeedback));
          return feedbackBloc;
        },
        act: (bloc) => bloc.add(const SubmitFeedback(
          type: FeedbackType.featureRequest,
          message: 'Feature request',
        )),
        verify: (bloc) {
          final state = bloc.state;
          if (state is FeedbackSubmitted) {
            expect(state.feedback.id, isNotEmpty);
            expect(state.feedback.createdAt, isA<DateTime>());
          }
        },
      );
    });

    group('Complex scenarios', () {
      blocTest<FeedbackBloc, FeedbackState>(
        'handles submitting feedback after viewing history',
        build: () {
          when(() => mockGetFeedbackHistoryUseCase())
              .thenAnswer((_) async => Right(mockFeedbackList));
          when(() => mockSubmitFeedbackUseCase(
                type: FeedbackType.general,
                message: 'New feedback',
              )).thenAnswer((_) async => Right(mockFeedback));
          return feedbackBloc;
        },
        act: (bloc) async {
          bloc.add(const GetFeedbackHistory());
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(const SubmitFeedback(
            type: FeedbackType.general,
            message: 'New feedback',
          ));
        },
        expect: () => [
          const FeedbackLoading(),
          FeedbackHistoryLoaded(feedbackList: mockFeedbackList),
          const FeedbackLoading(),
          FeedbackSubmitted(feedback: mockFeedback),
        ],
      );
    });
  });
}
