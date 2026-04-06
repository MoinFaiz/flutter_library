import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/exceptions.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/core/network/network_info.dart';
import 'package:flutter_library/features/feedback/data/datasources/feedback_remote_data_source.dart';
import 'package:flutter_library/features/feedback/domain/entities/feedback.dart';
import 'package:flutter_library/features/feedback/domain/repositories/feedback_repository.dart';

/// Implementation of feedback repository
class FeedbackRepositoryImpl implements FeedbackRepository {
  final FeedbackRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  FeedbackRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Feedback>> submitFeedback({
    required FeedbackType type,
    required String message,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final feedback = await remoteDataSource.submitFeedback(
          type: type,
          message: message,
        );
        return Right(feedback);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: 'Failed to submit feedback'));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<Feedback>>> getFeedbackHistory() async {
    if (await networkInfo.isConnected) {
      try {
        final feedbackList = await remoteDataSource.getFeedbackHistory();
        return Right(feedbackList);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: 'Failed to get feedback history'));
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}
