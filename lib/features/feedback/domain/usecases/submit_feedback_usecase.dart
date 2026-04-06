import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/feedback/domain/entities/feedback.dart';
import 'package:flutter_library/features/feedback/domain/repositories/feedback_repository.dart';

/// Use case for submitting feedback
class SubmitFeedbackUseCase {
  final FeedbackRepository repository;

  SubmitFeedbackUseCase({required this.repository});

  Future<Either<Failure, Feedback>> call({
    required FeedbackType type,
    required String message,
  }) async {
    if (message.trim().isEmpty) {
      return Left(ValidationFailure('Feedback message cannot be empty'));
    }
    
    if (message.trim().length < 10) {
      return Left(ValidationFailure('Please provide more detailed feedback (at least 10 characters)'));
    }

    return await repository.submitFeedback(
      type: type,
      message: message.trim(),
    );
  }
}
