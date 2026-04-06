import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/feedback/domain/entities/feedback.dart';
import 'package:flutter_library/features/feedback/domain/repositories/feedback_repository.dart';

/// Use case for getting feedback history
class GetFeedbackHistoryUseCase {
  final FeedbackRepository repository;

  GetFeedbackHistoryUseCase({required this.repository});

  Future<Either<Failure, List<Feedback>>> call() async {
    return await repository.getFeedbackHistory();
  }
}
