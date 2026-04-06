import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_library/features/feedback/data/repositories/feedback_repository_impl.dart';
import 'package:flutter_library/features/feedback/data/datasources/feedback_remote_data_source.dart';
import 'package:flutter_library/features/feedback/data/models/feedback_model.dart';
import 'package:flutter_library/features/feedback/domain/entities/feedback.dart';
import 'package:flutter_library/core/network/network_info.dart';
import 'package:flutter_library/core/error/exceptions.dart';
import 'package:flutter_library/core/error/failures.dart';

class MockFeedbackRemoteDataSource extends Mock implements FeedbackRemoteDataSource {}
class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  group('FeedbackRepositoryImpl', () {
    late FeedbackRepositoryImpl repository;
    late MockFeedbackRemoteDataSource mockRemoteDataSource;
    late MockNetworkInfo mockNetworkInfo;

    setUpAll(() {
      registerFallbackValue(FeedbackType.general);
    });

    setUp(() {
      mockRemoteDataSource = MockFeedbackRemoteDataSource();
      mockNetworkInfo = MockNetworkInfo();
      repository = FeedbackRepositoryImpl(
        remoteDataSource: mockRemoteDataSource,
        networkInfo: mockNetworkInfo,
      );
    });

    final testFeedback = FeedbackModel(
      id: '1',
      type: FeedbackType.bugReport,
      message: 'Test feedback message',
      createdAt: DateTime.now(),
      status: FeedbackStatus.pending,
    );

    final testFeedbackList = [
      testFeedback,
      FeedbackModel(
        id: '2',
        type: FeedbackType.featureRequest,
        message: 'Feature request',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        status: FeedbackStatus.resolved,
      ),
    ];

    group('submitFeedback', () {
      test('should return feedback when network is connected and submission succeeds', () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockRemoteDataSource.submitFeedback(
          type: any(named: 'type'),
          message: any(named: 'message'),
        )).thenAnswer((_) async => testFeedback);

        // Act
        final result = await repository.submitFeedback(
          type: FeedbackType.bugReport,
          message: 'Test feedback message',
        );

        // Assert
        expect(result, equals(Right(testFeedback)));
        verify(() => mockNetworkInfo.isConnected).called(1);
        verify(() => mockRemoteDataSource.submitFeedback(
          type: FeedbackType.bugReport,
          message: 'Test feedback message',
        )).called(1);
      });

      test('should return NetworkFailure when network is not connected', () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

        // Act
        final result = await repository.submitFeedback(
          type: FeedbackType.bugReport,
          message: 'Test feedback message',
        );

        // Assert
        expect(result, equals(Left(NetworkFailure())));
        verify(() => mockNetworkInfo.isConnected).called(1);
        verifyNever(() => mockRemoteDataSource.submitFeedback(
          type: any(named: 'type'),
          message: any(named: 'message'),
        ));
      });

      test('should return ServerFailure when ServerException is thrown', () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockRemoteDataSource.submitFeedback(
          type: any(named: 'type'),
          message: any(named: 'message'),
        )).thenThrow(const ServerException('Server error'));

        // Act
        final result = await repository.submitFeedback(
          type: FeedbackType.bugReport,
          message: 'Test feedback message',
        );

        // Assert
        expect(result, equals(const Left(ServerFailure(message: 'Server error'))));
        verify(() => mockNetworkInfo.isConnected).called(1);
        verify(() => mockRemoteDataSource.submitFeedback(
          type: FeedbackType.bugReport,
          message: 'Test feedback message',
        )).called(1);
      });

      test('should return ServerFailure when any other exception is thrown', () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockRemoteDataSource.submitFeedback(
          type: any(named: 'type'),
          message: any(named: 'message'),
        )).thenThrow(Exception('Unexpected error'));

        // Act
        final result = await repository.submitFeedback(
          type: FeedbackType.bugReport,
          message: 'Test feedback message',
        );

        // Assert
        expect(result, equals(const Left(ServerFailure(message: 'Failed to submit feedback'))));
        verify(() => mockNetworkInfo.isConnected).called(1);
        verify(() => mockRemoteDataSource.submitFeedback(
          type: FeedbackType.bugReport,
          message: 'Test feedback message',
        )).called(1);
      });
    });

    group('getFeedbackHistory', () {
      test('should return feedback list when network is connected and request succeeds', () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockRemoteDataSource.getFeedbackHistory())
            .thenAnswer((_) async => testFeedbackList);

        // Act
        final result = await repository.getFeedbackHistory();

        // Assert
        expect(result, equals(Right(testFeedbackList)));
        verify(() => mockNetworkInfo.isConnected).called(1);
        verify(() => mockRemoteDataSource.getFeedbackHistory()).called(1);
      });

      test('should return NetworkFailure when network is not connected', () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

        // Act
        final result = await repository.getFeedbackHistory();

        // Assert
        expect(result, equals(Left(NetworkFailure())));
        verify(() => mockNetworkInfo.isConnected).called(1);
        verifyNever(() => mockRemoteDataSource.getFeedbackHistory());
      });

      test('should return ServerFailure when ServerException is thrown', () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockRemoteDataSource.getFeedbackHistory())
            .thenThrow(const ServerException('Failed to fetch'));

        // Act
        final result = await repository.getFeedbackHistory();

        // Assert
        expect(result, equals(const Left(ServerFailure(message: 'Failed to fetch'))));
        verify(() => mockNetworkInfo.isConnected).called(1);
        verify(() => mockRemoteDataSource.getFeedbackHistory()).called(1);
      });

      test('should return ServerFailure when any other exception is thrown', () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockRemoteDataSource.getFeedbackHistory())
            .thenThrow(Exception('Network timeout'));

        // Act
        final result = await repository.getFeedbackHistory();

        // Assert
        expect(result, equals(const Left(ServerFailure(message: 'Failed to get feedback history'))));
        verify(() => mockNetworkInfo.isConnected).called(1);
        verify(() => mockRemoteDataSource.getFeedbackHistory()).called(1);
      });

      test('should return empty list when no feedback history exists', () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockRemoteDataSource.getFeedbackHistory())
            .thenAnswer((_) async => []);

        // Act
        final result = await repository.getFeedbackHistory();

        // Assert
        expect(result, isA<Right<Failure, List<Feedback>>>());
        result.fold(
          (failure) => fail('Expected success'),
          (feedbackList) => expect(feedbackList, isEmpty),
        );
        verify(() => mockNetworkInfo.isConnected).called(1);
        verify(() => mockRemoteDataSource.getFeedbackHistory()).called(1);
      });
    });

    group('Edge Cases', () {
      test('should handle null or empty feedback message gracefully', () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockRemoteDataSource.submitFeedback(
          type: any(named: 'type'),
          message: any(named: 'message'),
        )).thenAnswer((_) async => testFeedback);

        // Act
        final result = await repository.submitFeedback(
          type: FeedbackType.bugReport,
          message: '',
        );

        // Assert
        expect(result, equals(Right(testFeedback)));
        verify(() => mockRemoteDataSource.submitFeedback(
          type: FeedbackType.bugReport,
          message: '',
        )).called(1);
      });

      test('should handle very long feedback message', () async {
        // Arrange
        final longMessage = 'a' * 10000;
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockRemoteDataSource.submitFeedback(
          type: any(named: 'type'),
          message: any(named: 'message'),
        )).thenAnswer((_) async => testFeedback);

        // Act
        final result = await repository.submitFeedback(
          type: FeedbackType.featureRequest,
          message: longMessage,
        );

        // Assert
        expect(result, equals(Right(testFeedback)));
        verify(() => mockRemoteDataSource.submitFeedback(
          type: FeedbackType.featureRequest,
          message: longMessage,
        )).called(1);
      });
    });
  });
}
