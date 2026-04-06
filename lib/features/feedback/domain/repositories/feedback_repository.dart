import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/feedback/domain/entities/feedback.dart';

/// Repository interface for feedback operations
abstract class FeedbackRepository {
  /// Submit feedback to the server
  Future<Either<Failure, Feedback>> submitFeedback({
    required FeedbackType type,
    required String message,
  });

  /// Get user's feedback history (optional for future implementation)
  Future<Either<Failure, List<Feedback>>> getFeedbackHistory();
}
